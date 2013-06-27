//
//  ProfileViewer.m
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "ProfileViewer.h"

#define kIsFriendList 0
#define kIsProfile 1
#define kIsInvalid 2

@interface ProfileViewer ()

@end

@implementation ProfileViewer

#pragma mark - Init view

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUsername:(NSString*)theFancyUsername
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Friends";
        
        // override user agent of browser
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3", @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        
        // set up state
        
        _theFancyUsername = theFancyUsername;
        _web = [[UIWebView alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // appearance of navigation bar
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"UINavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      cDarkColor,
      UITextAttributeTextColor,
      [UIColor colorWithRed:255. green:255. blue:255. alpha:1.],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:sHeaderFont size:sHeaderSize],
      UITextAttributeFont,
      nil]];
    
    // prepare navigation bar
    
    UIButton *btn_finishedAddingFriends = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_finishedAddingFriends setImage:[UIImage imageNamed:@"UIBarItem-cancel"] forState:UIControlStateNormal];
    [btn_finishedAddingFriends setFrame:CGRectMake(0, 0, 38, 28)];
    [btn_finishedAddingFriends addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn_finishedAddingFriends];
    [self.navigationItem setRightBarButtonItem:rightBarBtn];
    
    UIButton *btn_backToLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_backToLogin setImage:[UIImage imageNamed:@"UIBarItem-back"] forState:UIControlStateNormal];
    [btn_backToLogin setFrame:CGRectMake(0, 0, 38, 28)];
    [btn_backToLogin addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn_backToLogin];
    [self.navigationItem setLeftBarButtonItem:leftBarBtn];
    
    // prepare web view
    
    [_web setDelegate:self];
    [_web setFrame:self.view.bounds];
    [self.view addSubview:_web];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://m.fancy.com/%@/following", _theFancyUsername] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    
    [_web loadRequest:request];
    
    ALog(@"");
    
}

- (void)finish
{
    
    [_delegate selectedRSS:@""];
    
}

#pragma mark - Jumping over login

- (void)didTapBackButton:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = request.URL.description;
    
    if ([self typeOfURL:url] == kIsFriendList) {
        
        ALog(@"%@", url);
        
        // prepare activity indicator
        
        activityIndicator = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        
        [activityIndicator setLabelText:@"Loading..."];
        [activityIndicator setMode:MBProgressHUDModeIndeterminate];
        [activityIndicator setAnimationType:MBProgressHUDAnimationZoom];
        
        [self.navigationController.view addSubview:activityIndicator];
        
        [activityIndicator show:YES];
        
        ALog(@"load profile");
        
        return YES;
        
    } else {
        
        if ([self typeOfURL:url] == kIsProfile) {
            
            ack = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            
            [ack setLabelText:@"Added!"];
            [ack setMode:MBProgressHUDModeCustomView];
            [ack setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIBarItem-check-white"]]];
            [ack setAnimationType:MBProgressHUDAnimationZoom];
            
            [self.navigationController.view addSubview:ack];
            
            [ack show:YES];
            [ack hide:YES afterDelay:0.5];
            
            ALog(@"%@", url);
            
            NSString *username = [[url componentsSeparatedByString:@"/"] lastObject];
            NSString *rssURL = [NSString stringWithFormat:@"%@%@", gRSSurlPrefix, username];
            
            [_delegate selectedRSS:rssURL];
            
        }
        
        return NO;
        
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    ALog(@"");
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    ALog(@"%@", [error description]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    
}

- (int)typeOfURL:(NSString*)url
{
    
    NSArray *urlComponents = [url componentsSeparatedByString:@"/"];
    NSString *lastComponent = [urlComponents lastObject];
    
    // Friendlist url
    if ([lastComponent isEqualToString:@"following"]) return kIsFriendList;
    
    // Invalid urls
    if ([lastComponent rangeOfString:@"signup"].location != NSNotFound) return kIsInvalid;
    if ([urlComponents containsObject:@"login"]) return kIsInvalid;
    if ([urlComponents containsObject:_theFancyUsername]) return kIsInvalid;
    if ([urlComponents containsObject:@"things"]) return kIsInvalid;

    return kIsProfile;
    
}

#pragma mark - Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
