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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationItem.title = @"Detail";
    if (!self.nameLabel.text) {
        self.nameLabel.text = @"No Information.";
    }
    if (!self.adressLabel.text) {
        self.adressLabel.text = @"No Information.";
    }
    if (!self.urlLabel.text) {
        self.urlLabel.text = @"No Information.";
    }
    if (!self.phoneLabel.text) {
        self.phoneLabel.text = @"No Information.";
    }
    self.nameLabel.text = self.name;
    self.adressLabel.text = self.adress;
    self.urlLabel.text = self.url;
    self.phoneLabel.text = self.phone;
    
    self.mapWebView.scrollView.scrollEnabled = NO;
    NSString *iframe = [NSString stringWithFormat:@"<html><head><title></title><style>body,html,iframe{margin:0;padding:0;}</style></head><body><iframe width=\"309\" height=\"309\" frameborder=\"0\" style=\"border:0\" src=\"%@\" ></iframe></body></html>", self.src];
    [self.mapWebView loadHTMLString:iframe baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear {
    self.name = nil;
    self.adress = nil;
    self.url = nil;
    self.phone = nil;
    self.mapWebView = nil;
    self.mapWebView.delegate = nil;
}

@end
