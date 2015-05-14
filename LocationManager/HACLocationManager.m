//
//  LocationManager.m
//  Location
//
//  Created by Hipolito Arias on 8/1/15.
//  Copyright (c) 2015 MasterApps. All rights reserved.
//

#import "HACLocationManager.h"



@implementation HACLocationManager {
    BOOL _stopLocation;
    BOOL _isGeocoding;
    BOOL _isLocation;
    NSTimer *_queryingTimer;
    CLLocation *_location;
}

@synthesize timeoutUpdating = _timeoutUpdating;

# pragma mark - Getters
-(NSInteger)timeoutUpdating{
    return _timeoutUpdating;
}

# pragma mark - Setters
- (void) setTimeoutUpdating:(NSInteger)timeoutUpdating {
    _timeoutUpdating = timeoutUpdating;
}

# pragma mark - Life cycle

+ (instancetype) sharedInstance {
    static HACLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _timeoutUpdating = kDefaultTimeOut;
    }
    return self;
}

# pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(self.locationErrorBlock){
        self.locationErrorBlock(error);
    }
}

/**
 *  < iOS 8
 *
 */
-(void)locationManager:(CLLocationManager *)delegator didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self locationManagerDidUpdateToLocation:newLocation];
}

/**
 *  > iOS 8
 *
 */
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self locationManagerDidUpdateToLocation:[locations lastObject]];
}


# pragma mark - Public Methods

- (void) requestAuthorizationLocation{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingLocation];
}

-(void) LocationQuery{
    [self startUpdatingLocation];
    _isLocation=YES;
}

-(void) GeocodingQuery{
    [self startUpdatingLocation];
    _isGeocoding=YES;
    
}

- (CLLocation *) getLastSavedLocation{
    NSDictionary *userLoc = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION];
    return [[CLLocation alloc] initWithLatitude:[[userLoc objectForKey:@"lat"]doubleValue]
                                      longitude:[[userLoc objectForKey:@"lng"]doubleValue]];
}


# pragma mark - Private Methods

- (void) startUpdatingLocation{
    
    if ([self locationIsEnabled] && [self canUseLocation]) {
        
        if (!self.locationManager)
            self.locationManager = [[CLLocationManager alloc]init];
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted ) {
            [self dispatchAlertCheckingVersionSystem];
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined)
        {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            {
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        [self.locationManager startUpdatingLocation];
        [self startTimer];
    }else{
        [self dispatchAlertCheckingVersionSystem];
    }
    
}

-(void)locationManagerDidUpdateToLocation:(CLLocation *)newLocation
{
    if( newLocation == nil || newLocation.horizontalAccuracy < 0 )
    {
        return;
    }
    
    NSTimeInterval newLocationTime = -[newLocation.timestamp timeIntervalSinceNow];
    
    if( newLocationTime > 5.0 )
    {
        return;
    }
    
    CLLocationCoordinate2D newLocationCoordinate = newLocation.coordinate;
    
    if( !CLLocationCoordinate2DIsValid(newLocationCoordinate) || ( newLocationCoordinate.latitude == 0.0 && newLocationCoordinate.longitude == 0.0 ))
    {
        return;
    }
    
    _location = newLocation;
    
    if (self.locationUpdatedBlock) {
        self.locationUpdatedBlock(newLocation);
    }
    
    [self saveLocationInUSerDefaultsWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    
}


- (BOOL) locationIsEnabled{
    if(![CLLocationManager locationServicesEnabled] &&
       ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted))
        return NO;
    
    return YES;
    
}

- (BOOL) canUseLocation{
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        if ([CLLocationManager locationServicesEnabled] &&
            ((authStatus == kCLAuthorizationStatusAuthorizedAlways) ||
             (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) ||
             ((authStatus == kCLAuthorizationStatusNotDetermined))))
            return YES;
        
        return NO;
    }
    
    if ([CLLocationManager locationServicesEnabled] && ((authStatus == kCLAuthorizationStatusAuthorized) || ((authStatus == kCLAuthorizationStatusNotDetermined))))
        return YES;
    
    return NO;
    
}

