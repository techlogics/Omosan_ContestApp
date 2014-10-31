//
//  PlaceViewController.h
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface PlaceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, copy) NSString *types;
@property (nonatomic, retain) NSArray *placeList;
@property UIRefreshControl * refresh;

@end
