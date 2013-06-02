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

typedef enum {
    ActionKeyShowDetails = 0,
    ActionKeyShowSharingOptions = 1
} ActionKey;

@protocol FeedCellActionDelegate <NSObject>
- (void)didSelectRowAtIndexPath:(NSIndexPath*)indexPath withAction:(ActionKey)action;
- (void)didBeginInteractionWithCell;
- (void)didEndInteractionWithCell;
@end

@interface FeedCell : UITableViewCell
{
    
    BOOL _bottomDrawerIsRevealed;
    CGRect imageOrigin;
    
    UIView *topDrawer;
    UIView *bottomDrawer;
    
    UIImageView *image;
    UILabel *title;
    UILabel *date;
    UILabel *author;
    
}

@property (nonatomic, assign) id<FeedCellActionDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setItemImage:(NSString*)imageURL;
- (void)setItemTitle:(NSString*)_title;
- (void)setItemDate:(NSString*)_date;
- (void)setItemAuthor:(NSString*)_author;

@end