- (void) saveLocationInUSerDefaultsWithLatitude:(double)lat longitude:(double)lng{
    
    NSNumber *latitude = [NSNumber numberWithDouble:lat];
    NSNumber *longitude = [NSNumber numberWithDouble:lng];
    
    NSDictionary *userLocation=@{@"lat":latitude,@"lng":longitude};
    
    [[NSUserDefaults standardUserDefaults]setObject:userLocation
                                             forKey:LAST_LOCATION];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1001){
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            if (&UIApplicationOpenSettingsURLString != NULL) {
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:settingsURL]) {
                    [[UIApplication sharedApplication] openURL:settingsURL];
                }
            }
        }
    }
}



- (void) getAddressFromLocation:(CLLocation *)location
{
    if ([self locationIsEnabled] && [self canUseLocation]) {
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (self.geocodingErrorBlock && (error || placemarks.count == 0)) {
                self.geocodingErrorBlock(error);
            } else {
                //                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                if(self.geocodingBlock) {
                    self.geocodingBlock(placemarks);
                }
            }
        }];
    }else{
        [self dispatchAlertCheckingVersionSystem];
    }
}

- (void) dispatchAlertCheckingVersionSystem{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView setTag:1001];
        [alertView show];
        
    }
    else{
        NSString *titles;
        titles = @"Title";
        NSString *msg = @"Location services are off. To use location services you must turn on 'Always' in the Location Services Settings from Click on 'Settings' > 'Privacy' > 'Location Services'. Enable the 'Location Services' ('ON')";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titles
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

- (NSError*) getCustomErrorWithUserInfo:(NSString *)info{
    return [NSError errorWithDomain:kCLErrorDomain
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey:info}];
    
}


-(void)startTimer
{
    [self stopTimer];
    _queryingTimer = [NSTimer scheduledTimerWithTimeInterval:_timeoutUpdating
                                                      target:self
                                                    selector:@selector(timerPassed)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)stopTimer
{
    if (_queryingTimer)
    {
        if ([_queryingTimer isValid])
        {
            [_queryingTimer invalidate];
        }
        _queryingTimer = nil;
    }
}

-(void)timerPassed
{
    [self stopTimer];
    
    [self.locationManager stopUpdatingLocation];
    
    if (_isLocation) {
        if (self.locationEndBlock) {
            self.locationEndBlock(_location);
        }
        _isLocation=NO;
    }
    
    if(_isGeocoding){
        [self getAddressFromLocation:_location];
        _isGeocoding=NO;
    }
    
}

-(void) ReverseGeocodingQueryWithText:(NSString *)addressText
{
    CLCircularRegion *currentRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(-33.861506931797535,151.21294498443604)
                                                                        radius:25000
                                                                    identifier:@"NEARBY"];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder geocodeAddressString:addressText inRegion:currentRegion completionHandler:^(NSArray *placemarks, NSError *error){
        if (error)
        {
            self.reverseGeocodingErrorBlock(error);
            
            return;
        }
        
        if (!placemarks)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No placemarks" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        self.reverseGeocodingBlock(placemarks);
    }];
    
}



-(void) RoutesBetweenTwoPointsWithUserLat:(float)latUser
                                  lngUser:(float)lngUser
                                  latDest:(float)latDest
                                  lngDest:(float)lngDest
                             transporType:(NSString *)transportType
                        onCompletionBlock:(DistanceCompletionBlock)onCompletion{
    
    MKPlacemark *source = [[MKPlacemark   alloc]initWithCoordinate:CLLocationCoordinate2DMake(latUser, lngUser)   addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(latDest, lngDest) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    
    if ([transportType isEqualToString:automovile]) {
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
    }else if ([transportType isEqualToString:walking]){
        [request setTransportType:MKDirectionsTransportTypeWalking];
    }else{
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
    }
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        //        MKRoute * rou = [[response routes]objectAtIndex:0];
        //        NSLog(@"%@",[self stringFromInterval:rou.expectedTravelTime]);
        
        onCompletion([response routes], nil);
    }];
}


// Transform NSTimeInterval to 00:00:00
-(NSString *) stringFromInterval:(NSTimeInterval) timeInterval
{
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}

@end
