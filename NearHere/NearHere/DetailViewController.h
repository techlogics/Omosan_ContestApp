//
//  DetailViewController.h
//  NearHere
//
//  Created by KenichiSaito on 10/20/14.
//  Copyright (c) 2014 KenichiSaito. All rights reserved.
//

#import "ViewController.h"

@interface DetailViewController : ViewController

@property (weak, nonatomic) IBOutlet UIWebView *mapWebView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@property NSString * name;
@property NSString * adress;
@property NSString * phone;
@property NSString * url;
@property NSString * src;

@end
