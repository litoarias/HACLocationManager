//
//  ViewController.m
//  LocationManager
//
//  Created by Hipolito Arias on 25/3/15.
//  Copyright (c) 2015 Hipolito Arias. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"

#define cellId @"CellId"

@interface ViewController () < MKMapViewDelegate, UISearchBarDelegate> {
    HACLocationManager *locationManager;
}

@property (strong, nonatomic) NSArray * section_0;
@property (strong, nonatomic) NSArray * section_1;
@property (strong, nonatomic) UIActivityIndicatorView *ai;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _section_0 = @[@""];
    _section_1 = @[@""];
    
    locationManager = [HACLocationManager sharedInstance];
    locationManager.timeoutUpdating = 6;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    
    NSLog(@"Last saved location: %@",locationManager.getLastSavedLocation);
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    self.mapView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mapView.layer.shadowOffset = CGSizeMake(4, 10);
    self.mapView.layer.shadowRadius = 5.0;
    self.mapView.layer.shadowOpacity = 0.6;
    self.mapView.layer.masksToBounds = NO;
    
    self.btnUSerLoc.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.btnUSerLoc.layer.shadowOffset = CGSizeMake(4, 10);
    self.btnUSerLoc.layer.cornerRadius = 4.0;
    self.btnUSerLoc.layer.shadowRadius = 5.0;
    self.btnUSerLoc.layer.shadowOpacity = 0.6;
    self.btnUSerLoc.layer.masksToBounds = NO;
    
    
    self.btnGeocoding.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.btnGeocoding.layer.shadowOffset = CGSizeMake(4, 10);
    self.btnGeocoding.layer.cornerRadius = 4.0;
    self.btnGeocoding.layer.shadowRadius = 5.0;
    self.btnGeocoding.layer.shadowOpacity = 0.6;
    self.btnGeocoding.layer.masksToBounds = NO;
    
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
    if (section==0) {
        return _section_0.count;
    }else if(section ==1){
        return _section_1.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = _section_0[indexPath.row];
            break;
            
        case 1:
            cell.textLabel.text = _section_1[indexPath.row];
            break;
    }
    
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    label.textColor = [UIColor whiteColor];
    
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    
    NSString *string =@"";
    
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

# pragma mark - MKMapViewDelegate
-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    
    MyPin.animatesDrop=TRUE;
    MyPin.pinColor = MKPinAnnotationColorPurple;
    MyPin.highlighted = NO;
    
    return MyPin;
}

# pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self tapReverseGeocoding:searchBar];
    
    
    [searchBar resignFirstResponder];
}

# pragma mark - IBActions

- (IBAction)tapUserLocation:(id)sender {
    
    [self startActivity];
    [self disabledButtons];
    
    __weak typeof(self) weakSelf = self;
    
    [locationManager LocationQuery];
    
    locationManager.locationUpdatedBlock = ^(CLLocation *location){
        
        
        weakSelf.section_0 = @[[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]];
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        
    };
    
    
    locationManager.locationEndBlock = ^(CLLocation *location){
        
        weakSelf.section_0 = @[[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]];
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        [weakSelf.ai stopAnimating];
        [weakSelf enableButtons];
        
        [weakSelf mapZoomWithMap:weakSelf.mapView userLocation:location];
        
    };
    
    
    
    locationManager.locationErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"Location Error"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles: nil]show];
        
        
        [weakSelf.ai stopAnimating];
        [weakSelf enableButtons];
    };
    
    
}

- (IBAction)tapGeocoding:(id)sender {
    [self startActivity];
    [self disabledButtons];
    
    __weak typeof(self) weakSelf = self;
    
    [locationManager GeocodingQuery];
    
    locationManager.geocodingBlock = ^(NSDictionary *placemark){
        
        weakSelf.section_1 = (NSArray *)[placemark valueForKey:@"FormattedAddressLines"];
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        [weakSelf.ai stopAnimating];
        [weakSelf enableButtons];
        
    };
    
    
    locationManager.geocodingErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"Geocoding Error"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles: nil]show];
        
        
        [weakSelf.ai stopAnimating];
        [weakSelf enableButtons];
        
    };
    
}


-(IBAction)tapReverseGeocoding:(id)sender{
    
    __weak typeof(self) weakSelf = self;
    
    UISearchBar *search = sender;
    
    [locationManager ReverseGeocodingQueryWithText:search.text];
    
    locationManager.reverseGeocodingBlock = ^(NSArray *placemarks){
        
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (int i = 0; i < [placemarks count]; i++)
        {
            CLPlacemark * thisPlacemark = [placemarks objectAtIndex:i];
            
            
            MKCoordinateRegion Bridge = { {0.0, 0.0} , {0.0, 0.0} };
            Bridge.center.latitude = thisPlacemark.location.coordinate.latitude;
            Bridge.center.longitude =thisPlacemark.location.coordinate.longitude;
            Bridge.span.longitudeDelta = 0.01f;
            Bridge.span.latitudeDelta = 0.01f;
            
            Annotation *ann = [[Annotation alloc] init];
            ann.title = @"Localidad: %@",[thisPlacemark valueForKey:@"locality"];
            ann.subtitle = @"Calle: %@",[thisPlacemark valueForKey:@"thoroughfare"];
            ann.coordinate = Bridge.center;
            
            [annotations addObject:ann];
            
//            NSLog(@"Comunidad: %@",[thisPlacemark valueForKey:@"administrativeArea"]);// Comunidad
//            NSLog(@"Localidad: %@",[thisPlacemark valueForKey:@"locality"]);// localidad
//            NSLog(@"Provincia: %@",[thisPlacemark valueForKey:@"subAdministrativeArea"]);// Provincia
//            NSLog(@"Número: %@",[thisPlacemark valueForKey:@"subThoroughfare"]);// Número
//            NSLog(@"Calle: %@",[thisPlacemark valueForKey:@"thoroughfare"]);// Calle
            
        }
        
        [weakSelf.mapView addAnnotations:annotations];
        Annotation *an = [annotations lastObject];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:an.coordinate.latitude
                                                     longitude:an.coordinate.longitude];
        [weakSelf mapZoomWithMap:weakSelf.mapView userLocation:loc];
       
    };
    
    locationManager.reverseGeocodingErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"Reverse Geocoding Error"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles: nil]show];
    };
    
}

# pragma mark - Private Methods

-(void)mapZoomWithMap:(MKMapView *)map userLocation:(CLLocation *)userLoc{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLoc.coordinate.latitude;
    location.longitude = userLoc.coordinate.longitude;
    region.span = span;
    region.center = location;
    [map setRegion:region animated:YES];
    
    
}

-(void)startActivity{
    
    //Create and add the Activity Indicator to splashView
    _ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _ai.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:.9];
    _ai.alpha = 1.0;
    _ai.center = self.view.center;
    _ai.hidesWhenStopped = YES;
    [self.view addSubview:_ai];
    [_ai startAnimating];
}



-(void)enableButtons{
    self.btnUSerLoc.enabled = YES;
    self.btnGeocoding.enabled = YES;
}

-(void)disabledButtons{
    self.btnUSerLoc.enabled = NO;
    self.btnGeocoding.enabled = NO;
}

@end
