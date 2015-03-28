# [![Logo](https://github.com/litoarias/HACLocationManager/blob/master/ExampleApp/github.png)](#)
HACLocationManager is written in Objective-C, very easy to use and effective class.  
Requests are made using blocks, giving answers through their delegates. If syntax is very comfortable and intuitive.
Use singleton design pattern and its compatibility is complete with iOS7 or higher.

##Requirements & Dependecies
- iOS >= 6.0
- ARC enabled
- CoreLocation Framework

##Installation

####CocoaPods:
Building

####Manual install:
- Copy `HACLocationManager.h` and `HACLocationManager.m` to your project
- Manual install [HACLocationManager](https://github.com/litoarias/HACLocationManager/#manual-install)

##Usage

###iOS 8
Since iOS 8 it is required to add `NSLocationWhenInUseUsageDescription` key to your `Info.plist` file. Value for this key will be a description of UIAlertView presented to user while asking for location  permission. See [Apple documentation](https://developer.apple.com/library/ios/documentation/corelocation/reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/requestWhenInUseAuthorization) for more info.

Basically all you need to do is to add single entry in your `Info.plist` file. Add key `NSLocationWhenInUseUsageDescription`, and select type `String`. The value you enter for this entry will be shown as text in UIAlertView presented to user first time you try to determine his location.
In the end it should look similar to this:

![Added entry to Info.plist](https://github.com/litoarias/HACLocationManager/blob/master/ExampleApp/Info_plist.png)
