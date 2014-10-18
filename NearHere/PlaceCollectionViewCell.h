//
//  PlaceCollectionViewCell.h
//  NearHere
//
//  Created by KenichiSaito on 10/18/14.
//  Copyright (c) 2014 KenichiSaito. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IMAGE_HEIGHT 200
#define IMAGE_OFFSET_SPEED 25

@interface PlaceCollectionViewCell : UICollectionViewCell

/*
 
 image used in the cell which will be having the parallax effect
 
 */
@property (nonatomic, strong, readwrite) UIImage *image;

/*
 Image will always animate according to the imageOffset provided. Higher the value means higher offset for the image
 */
@property (nonatomic, assign, readwrite) CGPoint imageOffset;

@property (nonatomic, strong, readwrite) UILabel * name;

@end
