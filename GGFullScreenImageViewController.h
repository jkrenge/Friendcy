//
//  GGFullscreenImageViewController.h
//  TFM
//
//  Created by John Wu on 6/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Defines.h"

typedef NS_ENUM(NSUInteger, GGOrientation) {
    GGOrientationPortrait = 0,
    GGOrientationLandscapeLeft = 1,
    GGOrientationPortraitUpsideDown = 2,
    GGOrientationLandscapeRight = 3
};

@interface GGFullscreenImageViewController : UIViewController
{
    
    CGRect JKstartFrame;
    
    NSValue *internalStartPoint;
    NSValue *internalStartRect;
    
}

@property (nonatomic, retain) UIImageView *liftedImageView;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

- (void)setJKstartFrame:(CGRect)frame;

@end
