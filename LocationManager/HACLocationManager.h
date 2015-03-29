//
//  USerLocationManager.h
//  Location
//
//  Created by Hipolito Arias on 8/1/15.
//  Copyright (c) 2015 MasterApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kDefaultTimeOut 5
#define LAST_LOCATION @"kUserLocation"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef void (^HACLocationManagerUpdatingCallback)(CLLocation *);
typedef void (^HACLocationManagerEndCallback)(CLLocation *);
typedef void (^HACLocationManagerErrorCallback)(NSError *);

typedef void (^HACGeocodingManagerCallback)(NSDictionary *);
typedef void (^HACGeocodingManagerErrorCallback)(NSError *);


@interface HACLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) HACLocationManagerUpdatingCallback locationUpdatedBlock;
@property (nonatomic, copy) HACLocationManagerEndCallback locationEndBlock;
@property (nonatomic, copy) HACLocationManagerErrorCallback locationErrorBlock;

@property (nonatomic, copy) HACGeocodingManagerCallback geocodingUpdatedBlock;
@property (nonatomic, copy) HACGeocodingManagerErrorCallback geocodingErrorBlock;

/**
 *  This method is used to request permissions location, you can use them anywhere you want, 
 *  as long before requesting location.
 */
- (void) requestAuthorizationLocation;

-(void) Location;

-(void) Geocoding;

- (CLLocation *) getLastSavedLocation;

+ (id) sharedInstance;

@end
