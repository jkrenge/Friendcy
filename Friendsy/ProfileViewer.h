//
//  ProfileViewer.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Defines.h"

#import "MBProgressHUD.h"

@protocol ProfileViewerDelegate <NSObject>
- (void)selectedRSS:(NSString*)rss;
@end

@interface ProfileViewer : UIViewController <UIWebViewDelegate>
{
    
    NSString *_theFancyUsername;
    UIWebView *_web;
    
    MBProgressHUD *activityIndicator;
    MBProgressHUD *ack;
    
}

@property (nonatomic, assign) id<ProfileViewerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUsername:(NSString*)theFancyUsername;

@end
