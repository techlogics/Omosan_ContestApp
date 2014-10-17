//
//  PlaceCollectionViewCell.h
//  NearHere
//
//  Created by Kenichi Saito on 10/17/14.
//  Copyright (c) 2014 Adcras. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_HEIGHT 200
#define IMAGE_OFFSET_SPEED 25

@interface PlaceCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readwrite) UIImage * image;
@property (nonatomic, assign, readwrite) CGPoint * imageOffset;

@end
