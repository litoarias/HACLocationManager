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
-(void)didFinishGetLocationWithLocation:(CLLocation *)location;
-(void)didFinishGettingFullAddress:(NSDictionary *)address;

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
 *  This method is used to request permissions location, you can use them anywhere you want, 
 *  as long before requesting location.
 */
- (void) requestAuthorizationLocation;

/**
 *  <#Description#>
 *
 *  @param delegate <#delegate description#>
 */
- (void) getFullAddressFromLastLocationWithDelegate:(id)delegate;

/**
 *  <#Description#>
 *
 *  @param delegate <#delegate description#>
 */
- (void) startUpdatingLocationWithDelegate:(id)delegate;

/**
 *  <#Description#>
 */
- (void) stopUpdatingLocationNow;

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
 *  @param lat <#lat description#>
 *  @param lng <#lng description#>
 */
- (void) saveLocationInUSerDefaultsWithLatitude:(double)lat longitude:(double)lng;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) locationIsEnabled;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (id) sharedInstance;

@end
