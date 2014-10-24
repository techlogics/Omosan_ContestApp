//
//  ViewController.m
//  NearHere
//
//  Created by KenichiSaito on 10/18/14.
//  Copyright (c) 2014 KenichiSaito. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "PlaceCollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView * placeCollectionView;
@property (nonatomic, strong) NSMutableArray * images;
@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, copy)   NSArray * placeList;
@property (nonatomic) dispatch_queue_t q_global;
@property (nonatomic) dispatch_queue_t q_main;
@property UIRefreshControl * refresh;

@end


@implementation ViewController

const NSString * API_URL_FOR_PLACE;
const NSString * API_URL_FOR_PHOTO;
const NSString * API_URL_FOR_DETAIL;
const NSString * API_URL_FOR_MAP;
const NSString * API_KEY;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    API_URL_FOR_PLACE = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    API_URL_FOR_PHOTO = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&maxheight=500";
    API_URL_FOR_DETAIL = @"https://maps.googleapis.com/maps/api/place/details/json?";
    API_URL_FOR_MAP = @"https://www.google.com/maps/embed/v1/place?";
    API_KEY = @"AIzaSyCdOeV8oBeI3DK61dA95mJ4OcqqAfeRXIY";

    _q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _q_main = dispatch_get_main_queue();
    
    _placeCollectionView.delegate = self;
    _placeCollectionView.dataSource = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;

    _placeCollectionView.alwaysBounceVertical = YES;
    
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self
                 action:@selector(refreshAction:)
       forControlEvents:UIControlEventValueChanged];
    [_placeCollectionView addSubview:_refresh];

    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        // 位置情報測位の許可を求めるメッセージを表示する
        [_locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
    } else { // iOS7以前
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaceCell" forIndexPath:indexPath];
    //set offset accordingly
    CGFloat yOffset = ((self.placeCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    cell.name.text = @"Loading";
    cell.image = nil;
    dispatch_async(_q_global, ^{
        NSString * photoUrl = [NSString stringWithFormat:@"%@&photoreference=%@&sensor=true&key=%@", API_URL_FOR_PHOTO, [_placeList[indexPath.row][@"photos"] valueForKey:@"photo_reference"][0], API_KEY];
        NSData * photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        dispatch_async(_q_main, ^{
            UIImage * image = [[UIImage alloc] initWithData:photoData];
            cell.image = image;
            cell.name.text = [NSString stringWithFormat:@"%@", _placeList[indexPath.row][@"name"]];
            UIApplication * application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
        });
    });
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * detailUrl = [NSString stringWithFormat:@"%@reference=%@&sensor=true&key=%@", API_URL_FOR_DETAIL, _placeList[indexPath.row][@"reference"], API_KEY];
    NSURLRequest * detailRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:detailUrl]];
    NSData * detailJson = [NSURLConnection sendSynchronousRequest:detailRequest returningResponse:nil error:nil];
    NSError * error=nil;
    NSArray * detailArray = [NSJSONSerialization JSONObjectWithData:detailJson options:NSJSONReadingAllowFragments error:&error];
    NSString * inputString = [NSString stringWithFormat:@"%@", _placeList[indexPath.row][@"name"]];
    CFStringRef originalString = (__bridge CFStringRef)inputString;
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
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

// 位置情報が許可されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
    }
}

// 位置情報が更新すると呼ばれる
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * newLocation = [locations lastObject];
    [self getPlaceListWith:newLocation.coordinate.latitude and:newLocation.coordinate.longitude];
    // 位置測位を終了する
    [_locationManager stopUpdatingLocation];
}

// API接続
- (void)getPlaceListWith:(double)latitude and:(double)longtitude
{
    UIApplication * application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    // &types=XXX|YYY|ZZZ
    
    dispatch_async(_q_global, ^{

        NSString * url = [NSString stringWithFormat:@"%@?location=%f,%f&radius=500&&sensor=true&key=%@", API_URL_FOR_PLACE, latitude, longtitude, API_KEY];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSError *error=nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
        // NSLog(@"%@", [array valueForKey:@"status"]);
        // NSLog(@"%@", [self getTypes]);
        NSLog(@"%@", url);
        if ([[array valueForKey:@"status"] isEqualToString:@"OK"]) {
            _placeList = [array valueForKey:@"results"];
            dispatch_async(_q_main, ^{
                [_placeCollectionView reloadData];
            });
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Over Query Limit.Please Try Again Tomorrow" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.view addSubview:alert];
        }
        dispatch_async(_q_main, ^{
            UIApplication * application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO; // インジケータOFF
            [_placeCollectionView reloadData];
            [_refresh endRefreshing];
        });
    });
    
}

//- (NSString *)getTypes
//{
//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"types" ofType:@"json"];
//    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
//    NSData * data = [fileHandle readDataToEndOfFile];
//    NSDictionary * typesKey = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSString * typeString = [[NSString alloc] init];
//
//    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dictionary = [settings dictionaryRepresentation];
//    for (int i = 0; i < dictionary.count; i++) {
//        if ([settings objectForKey:dictionary.allKeys[i]] == [typesKey valueForKey:typesKey.allKeys[i]]) {
//            [typeString stringByAppendingString:[typesKey valueForKey:typesKey.allKeys[i]]];
//        }
//    }
//    return typeString;
//}

- (void)refreshAction:(id)sender
{
    [sender beginRefreshing];
    [_locationManager startUpdatingLocation];
}


#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for(PlaceCollectionViewCell * view in _placeCollectionView.visibleCells) {
        CGFloat yOffset = ((_placeCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
