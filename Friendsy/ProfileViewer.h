//
//  ProfileViewer.h
//  Friendsy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Defines.h"

@protocol ProfileViewerDelegate <NSObject>
- (void)selectedRSS:(NSString*)rss;
- (void)manuallyGoBackToLogin;
@end

@interface ProfileViewer : UIViewController <UIWebViewDelegate>
{
    
    NSString *_theFancyUsername;
    NSURLRequest *_request;
    UIWebView *_web;
    
}

@property (nonatomic, assign) id<ProfileViewerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUsername:(NSString*)theFancyUsername;
- (void)showManuallyGoBackToLoginButton;

@end
