//
//  ViewController.m
//  NearHere
//
//  Created by Kenichi Saito on 10/17/14.
//  Copyright (c) 2014 Adcras. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _placeListCollection.delegate = self;
    _placeListCollection.dataSource = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaceCell" forIndexPath:indexPath];
    return cell;
}
@end
