//
//  DetailViewController.m
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.title = @"Detail";
    _nameLabel.text = _name;
    _adressLabel.text = _adress;
    _urlLabel.text = _url;
    _phoneLabel.text = _phone;
    
    _mapWebView.scrollView.scrollEnabled = NO;
    NSString * iframe = [NSString stringWithFormat:@"<html><head><title></title><style>body,html,iframe{margin:0;padding:0;}</style></head><body><iframe width=\"266\" height=\"266\" frameborder=\"0\" style=\"border:0\" src=\"%@\" ></iframe></body></html>", _src];
    [_mapWebView loadHTMLString:iframe baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
