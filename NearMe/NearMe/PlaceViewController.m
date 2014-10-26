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


@interface PlaceViewController () <UIScrollViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

// @property (nonatomic, strong) NSArray *tableItems;
@property (nonatomic, copy) NSArray *placeList;
@property UIRefreshControl * refresh;


@end

@implementation PlaceViewController

const NSString * API_URL_FOR_PLACE = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
const NSString * API_URL_FOR_PHOTO = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=640&maxheight=402";
const NSString * API_URL_FOR_DETAIL = @"https://maps.googleapis.com/maps/api/place/details/json?";
const NSString * API_URL_FOR_MAP = @"https://www.google.com/maps/embed/v1/place?";
const NSString * API_KEY = @"AIzaSyCdOeV8oBeI3DK61dA95mJ4OcqqAfeRXIY";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", self.types);
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    

    
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self
                 action:@selector(refreshAction:)
       forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refresh];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        // 位置情報測位の許可を求めるメッセージを表示する
        [self.locationManager requestWhenInUseAuthorization];
    } else { // iOS7以前
        // 位置測位スタート
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)getPlaceListWith:(double)latitude and:(double)longtitude
{
    UIApplication * application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    // &types=XXX|YYY|ZZZ

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString * placeUrl = [NSString stringWithFormat:@"%@?location=%f,%f&radius=1000&types=%@&sensor=true&key=%@", API_URL_FOR_PLACE, latitude, longtitude, self.types, API_KEY];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:placeUrl]];
        NSData *placeData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSError *error=nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:placeData options:NSJSONReadingAllowFragments error:&error];
        // NSLog(@"%@", [array valueForKey:@"status"]);
        // NSLog(@"%@", [self getTypes]);
        NSLog(@"%@", placeUrl);
        if ([[array valueForKey:@"status"] isEqualToString:@"OK"]) {
            self.placeList = [array valueForKey:@"results"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Over Query Limit.Please Try Again Tomorrow" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.view addSubview:alert];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication * application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO; // インジケータOFF
            [self.tableView reloadData];
            [self.refresh endRefreshing];
        });
    });
    
}

// 位置情報が許可されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // 位置測位スタート
        [self.locationManager startUpdatingLocation];
    }
}

// 位置情報が更新すると呼ばれる
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * newLocation = [locations lastObject];
    [self getPlaceListWith:newLocation.coordinate.latitude and:newLocation.coordinate.longitude];
    // 位置測位を終了する
    [self.locationManager stopUpdatingLocation];
}

- (void)refreshAction:(id)sender
{
    [sender beginRefreshing];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"parallaxCell";
    ParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.parallaxImage.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString * photoUrl = [NSString stringWithFormat:@"%@&photoreference=%@&sensor=true&key=%@", API_URL_FOR_PHOTO, [self.placeList[indexPath.row][@"photos"] valueForKey:@"photo_reference"][0], API_KEY];
        NSData * photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [[UIImage alloc] initWithData:photoData];
            cell.parallaxImage.image = image;
            if (!cell.parallaxImage.image) {
                cell.parallaxImage.image = [UIImage imageNamed:@"noPhoto"];
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"%@", self.placeList[indexPath.row][@"name"]];
            UIApplication * application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
        });
    });

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * detailUrl = [NSString stringWithFormat:@"%@reference=%@&sensor=true&key=%@", API_URL_FOR_DETAIL, self.placeList[indexPath.row][@"reference"], API_KEY];
    NSURLRequest * detailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:detailUrl]];
    NSData * detailJson = [NSURLConnection sendSynchronousRequest:detailRequest returningResponse:nil error:nil];
    NSError * error=nil;
    NSArray * detailArray = [NSJSONSerialization JSONObjectWithData:detailJson options:NSJSONReadingAllowFragments error:&error];
    NSString * inputString = [NSString stringWithFormat:@"%@", self.placeList[indexPath.row][@"name"]];
    CFStringRef originalString = (__bridge CFStringRef)inputString;
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        originalString,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);
    NSString * mapUrl = [NSString stringWithFormat:@"%@key=%@&q=%@", API_URL_FOR_MAP, API_KEY, encodedString];
    DetailViewController * detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.name = [NSString stringWithFormat:@"%@", _placeList[indexPath.row][@"name"]];
    detailViewController.url = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"website"]];
    detailViewController.phone = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"international_phone_number"]];
    detailViewController.adress = [NSString stringWithFormat:@"%@", [[detailArray valueForKey:@"result"] valueForKey:@"formatted_address"]];
    detailViewController.src = mapUrl;
    // NSLog(@"%@", _placeList[indexPath.row]);
    // NSLog(@"%@", mapUrl);
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (ParallaxCell *cell in visibleCells) {
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}


@end
