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


#define LAST_LOCATION @"kUserLocation"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/**
 *  <#Description#>
 */
typedef enum _PrecisionLocation {
    /**
     *  <#Description#>
     */
    LowPorecision = 5,
    /**
     *  <#Description#>
     */
    NormalPrecision = 10,
    /**
     *  <#Description#>
     */
    HighPrecision = 15
    
} PrecisionLocation;


/**
 *  This is a block of completion, for when background tasks are completed, can respond.
 *
 *  @param data  Dictionary of response
 *  @param error Error response
 */
typedef void (^ResponseDataCompletionBlock)(NSDictionary *data, NSError *error);

/**
 *  <#Description#>
 */
@protocol HACLocationManagerDelegate <NSObject>

@required

/**
 *  This method indicates its delegate when finished first obtaining location (latitude and longitude)
 */
-(void)didFinishFirstUpdateLocation:(CLLocation *)location;

/**
 *  This method is executed following didFinishFirstUpdateLocation:location for the exact location. You can upgrade the interface on each iteration of this method.
 */
-(void)didUpdatingLocationExactly:(CLLocation *)location;

/**
 *   This method indicates its delegate when finished first obtaining address (placemark)
 */
-(void)didFinishGetAddress:(NSDictionary *)placemark location:(CLLocation *)location;

/**
 *  This method indicates when obtaining the address fails
 */
-(void)didFailGettingAddressWithError:(NSError *)error;

/**
 *  This method indicates when obtaining the location fails
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

/**
 *  <#Description#>
 */
@interface HACLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

/**
 *  <#Description#>
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 *  <#Description#>
 */
@property (weak, nonatomic) id<HACLocationManagerDelegate>delegate;

/**
 *  <#Description#>
 */
@property int precision;

/**
 *  <#Description#>
 */
@property int firstUpdateSeconds;

/**
 *  This method is used to request permissions location, you can use them anywhere you want, 
 *  as long before requesting location.
 */
- (void) requestAuthorizationLocation;

/**
 *  <#Description#>
 *
 *  @param delegate <#delegate description#>
 */
- (void) startUpdatingLocationWithDelegate:(id)delegate;

/**
 *  <#Description#>
 *
 *  @param distanceFilter <#distanceFilter description#>
 */
- (void) setDistanceFilter:(double)distanceFilter;

/**
 *  <#Description#>
 *
 *  @param desired <#desired description#>
 */
- (void) setDesiredAccuary:(double)desired;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (CLLocation *) getLastSavedLocation;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (id) sharedInstance;

@end
