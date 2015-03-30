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
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
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
    _isGeocoding = YES;
    
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
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
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
                
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                if(self.geocodingBlock) {
                    self.geocodingBlock([placemark.addressDictionary mutableCopy]);
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
    }
    if(_isGeocoding){
        [self getAddressFromLocation:_location];
        _isGeocoding=NO;
    }
    
    
}






















-(IBAction) onRGeoWithText:(NSString*)textLocation
{
    
    
    CLCircularRegion *currentRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(-33.861506931797535,151.21294498443604)
                                                                        radius:25000
                                                                    identifier:@"NEARBY"];
    
    //    CLRegion * currentRegion = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(-33.861506931797535,151.21294498443604)
    //                                                                       radius:25000 identifier:@"NEARBY"];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:textLocation inRegion:currentRegion completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             //             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Dirección errónea, imposible de localizar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
             
             return;
         }
         
         if (!placemarks)
         {
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No placemarks" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
             
             
             return;
         }
         
         
         if(placemarks.count > 1){
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Varias coincidencias" message:@"Han salido varios resultados, matiza mejor la dirección. Vuelve a intertarlo" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
             return;
         }
         for (int i = 0; i < [placemarks count]; i++)
         {
             CLPlacemark * thisPlacemark = [placemarks objectAtIndex:i];
             
             //             NSLog(@"%@",[thisPlacemark valueForKey:@"administrativeArea"]);// Comunidad
             //             NSLog(@"%@",[thisPlacemark valueForKey:@"locality"]);// localidad
             //             //            NSLog(@"%@",[thisPlacemark valueForKey:@"postCode"]);// CP
             //             NSLog(@"%@",[thisPlacemark valueForKey:@"subAdministrativeArea"]);// Provincia
             //             NSLog(@"%@",[thisPlacemark valueForKey:@"subThoroughfare"]);// Número
             //             NSLog(@"%@",[thisPlacemark valueForKey:@"thoroughfare"]);// Calle
             //             NSLog(@"%f",thisPlacemark.location.coordinate.latitude);// Calle
             //             NSLog(@"%f",thisPlacemark.location.coordinate.longitude);// Calle
             
             //             lat = thisPlacemark.location.coordinate.latitude;
             //             lng = thisPlacemark.location.coordinate.longitude;
             
             //             NSString *numero = [thisPlacemark valueForKey:@"subThoroughfare"] == nil ? @"" : [thisPlacemark valueForKey:@"subThoroughfare"];
             
             if([thisPlacemark valueForKey:@"administrativeArea"] == nil ||
                [thisPlacemark valueForKey:@"locality"] == nil ||
                [thisPlacemark valueForKey:@"subAdministrativeArea"] == nil ||
                [thisPlacemark valueForKey:@"thoroughfare"] == nil ||
                thisPlacemark.location.coordinate.latitude == 0.0 ||
                thisPlacemark.location.coordinate.longitude == 0.0){
                 
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se ha podido establecer la dirección porque los datos no son válidos, vuelve a intertarlo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 
                 
                 return;
             }
             
             //
             //             self.fieldAddressComplet.text = [NSString stringWithFormat:@"%@ %@, %@", [thisPlacemark valueForKey:@"thoroughfare"],numero,[thisPlacemark valueForKey:@"locality"]];
             //             self.fieldProvincia.text = [thisPlacemark valueForKey:@"subAdministrativeArea"];
             //             self.fieldComunidad.text = [thisPlacemark valueForKey:@"administrativeArea"];
             //            NSLog(@"%@",thisPlacemark);
             //
             //             MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
             //             annotationPoint.coordinate = thisPlacemark.location.coordinate;
             //             annotationPoint.title = thisPlacemark.name;
             //             [self.map addAnnotation:annotationPoint];
             //             [self.map setCenterCoordinate:thisPlacemark.location.coordinate];
             //             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (thisPlacemark.location.coordinate, 25000, 25000);
             //             [self.map setRegion:region animated:NO];
             
         }
         
         
     }];
}


















//switch (self.locationErrorCode)
//{
//    case kCLErrorLocationUnknown:
//        [self alert:@"Couldn't figure out where this photo was taken (yet)."]; break;
//    case kCLErrorDenied:
//        [self alert:@"Location Services disabled under Privacy in Settings application."]; break;
//    case kCLErrorNetwork:
//        [self alert:@"Can't figure out where this photo is being taken.  Verify your connection to the network."]; break;
//    default:
//        [self alert:@"Cant figure out where this photo is being taken, sorry."]; break;
//}

@end
