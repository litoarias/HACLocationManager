# [![Logo](https://github.com/litoarias/HACLocationManager/blob/master/ExampleApp/github.png)](#)

<img src="https://img.shields.io/twitter/url/https/github.com/litoarias/HACLocationManager.svg?style=social"><br>

<img src="https://img.shields.io/github/issues/litoarias/HACLocationManager.svg?style=flat-square">
<img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square">
<img src="https://img.shields.io/cocoapods/v/HACLocationManager.svg?style=flat-square">
<img src="https://img.shields.io/npm/dm/HACLocationManager.svg?style=flat-square">


HACLocationManager is written in Objective-C, very easy to use and effective class.  
Requests are made using blocks. Its syntax is very comfortable and intuitive.
Use singleton design pattern and its compatibility is complete with iOS7 or higher.
This class is not for use as GPS, only for obtain user location in any moment and get geocoding and reverse geocoding.

##Requirements and Dependencies
- iOS >= 7.0
- ARC enabled
- CoreLocation Framework

##Installation

####CocoaPods:

    	pod 'HACLocationManager'

####Carthage:
        github "litoarias/HACLocationManager"


####Manual install:
- Copy `HACLocationManager.h` and `HACLocationManager.m` to your project
- Manual install [HACLocationManager](https://github.com/litoarias/HACLocationManager/#manual-install)

##Usage

### Requesting Permission to Access Location Services

#### iOS 7
For iOS 7, it is recommended that you provide a description for how your app uses location services by setting a string for the key [`NSLocationUsageDescription`](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW27) in your app's `Info.plist` file.

#### iOS 8
Since iOS 8 it is required to add `NSLocationWhenInUseUsageDescription` key to your `Info.plist` file. Value for this key will be a description of UIAlertView presented to user while asking for location  permission. See [Apple documentation](https://developer.apple.com/library/ios/documentation/corelocation/reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/requestWhenInUseAuthorization) for more info.

Basically all you need to do is to add single entry in your `Info.plist` file. Add key `NSLocationWhenInUseUsageDescription`, and select type `String`. The value you enter for this entry will be shown as text in UIAlertView presented to user first time you try to determine his location.
In the end it should look similar to this:

![Added entry to Info.plist](https://github.com/litoarias/HACLocationManager/blob/master/ExampleApp/Info_plist.png)

### Request permissions
To request permissions location, when you want independently to any operation. This request must always be performed before applying any other. I recommend do it in your AppDelegate.
```objective-c
[[HACLocationManager sharedInstance]requestAuthorizationLocation];
```
##### Instance class & set time out
You can configure time out for updates in request, for default it's 5 seconds
```objective-c
HACLocationManager *locationManager = [HACLocationManager sharedInstance];
locationManager.timeoutUpdating = 6;
```

###Obtain user location 
Is obtained by locating blocks, based on the location and updates the last location obtained. The first is optional, only if your application requires it.

##### Request get Location
```objective-c
[locationManager LocationQuery];
```
##### Updates Location
```objective-c
locationManager.locationUpdatedBlock = ^(CLLocation *location){
  NSLog(@"%@", location);
};
```
##### End updates Location
```objective-c
locationManager.locationEndBlock = ^(CLLocation *location){
  NSLog(@"%@", location);
};
```

##### Failed to obtain the Location
```objective-c
locationManager.locationErrorBlock = ^(NSError *error){
  NSLog(@"%@", error);
};
```
###Geocoding

##### Request Geocoding of User Location
```objective-c
[locationManager GeocodingQuery];
```
##### Get Address of User
Can multiple placemarks are received, so an array is returned 
```objective-c
locationManager.geocodingBlock = ^(NSArray *placemarks){
    
    CLPlacemark *placemark = (CLPlacemark *)placemarks[0];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
       placemark.subThoroughfare ? placemark.subThoroughfare : @"",
       placemark.thoroughfare ? placemark.thoroughfare : @"",
       placemark.postalCode ? placemark.postalCode : @"",
       placemark.locality ? placemark.locality : @"",
       placemark.administrativeArea ? placemark.administrativeArea : @"",
       placemark.country ? placemark.country : @""]);
};
```

##### Failed to obtain Address
```objective-c
locationManager.geocodingErrorBlock = ^(NSError *error){
  NSLog(@"%@", error);
};
```

### Reverse Geocoding
##### Request Reverse Geocoding
```objective-c
[locationManager ReverseGeocodingQueryWithText:@"1755 Embarcadero Road Palo Alto, CA 94303"];
```
##### Response
Can multiple placemarks are received, so an array is returned 
```objective-c
locationManager.reverseGeocodingBlock = ^(NSArray *placemarks){
  for (int i = 0; i < [placemarks count]; i++){
     CLPlacemark * thisPlacemark = [placemarks objectAtIndex:i];
     NSLog(@"%@", thisPlacemark);
  }
};
```
##### Failed block
```objective-c
locationManager.reverseGeocodingErrorBlock = ^(NSError *error){
  NSLog("%@", error);
};
```

### Get last stored location
You can also get the latest location of the user stored persistently for those cases in which the location is not available.
```objective-c
NSLog(@"%@",locationManager.getLastSavedLocation);
```

### Get the route between two points.
You can try changing the parameters in the sample project, changing the parameters of latitude and longitude.
The means of transport can also be chosen, walking or automovile, for default it's automovile.
```objective-c
[[HACLocationManager sharedInstance]RoutesBetweenTwoPointsWithUserLat:40.4376751
                                                                    lngUser:-3.7044201
                                                                    latDest:40.0619721
                                                                    lngDest:-2.1480249
                                                               transporType:automovile
                                                          onCompletionBlock:^(NSArray * routes, NSError *error){
        if(!error){
           
            [routes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                MKRoute *route = obj;
                
                MKPolyline *line = [route polyline];
                
                [self.mapView addOverlay:line];
                
                NSLog(@"Rout Name : %@",route.name);
                
                NSLog(@"Total Distance (in Meters) :%f",route.distance);
                
                NSArray *steps = [route steps];
                
                NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
                
                [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSLog(@"Rout Instruction : %@",[obj instructions]);
                    
                    NSLog(@"Rout Distance : %f",[obj distance]);
                    
                }];
            }];
        }else{
            NSLog(@"%@", [error localizedDescription]);
        }

    }];
```


Enjoy :D

## Contributing

1. Fork it ( https://github.com/[my-github-username]/HACLocationManager/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
