//
//  PlaceViewController.m
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import "PlaceViewController.h"
#import "ParallaxCell.h"
#import "DetailViewController.h"
#import "AFNetworking.h"


@interface PlaceViewController () <UIScrollViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>


@end

@implementation PlaceViewController

const NSString * API_URL_FOR_PLACE = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
const NSString * API_URL_FOR_PHOTO = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=640&maxheight=402";
const NSString * API_URL_FOR_DETAIL = @"https://maps.googleapis.com/maps/api/place/details/json?";
const NSString * API_URL_FOR_MAP = @"https://www.google.com/maps/embed/v1/place?";
const NSString * API_KEY = @"AIzaSyCXTs1jpiaCLWknu0mrIqepraIfSU9l6cg";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self
                     action:@selector(refreshAction:)
           forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refresh];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        [self.locationManager requestWhenInUseAuthorization];
    } else { // iOS7以前
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self scrollViewDidScroll:nil];
}

- (void)viewWillDisappear {
    self.locationManager.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)getPlaceListWith:(double)latitude and:(double)longtitude {
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    NSString *placeUrl = [NSString stringWithFormat:@"%@?location=%f,%f&radius=1000&types=%@&sensor=true&key=%@", API_URL_FOR_PLACE, latitude, longtitude, self.types, API_KEY];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:placeUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"OK"]) {
            self.placeList = responseObject[@"results"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                [self.refresh endRefreshing];
            });
        } else if ([[responseObject valueForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No result." message:@"Sorry.. No Result." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.tableView addSubview:alert];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Over Query Limit.Please Try Again Tomorrow" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.tableView addSubview:alert];
            [alert show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

// 位置情報が許可されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

// 位置情報が更新すると呼ばれる
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    [self getPlaceListWith:newLocation.coordinate.latitude and:newLocation.coordinate.longitude];
    [self.locationManager stopUpdatingLocation];
}

- (void)refreshAction:(id)sender {
    [sender beginRefreshing];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"parallaxCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.placeList[indexPath.row][@"photos"] valueForKey:@"photo_reference"][0]) {
        NSString *photoUrl = [NSString stringWithFormat:@"%@&photoreference=%@&sensor=true&key=%@", API_URL_FOR_PHOTO, [self.placeList[indexPath.row][@"photos"] valueForKey:@"photo_reference"][0], API_KEY];
        [cell setImageWith:photoUrl];
    } else {
        cell.parallaxImage.image = [UIImage imageNamed:@"noPhoto"];
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", self.placeList[indexPath.row][@"name"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *detailUrl = [NSString stringWithFormat:@"%@reference=%@&sensor=true&key=%@", API_URL_FOR_DETAIL, self.placeList[indexPath.row][@"reference"], API_KEY];
    NSURLRequest *detailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:detailUrl]];
    NSData *detailJson = [NSURLConnection sendSynchronousRequest:detailRequest returningResponse:nil error:nil];
    NSError *error=nil;
    NSArray *detailArray = [NSJSONSerialization JSONObjectWithData:detailJson options:NSJSONReadingAllowFragments error:&error];
    
    NSString *inputString = [NSString stringWithFormat:@"%@", self.placeList[indexPath.row][@"name"]];
    CFStringRef originalString = (__bridge CFStringRef)inputString;
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        originalString,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);
    
    NSString *mapUrl = [NSString stringWithFormat:@"%@key=%@&q=%@", API_URL_FOR_MAP, API_KEY, encodedString];
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.name = [NSString stringWithFormat:@"%@", self.placeList[indexPath.row][@"name"]];
    detailViewController.url = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"website"]];
    detailViewController.phone = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"international_phone_number"]];
    detailViewController.adress = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"formatted_address"]];
    detailViewController.src = mapUrl;
    // NSLog(@"%@", _placeList[indexPath.row]);
    // NSLog(@"%@", mapUrl);
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *visibleCells = [self.tableView visibleCells];
    for (ParallaxCell *cell in visibleCells) {
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}


@end
