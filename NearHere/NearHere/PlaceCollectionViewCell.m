//
//  PlaceCollectionViewCell.m
//  NearHere
//
//  Created by Kenichi Saito on 10/17/14.
//  Copyright (c) 2014 Adcras. All rights reserved.
//

#import "PlaceCollectionViewCell.h"

@interface PlaceCollectionViewCell()

@property (nonatomic, strong, readwrite) UIImageView * placeImageView;

@end

@implementation PlaceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setupImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self setupImageView];
    return self;
}


- (void)setupImageView
{
    self.clipsToBounds = YES;
    
    _placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, IMAGE_HEIGHT)];
    _placeImageView.backgroundColor = [UIColor redColor];
    _placeImageView.contentMode = UIViewContentModeScaleAspectFill;
    _placeImageView.clipsToBounds = NO;
    [self addSubview:_placeImageView];
}

- (void)setImage:(UIImage *)image
{
    _placeImageView.image = image;
    
    [self setImageOffset:self.imageOffset];
}

- (void)setImageOffset:(CGPoint *)imageOffset
{
    _imageOffset = imageOffset;
    
    CGRect frame = _placeImageView.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset->x, _imageOffset->y);
    _placeImageView.frame = offsetFrame;
}


@end
