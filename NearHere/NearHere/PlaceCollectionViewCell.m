//
//  PlaceCollectionViewCell.m
//  NearHere
//
//  Created by KenichiSaito on 10/18/14.
//  Copyright (c) 2014 KenichiSaito. All rights reserved.
//

#import "PlaceCollectionViewCell.h"

@interface PlaceCollectionViewCell()

@property (nonatomic, strong, readwrite) UIImageView *MJImageView;

@end

@implementation PlaceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setupImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setupImageView];
    return self;
}


#pragma mark - Setup Method
- (void)setupImageView
{
    self.clipsToBounds = YES;
    
    // self.MJImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, IMAGE_HEIGHT)];
    self.MJImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, IMAGE_HEIGHT)];
    self.MJImageView.backgroundColor = [UIColor redColor];
    self.MJImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.MJImageView.clipsToBounds = NO;
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 280, 20)]; //
    self.name.textAlignment = NSTextAlignmentCenter;
    self.name.textColor = [UIColor whiteColor];
    [self addSubview:self.MJImageView];
    [self addSubview:self.name];
}

# pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    self.MJImageView.image = image;
    
    [self setImageOffset:self.imageOffset];
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    _imageOffset = imageOffset;
    
    CGRect frame = self.MJImageView.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset.x, _imageOffset.y);
    self.MJImageView.frame = offsetFrame;
}

@end