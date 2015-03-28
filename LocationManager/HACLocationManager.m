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
    BOOL _firstUpdate;
    BOOL _othersUpdate;
}

@synthesize precision = _precision;
@synthesize firstUpdateSeconds = _firstUpdateSeconds;

/**
 *  GETTERS
 */
- (int)precision{
    return _precision;
}
- (int)firstUpdateSeconds{
    return _firstUpdateSeconds;
}

/**
 *  SETTERS
 */
- (void) setPrecision:(int)precision{
    _precision = precision;
}
- (void) setFirstUpdateSeconds:(int)firstUpdateSeconds{
    _firstUpdateSeconds = firstUpdateSeconds;
}

# pragma mark - Life cycle

+ (id) sharedInstance {
    static HACLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        _precision = NormalPrecision;
        _firstUpdateSeconds = 3;
    }
    return self;
}

# pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.delegate locationManager:manager didFailWithError:[self getCustomError]];
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
    
    if (_firstUpdate)
    {
        [self.delegate didFinishFirstUpdateLocation:newLocation];
        _firstUpdate = NO;
        return;
    }
    
    if (_othersUpdate)
    {
        [self.delegate didUpdatingLocationExactly:newLocation];
    }
    
    [self saveLocationInUSerDefaultsWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    
    if (!_stopLocation)
    {
        return;
    }
    
    [self getFullAddressWihtLocation:newLocation];
    
    [self stopUpdatingLocationNow];
    
    _stopLocation = NO;
    
    _othersUpdate = NO;
    
}

# pragma mark - Public Methods

- (void) requestAuthorizationLocation{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingLocation];
}

- (void) getFullAddressWihtLocation:(CLLocation *)location{
    
    if ([self locationIsEnabled] && [self canUseLocation]) {
        
        
        [self getAddressFromLocation:location onCompletion:^(NSDictionary *dataReceive, NSError *error){
            
            if (!error) {
                [self.delegate didFinishGetAddress:dataReceive location:location];
            }else{
                [self.delegate didFailGettingAddressWithError:error];
            }
            
        }];
    }else{
        [self.delegate locationManager:nil didFailWithError:[self getCustomError]];
        [self dispatchAlertCheckingVersionSystem];
    }
    
}

- (void) startUpdatingLocationWithDelegate:(id)delegate{
    
    if (delegate){
        self.delegate = nil;
        self.delegate = delegate;
    }
    
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
        
        [self dispatchAfterForUpdateUI];
        [self dispatchAfterForStopUpdatingLocation];
        
        [self.locationManager startUpdatingLocation];
        
    }else{
        [self.delegate locationManager:nil didFailWithError:[self getCustomError]];
        [self dispatchAlertCheckingVersionSystem];
    }
    
}

- (void) setDistanceFilter:(double)distanceFilter{
    _locationManager.desiredAccuracy = distanceFilter;
}

- (void) setDesiredAccuary:(double)desired{
    _locationManager.desiredAccuracy = desired;
}

- (CLLocation *) getLastSavedLocation{
    
    NSDictionary *userLoc = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION];
    
    return [[CLLocation alloc] initWithLatitude:[[userLoc objectForKey:@"lat"]doubleValue]
                                      longitude:[[userLoc objectForKey:@"lng"]doubleValue]];
}


# pragma mark - Private Methods

- (void) stopUpdatingLocationNow{
    [_locationManager stopUpdatingLocation];
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
              completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler([placemark.addressDictionary mutableCopy]);
            }
        }
    }];
}

- (void) getAddressFromLocation:(CLLocation *)location onCompletion:(ResponseDataCompletionBlock)completionBlock{
    
    // Call the method to find the address
    [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
        
        //        NSLog(@"address informations : %@", d);
        //        NSLog(@"Street : %@", [d valueForKey:@"Street"]);
        //        NSLog(@"ZIP code : %@", [d valueForKey:@"ZIP"]);
        //        NSLog(@"City : %@", [d valueForKey:@"City"]);
        //        NSLog(@"formatted address : %@", [d valueForKey:@"FormattedAddressLines"]);
        
        completionBlock(d, nil);
        
    } failureHandler:^(NSError *error) {
        completionBlock(nil, error);
    }];
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

- (NSError*) getCustomError{
    return [NSError errorWithDomain:@"Fail Location Permissions"
                               code:1111
                           userInfo:@{NSLocalizedDescriptionKey:@"Location services are not enabled"}];
    
}

- (void)dispatchAfterForStopUpdatingLocation{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_precision * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopUpdatingLocation];
    });
}

- (void)dispatchAfterForUpdateUI{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_firstUpdateSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startUpdatingUI];
    });
}

- (void) stopUpdatingLocation{
    _stopLocation = YES;
}

- (void) startUpdatingUI{
    _firstUpdate = YES;
    _othersUpdate = YES;
}

@end
