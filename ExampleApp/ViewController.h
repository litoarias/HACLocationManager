//
//  ViewController.h
//  LocationManager
//
//  Created by Hipolito Arias on 25/3/15.
//  Copyright (c) 2015 Hipolito Arias. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HACLocationManager.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnUSerLoc;

@property (weak, nonatomic) IBOutlet UIButton *btnAddress;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)tapUserLocation:(id)sender;

- (IBAction)tapGetAddress:(id)sender;

@end

