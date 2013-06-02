//
//  FeedCell.m
//  Friendcy
//
//  Created by Julian Krenge on 28.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "FeedCell.h"
#import "Defines.h"
#import "AppDelegate.h"

#import "BButton.h"

#pragma mark - Defines

#define kSpaceAboveImage 30
#define kInfoOffset 10
#define kBorderOffset 4
#define kBorderWidth 6
#define kHeightOfTitle 34
#define kWidthOfDate 210

#define kButtonHeight 40
#define kButtonSpace 10

#define kHidingOffset -200
#define kHiddenOpacity 0.1f
#define kAnimDuration 0.25f

#define kKeyOfRevealAnimation @"drawerRevealAnimation"
#define kKeyOfHideAnimation @"drawerHideAnimation"

#pragma mark - Init

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _bottomDrawerIsRevealed = NO;
        
        // prepare drawer
        
        topDrawer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, gFeedCellHeight)];
        [self loadTopDrawer];
        [self.viewForBaselineLayout addSubview:topDrawer];
        
        [self loadCellInformation];
        
        // add interactivity
        
//        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullscreenImage)];
//        [image addGestureRecognizer:tapRec];
        
    }
    return self;
}

#pragma mark - Drawer interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Prepare bottom drawer
    
    if (bottomDrawer == nil) {
        [self loadBottomDrawer];
    }
    
    // block interaction with table itself
    
    [_delegate didBeginInteractionWithCell];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self];
    CGPoint previousLocation = [aTouch previousLocationInView:self];
    topDrawer.frame = CGRectOffset(topDrawer.frame, location.x-previousLocation.x, 0);

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_delegate didEndInteractionWithCell];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    [_delegate didEndInteractionWithCell];
    
    if (topDrawer.frame.origin.x < -50) [self revealSubDrawer];
    else [self hideSubDrawer];
    
}

- (void)revealSubDrawer
{
    
    if (_bottomDrawerIsRevealed) return;
        
    _bottomDrawerIsRevealed = YES;

    // Prepare bottom drawer
    
    if (bottomDrawer == nil) {
        [self loadBottomDrawer];
    }
    
    // Set up fade in effect
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeInAnimation setToValue:[NSNumber numberWithFloat:1]];
    
    // Group animations
    
    CAAnimationGroup *groupIn = [CAAnimationGroup animation];
    groupIn.fillMode = kCAFillModeForwards;
    groupIn.removedOnCompletion = NO;
    [groupIn setAnimations:[NSArray arrayWithObjects:fadeInAnimation, nil]];
    groupIn.duration = kAnimDuration;
    groupIn.delegate = self;
    
    // Set up path movement
    
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:CGPointMake(kHidingOffset/2, gFeedCellHeight/2)]];

    // Group animations
    
    CAAnimationGroup *groupOut = [CAAnimationGroup animation];
    groupOut.fillMode = kCAFillModeForwards;
    groupOut.removedOnCompletion = NO;
    [groupOut setAnimations:[NSArray arrayWithObjects:moveOutAnimation, nil]];
    groupOut.duration = kAnimDuration;
    groupOut.delegate = self;
    
    // Add animations
    
    [groupIn setValue:bottomDrawer forKey:@"viewBeingAnimated"];
    [bottomDrawer.layer addAnimation:groupIn forKey:kKeyOfRevealAnimation];
    
    [groupOut setValue:topDrawer forKey:@"viewBeingAnimated"];
    [topDrawer.layer addAnimation:groupOut forKey:kKeyOfRevealAnimation];
    
}

- (void)hideSubDrawer
{
        
    _bottomDrawerIsRevealed = NO;

    // Set up fade out effect
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeInAnimation setToValue:[NSNumber numberWithFloat:kHiddenOpacity]];
    
    // Group animations
    
    CAAnimationGroup *groupIn = [CAAnimationGroup animation];
    groupIn.fillMode = kCAFillModeForwards;
    groupIn.removedOnCompletion = NO;
    [groupIn setAnimations:[NSArray arrayWithObjects:fadeInAnimation, nil]];
    groupIn.duration = kAnimDuration;
    groupIn.delegate = self;
    
    // Set up path movement
    
    CABasicAnimation *moveOutAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveOutAnimation setToValue:[NSValue valueWithCGPoint:CGPointMake(320/2, gFeedCellHeight/2)]];
    
    // Group animations
    
    CAAnimationGroup *groupOut = [CAAnimationGroup animation];
    groupOut.fillMode = kCAFillModeForwards;
    groupOut.removedOnCompletion = NO;
    [groupOut setAnimations:[NSArray arrayWithObjects:moveOutAnimation, nil]];
    groupOut.duration = kAnimDuration;
    groupOut.delegate = self;
    
    // Add animations
    
    [groupIn setValue:bottomDrawer forKey:@"viewBeingAnimated"];
    [bottomDrawer.layer addAnimation:groupIn forKey:kKeyOfHideAnimation];
    
    [groupOut setValue:topDrawer forKey:@"viewBeingAnimated"];
    [topDrawer.layer addAnimation:groupOut forKey:kKeyOfHideAnimation];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    if (flag && anim == [topDrawer.layer animationForKey:kKeyOfRevealAnimation]) {
        
        [topDrawer setFrame:CGRectMake(kHidingOffset, 0, 320, gFeedCellHeight)];
        
    } else if (flag && anim == [topDrawer.layer animationForKey:kKeyOfHideAnimation]) {
        
        [topDrawer setFrame:CGRectMake(0, 0, 320, gFeedCellHeight)];
        
    }
    
}

