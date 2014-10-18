//
//  ViewController.m
//  NearHere
//
//  Created by KenichiSaito on 10/18/14.
//  Copyright (c) 2014 KenichiSaito. All rights reserved.
//

#import "ViewController.h"
#import "PlaceCollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *placeCollectionView;
@property (nonatomic, strong) NSMutableArray * images;
@property (nonatomic, retain) CLLocationManager * locationManager;
@property NSArray * placeList;
@property NSMutableDictionary * placeImageReference;
@property dispatch_queue_t q_global; // = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
@property dispatch_queue_t q_main; // = dispatch_get_main_queue();

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _placeCollectionView.delegate = self;
    _placeCollectionView.dataSource = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _q_main = dispatch_get_main_queue();
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        
        // 位置情報測位の許可を求めるメッセージを表示する
        //	[_locationManager requestAlwaysAuthorization]; // 常に許可
        [_locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
        
    } else { // iOS7以前
        
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
        
    }
    
    [_placeCollectionView reloadData];
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlaceCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaceCell" forIndexPath:indexPath];

    // cell.image = _placeImage;
    dispatch_async(_q_main, ^{
        NSString * photoUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&maxheight=1000&photoreference=%@&sensor=true&key=AIzaSyCrf9FYI26DuWw5MFR1t82NHIU30Hod6rM", _placeImageReference[[NSString stringWithFormat:@"%ld", indexPath.row]]];
        NSData * photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        UIImage * image = [[UIImage alloc] initWithData:photoData];
        cell.name.text = [NSString stringWithFormat:@"%@", _placeList[indexPath.row][@"name"]];
        cell.image = image;
    });
    
    //set offset accordingly
    CGFloat yOffset = ((self.placeCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    
    
    
    return cell;
}

// 位置情報が許可されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
    }
}

// 位置情報が更新すると呼ばれる
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"%f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [self getPlaceListWith:newLocation.coordinate.latitude and:newLocation.coordinate.longitude];
    
    // 位置測位を終了する
    [_locationManager stopUpdatingLocation];
}

// API接続
- (void)getPlaceListWith:(double)latitude and:(double)longtitude
{
    UIApplication * application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    
    
    dispatch_async(_q_global, ^{
        
        NSString * url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&sensor=true&key=AIzaSyCrf9FYI26DuWw5MFR1t82NHIU30Hod6rM", latitude, longtitude];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSError *error=nil;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
        
        if ([[array valueForKey:@"status"] isEqualToString:@"OK"]) {
            _placeList = [array valueForKeyPath:@"results"];
        } else if ([[array valueForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Over Query Limit.Please Try Again Tomorrow" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.view addSubview:alert];
        }
        
        for (int i = 0; i < 20; i++) {
            if ([_placeList[i] containsObject:@"photos"]) {
                // NSString * photoUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&maxheight=1000&photoreference=%@&sensor=true&key=AIzaSyCrf9FYI26DuWw5MFR1t82NHIU30Hod6rM", _placeList[i][@"photos"][@"photo_reference"]];
                [_placeImageReference setValue:_placeList[i][@"photos"][@"photo_reference"] forKey:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
        dispatch_async(_q_main, ^{
            [self.placeCollectionView reloadData];
        });
    });
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(PlaceCollectionViewCell *view in self.placeCollectionView.visibleCells) {
        CGFloat yOffset = ((self.placeCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
