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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _placeCollectionView.delegate = self;
    _placeCollectionView.dataSource = self;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        
        // 位置情報測位の許可を求めるメッセージを表示する
        //	[_locationManager requestAlwaysAuthorization]; // 常に許可
        [_locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
        
    } else { // iOS7以前
        
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
        
    }
    
    NSUInteger index;
    for (index = 0; index < 14; ++index) {
        // Setup image name
        NSString *name = [NSString stringWithFormat:@"image%03ld.jpg", (unsigned long)index];
        if(!self.images)
            self.images = [NSMutableArray arrayWithCapacity:0];
        [self.images addObject:name];
    }
    [_placeCollectionView reloadData];
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlaceCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    //get image name and assign
    NSString* imageName = [self.images objectAtIndex:indexPath.item];
    cell.image = [UIImage imageNamed:imageName];
    
    //set offset accordingly
    CGFloat yOffset = ((self.placeCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    
    cell.name.text = [NSString stringWithFormat:@"%@", _placeList[indexPath.row][@"name"]];
    
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
    NSString * url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&sensor=true&key=AIzaSyCrf9FYI26DuWw5MFR1t82NHIU30Hod6rM", latitude, longtitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error=nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
    _placeList = [array valueForKeyPath:@"results"];
    NSLog(@"%@", _placeList);
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(PlaceCollectionViewCell *view in self.placeCollectionView.visibleCells) {
        CGFloat yOffset = ((self.placeCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}

- (void)getPlacePhotoWith:(NSString *)photoReferance
{
    NSString * url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=320&maxheight=160&photoreference=%@&sensor=true&key=AIzaSyCrf9FYI26DuWw5MFR1t82NHIU30Hod6rM", photoReferance];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    // _placeImage = (UIImage *)data;
    // NSLog(@"%@", _placeImage);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
