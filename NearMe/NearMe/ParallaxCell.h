//
//  ParallaxCell.h
//  NearMe
//
//  Created by KenichiSaito on 10/26/14.
//  Copyright (c) 2014 TechLogics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParallaxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *parallaxImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
