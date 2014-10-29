//
//  ViewController.m
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import "ViewController.h"
#import "PlaceViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PlaceViewController *placeViewContoller = (PlaceViewController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"art"]) {
        placeViewContoller.types = @"museum";
    } else if ([segue.identifier isEqualToString:@"restaurant"]) {
        placeViewContoller.types = @"restaurant";
    } else if ([segue.identifier isEqualToString:@"amusement"]) {
        placeViewContoller.types = @"amusement_park";
    } else if ([segue.identifier isEqualToString:@"health"]) {
        placeViewContoller.types = @"health";
    } else if ([segue.identifier isEqualToString:@"transit"]) {
        placeViewContoller.types = @"subway_station";
    } else if ([segue.identifier isEqualToString:@"campground"]) {
        placeViewContoller.types = @"campground";
    } else if ([segue.identifier isEqualToString:@"airport"]) {
        placeViewContoller.types = @"airport";
    } else if ([segue.identifier isEqualToString:@"beauty_salon"]) {
        placeViewContoller.types = @"beauty_salon";
    } else if ([segue.identifier isEqualToString:@"cafe"]) {
        placeViewContoller.types = @"cafe";
    } else if ([segue.identifier isEqualToString:@"shopping_mall"]) {
        placeViewContoller.types = @"shopping_mall";
    } else if ([segue.identifier isEqualToString:@"gas_station"]) {
        placeViewContoller.types = @"gas_station";
    } else if ([segue.identifier isEqualToString:@"establishment"]) {
        placeViewContoller.types = @"establishment";
    } else if ([segue.identifier isEqualToString:@"school"]) {
        placeViewContoller.types = @"school";
    } else if ([segue.identifier isEqualToString:@"hospital"]) {
        placeViewContoller.types = @"hospital";
    } else if ([segue.identifier isEqualToString:@"movie_theater"]) {
        placeViewContoller.types = @"movie_theater";
    } else if ([segue.identifier isEqualToString:@"bar"]) {
        placeViewContoller.types = @"bar";
    } else if ([segue.identifier isEqualToString:@"parking"]) {
        placeViewContoller.types = @"parking";
    } else if ([segue.identifier isEqualToString:@"lodging"]) {
        placeViewContoller.types = @"lodging";
    }
}

@end
