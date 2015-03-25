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


// Block Completion
typedef void (^ResponseDataCompletionBlock)(NSDictionary *plays, NSError *error);


@protocol HACLocationManagerDelegate <NSObject>

@required

-(void)didFinishGetLocationWithLocation:(CLLocation *)location;
-(void)didFinishGettingFullAddress:(NSDictionary *)address;

@end


@interface HACLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) id<HACLocationManagerDelegate>delegate;

- (void) requestAuthorizationLocation;
- (void) getFullAddressFromLastLocationWithDelegate:(id)delegate;
- (void) startUpdatingLocationWithDelegate:(id)delegate;
- (void) stopUpdatingLocationNow;
- (void) setDistanceFilter:(double)distanceFilter;
- (void) setDesiredAccuary:(double)desired;
- (CLLocation *) getLastSavedLocation;
- (void) saveLocationInUSerDefaultsWithLatitude:(double)lat longitude:(double)lng;
- (BOOL) locationIsEnabled;

+ (id) sharedInstance;

@end