#pragma mark - Other interactivity

- (void)showFullscreenImage
{
    
    // calculate origin frame
    
    CGRect frame = image.frame;
    frame.origin.y = [self calculateYforImageOnly:YES];
    
    // prepare image
    
    [image setContentMode:UIViewContentModeScaleAspectFill];
    
    // show fullscreen
    
    GGFullscreenImageViewController *fullscreen = [[GGFullscreenImageViewController alloc] init];
    [fullscreen setJKstartFrame:frame];
    [fullscreen setLiftedImageView:image];
    
    AppDelegate* myAppDelegate = [[UIApplication sharedApplication] delegate];
    [myAppDelegate.drawerController presentViewController:fullscreen animated:YES completion:nil];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

#pragma mark - Navigation

- (void)presentDetails
{
    
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    [_delegate didSelectRowAtIndexPath:indexPath withAction:ActionKeyShowDetails];
    
}

- (void)presentSharingOptions
{
    
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    [_delegate didSelectRowAtIndexPath:indexPath withAction:ActionKeyShowSharingOptions];
    
}

#pragma mark - Attribute setters

- (void)setItemImage:(NSString*)imageURL
{
    
    [image setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:gPlaceholderImage]];
    
}

- (void)setItemTitle:(NSString*)_title { [title setText:_title]; }
- (void)setItemDate:(NSString*)_date { [date setText:_date]; }
- (void)setItemAuthor:(NSString*)_author { [author setText:_author]; }

#pragma mark - Prepare content of cell

- (void)loadCellInformation
{
    
    UIFont *authorFont = [UIFont fontWithName:@"Helvetica-Bold" size:14.];
    UIFont *dateFont = [UIFont fontWithName:@"Helvetica" size:14.];
    int imageBorder = kBorderOffset + 1 + kBorderWidth;
    
    // prepare author badge
    
    int authorOffset = 5;
    
    author = [[UILabel alloc] initWithFrame:CGRectMake(imageBorder+authorOffset, kInfoOffset+authorOffset, 320-2*imageBorder-kWidthOfDate, kSpaceAboveImage)];
    [author setShadowColor:[UIColor whiteColor]];
    [author setShadowOffset:CGSizeMake(1, 1)];
    [author setFont:authorFont];
    [author setTextColor:[UIColor darkGrayColor]];
    [author setTextAlignment:NSTextAlignmentCenter];
    [author setBackgroundColor:[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1.]];
    
    CALayer *authorBorder = [CALayer layer];
    [authorBorder setFrame:CGRectMake(author.frame.origin.x-1, author.frame.origin.y-1, author.frame.size.width+2, author.frame.size.height+2)];
    [authorBorder setBackgroundColor:[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.].CGColor];
    
    [authorBorder setShadowColor:[UIColor darkGrayColor].CGColor];
    [authorBorder setShadowOffset:CGSizeMake(0., 1.)];
    [authorBorder setShadowRadius:2.];
    [authorBorder setShadowOpacity:.4];
    
    CGRect shadowFrame2 = authorBorder.bounds;
    CGPathRef shadowPath2 = [UIBezierPath bezierPathWithRect:shadowFrame2].CGPath;
    [authorBorder setShadowPath:shadowPath2];
    
    [self.viewForBaselineLayout.layer addSublayer:authorBorder];
    [self.viewForBaselineLayout addSubview:author];
    
    // prepare date
    
    date = [[UILabel alloc] initWithFrame:CGRectMake(320-imageBorder-kWidthOfDate, kInfoOffset, kWidthOfDate, kSpaceAboveImage)];
    [date setFont:dateFont];
    [date setTextColor:[UIColor darkGrayColor]];
    [date setTextAlignment:NSTextAlignmentRight];
    [date setBackgroundColor:[UIColor clearColor]];
    
    [self.viewForBaselineLayout addSubview:date];
    
}

