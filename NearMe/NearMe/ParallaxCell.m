//
//  ParallaxCell.m
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import "ParallaxCell.h"

@implementation ParallaxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame) / 2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(self.parallaxImage.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) *difference;
    
    CGRect imageRect = self.parallaxImage.frame;
    imageRect.origin.y = -(difference / 2)+move;
    self.parallaxImage.frame = imageRect;
}

- (void)setImageWith:(NSString *)photoReference {
    [self.parallaxImage sd_setImageWithURL:[NSURL URLWithString:photoReference] placeholderImage:[UIImage imageNamed:@"noPhoto"]];
}
@end
