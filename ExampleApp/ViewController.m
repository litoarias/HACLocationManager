//
//  ViewController.m
//  LocationManager
//
//  Created by Hipolito Arias on 25/3/15.
//  Copyright (c) 2015 Hipolito Arias. All rights reserved.
//

#import "ViewController.h"

#define cellId @"CellId"

@interface ViewController () <HACLocationManagerDelegate> {
    NSMutableArray * dataForTable;
    UIActivityIndicatorView *ai;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[HACLocationManager sharedInstance]requestAuthorizationLocation];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    dataForTable = [NSMutableArray new];
    dataForTable[0] = @"";
    dataForTable[1] = @"";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.mapView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mapView.layer.shadowOffset = CGSizeMake(4, 10);
    self.mapView.layer.shadowRadius = 5.0;
    self.mapView.layer.shadowOpacity = 0.6;
    self.mapView.layer.masksToBounds = NO;
    
    self.btnAddress.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnAddress.layer.shadowOffset = CGSizeMake(4, 10);
    self.btnAddress.layer.cornerRadius = 4.0;
    self.btnAddress.layer.shadowRadius = 5.0;
    self.btnAddress.layer.shadowOpacity = 0.6;
    self.btnAddress.layer.masksToBounds = NO;
    
    self.btnUSerLoc.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnUSerLoc.layer.shadowOffset = CGSizeMake(4, 10);
    self.btnUSerLoc.layer.cornerRadius = 4.0;
    self.btnUSerLoc.layer.shadowRadius = 5.0;
    self.btnUSerLoc.layer.shadowOpacity = 0.6;
    self.btnUSerLoc.layer.masksToBounds = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    

    switch (indexPath.section) {
        case 0:
            if (dataForTable[0])
                cell.textLabel.text = dataForTable[0];
            break;
            
        case 1:
            if (dataForTable[1])
                cell.textLabel.text = dataForTable[1];
            break;
        
        default:
            
            break;
    }
    
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    
    
    
    NSString *string =@"Test";
    
    switch (section) {
        case 0:
            string = @"Lat - Lng";
            break;
            
        case 1:
            string = @"Address";
            break;
        default:
            break;
    }
    
    [label setText:string];
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:0.29 green:0.53 blue:0.91 alpha:1.0]];
    
    return view;
}

- (IBAction)tapUserLocation:(id)sender {
    
    [[HACLocationManager sharedInstance]startUpdatingLocationWithDelegate:self];
}

- (IBAction)tapGetAddress:(id)sender {
    [[HACLocationManager sharedInstance]getFullAddressFromLastLocationWithDelegate:self];
}

-(void)startActivity{
    
    ai = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ai.hidesWhenStopped = YES;
    [ai startAnimating];
    ai.center = self.view.center;
    
    [self.view addSubview:ai];
}

# pragma mark - HACLocationManager
-(void)didFinishGetLocationWithLocation:(CLLocation *)location{
    
    dataForTable[0] = [NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude];
    [self.tableView reloadData];
    [ai stopAnimating];
}

-(void)didFinishGettingFullAddress:(NSDictionary *)address{
    
    
    [ai stopAnimating];
}


@end
