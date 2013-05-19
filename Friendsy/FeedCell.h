//
//  FeedCell.h
//  Friendcy
//
//  Created by Julian Krenge on 28.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

#import "GGFullScreenImageViewController.h"

#import "FeedItem.h"

@interface FeedCell : UITableViewCell
{
    
    UIView *topDrawer;
    UIView *bottomDrawer;
    
    UIImageView *image;
    UILabel *title;
    UILabel *date;
    UILabel *author;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setItemImage:(NSString*)imageURL;
- (void)setItemTitle:(NSString*)_title;
- (void)setItemDate:(NSString*)_date;
- (void)setItemAuthor:(NSString*)_author;

@end