- (void)loadTopDrawer
{

    UIFont *titleFont = [UIFont fontWithName:@"Helvetica" size:17.];
    int imageBorder = kBorderOffset + 1 + kBorderWidth;
    
    // prepare image
    
    CALayer *darkBorder = [CALayer layer];
    [darkBorder setFrame:CGRectMake(kBorderOffset, kBorderOffset+kSpaceAboveImage, 320-2*kBorderOffset, gFeedCellHeight-kSpaceAboveImage-kBorderOffset*2)];
    [darkBorder setBackgroundColor:[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.].CGColor];
    
    CALayer *lightBorder = [CALayer layer];
    [lightBorder setFrame:CGRectMake(kBorderOffset+1, kBorderOffset+1+kSpaceAboveImage, darkBorder.frame.size.width-2, darkBorder.frame.size.height-2)];
    [lightBorder setBackgroundColor:[UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1.].CGColor];
    
    image = [[UIImageView alloc] initWithFrame:CGRectMake(imageBorder, imageBorder+kSpaceAboveImage, 320-2*imageBorder, gFeedCellHeight-kSpaceAboveImage-2*imageBorder)];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFill];
    
    [darkBorder setShadowColor:[UIColor darkGrayColor].CGColor];
    [darkBorder setShadowOffset:CGSizeMake(0., 1.)];
    [darkBorder setShadowRadius:2.];
    [darkBorder setShadowOpacity:.4];
    
    CGRect shadowFrame = darkBorder.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    [darkBorder setShadowPath:shadowPath];
    
    [topDrawer.layer addSublayer:darkBorder];
    [topDrawer.layer addSublayer:lightBorder];
    [topDrawer addSubview:image];
    
    // prepare title
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x, image.frame.origin.y+image.frame.size.height-kHeightOfTitle, image.frame.size.width, kHeightOfTitle)];
    [title setBackgroundColor:[UIColor colorWithRed:.98 green:.98 blue:.98 alpha:.6]];
    [title setShadowColor:[UIColor whiteColor]];
    [title setShadowOffset:CGSizeMake(1, 1)];
    [title setFont:titleFont];
    
    [topDrawer addSubview:title];
    
    // enable interaction
    
    [image setUserInteractionEnabled:YES];
    [topDrawer setUserInteractionEnabled:YES];
    
}

- (void)loadBottomDrawer
{
    
    int availableWidth = 320 - (320+kHidingOffset);
    
    bottomDrawer = [[UIView alloc] initWithFrame:CGRectMake(320-availableWidth-40, 0, availableWidth, gFeedCellHeight)];
    [bottomDrawer setAlpha:kHiddenOpacity];
    
    // calculate button frames
    
    int numOfButtons = 2;
    
    NSMutableArray *btnRects = [[NSMutableArray alloc] initWithCapacity:numOfButtons];
    int btnStartY = (gFeedCellHeight - (numOfButtons*kButtonHeight + (numOfButtons-1)*kButtonSpace)) / 2;
    for (int i = 0; i < numOfButtons; i++) {
        CGRect f = CGRectMake(kButtonSpace, btnStartY, availableWidth-2*kButtonSpace, kButtonHeight);
        [btnRects addObject:[NSValue valueWithCGRect:f]];
        btnStartY += (kButtonHeight + kButtonSpace);
    }
    
    // add buttons
    
    BButton *detailBtn = [[BButton alloc] initWithFrame:[[btnRects objectAtIndex:0] CGRectValue] type:BButtonTypeDefault];
    [detailBtn setTitle:@"Show details" forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(presentDetails) forControlEvents:UIControlEventTouchUpInside];
    [bottomDrawer addSubview:detailBtn];
    
    BButton *shareBtn = [[BButton alloc] initWithFrame:[[btnRects objectAtIndex:1] CGRectValue] type:BButtonTypeDefault];
    [shareBtn setTitle:@"Share this" forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(presentSharingOptions) forControlEvents:UIControlEventTouchUpInside];
    [bottomDrawer addSubview:shareBtn];
    
    // add bottom drawer to cell
    
    [self.viewForBaselineLayout insertSubview:bottomDrawer belowSubview:topDrawer];
    
    // add interactivity to bottom drawer
    
//    [bottomDrawer setUserInteractionEnabled:YES];
//    
//    UISwipeGestureRecognizer *swipeRightRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSubDrawer)];
//    [swipeRightRec setDirection:UISwipeGestureRecognizerDirectionRight];
//    [bottomDrawer addGestureRecognizer:swipeRightRec];
//    
//    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSubDrawer)];
//    [bottomDrawer addGestureRecognizer:tapRec];
    
}

#pragma mark - Helper

- (int)calculateYforImageOnly:(BOOL)onlyForImage
{
    
    CGRect frame;
    if (onlyForImage) frame = image.frame;
    else frame = topDrawer.frame;
    
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    int rowOffset = indexPath.row * gFeedCellHeight;
    int scrollOffset = ((UITableView *)self.superview).contentOffset.y;
    int result = 20. + 44. + rowOffset - scrollOffset + frame.origin.y;
    
    return result;
    
}

@end
