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
#import <MapKit/MapKit.h>

#define kDefaultTimeOut 5
#define LAST_LOCATION @"kUserLocation"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define walking @"kWalking"
#define automovile @"kAutomovile"

// LOCATION -> Manages without blocks the various events on location. Updates , last update and error event.
/**
 *  Updating location, previous timeout
 *
 *  @param CLLocation
 */
typedef void (^HACLocationManagerUpdatingCallback)(CLLocation *);

/**
 *  End callback location
 *
 *  @param CLLocation
 */
typedef void (^HACLocationManagerEndCallback)(CLLocation *);

/**
 *  Error callback
 *
 *  @param NSError description
 */
typedef void (^HACLocationManagerErrorCallback)(NSError *);



// GEOCODING -> Manages without blocks the various events on Geocoding. Callback or error event.
/**
 *  Callback success
 *
 *  @param NSDictionary of placemark
 */
typedef void (^HACGeocodingManagerCallback)(NSArray *);

/**
 *  Error callback
 *
 *  @param NSError of Description error
 */
typedef void (^HACGeocodingManagerErrorCallback)(NSError *);

// REVERSE GEOCODING -> Manages without blocks the various events on Geocoding. Callback or error event.
/**
 *  Callback success
 *
 *  @param NSDictionary of placemark
 */
typedef void (^HACReverseGeocodingManagerCallback)(NSArray *);

/**
 *  Error callback
 *
 *  @param NSError of Description error
 */
typedef void (^HACReverseGeocodingManagerErrorCallback)(NSError *);

/**
 *  Distance callBack
 *
 */
typedef void (^DistanceCompletionBlock)(double distance, NSError *error);

@interface HACLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSInteger timeoutUpdating;
@property (nonatomic, copy) HACLocationManagerUpdatingCallback locationUpdatedBlock;
@property (nonatomic, copy) HACLocationManagerEndCallback locationEndBlock;
@property (nonatomic, copy) HACLocationManagerErrorCallback locationErrorBlock;
@property (nonatomic, copy) HACGeocodingManagerCallback geocodingBlock;
@property (nonatomic, copy) HACGeocodingManagerErrorCallback geocodingErrorBlock;
@property (nonatomic, copy) HACReverseGeocodingManagerCallback reverseGeocodingBlock;
@property (nonatomic, copy) HACReverseGeocodingManagerErrorCallback reverseGeocodingErrorBlock;


/**
 *  This method is used to request permissions location, you can use them anywhere you want, 
 *  as long before requesting location.
 */
- (void) requestAuthorizationLocation;

- (void) LocationQuery;

- (void) GeocodingQuery;

- (void) ReverseGeocodingQueryWithText:(NSString *)addressText;

- (CLLocation *) getLastSavedLocation;

-(void) DistanceBetweenTwoPointsWithUserLat:(float)latUser
                                   lngUser:(float)lngUser
                                   latDest:(float)latDest
                                   lngDest:(float)lngDest
                              transporType:(NSString *)transportType
                         onCompletionBlock:(DistanceCompletionBlock)onCompletion;

+ (id) sharedInstance;

@end
