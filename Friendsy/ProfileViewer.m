//
//  ProfileViewer.m
//  Friendsy
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
        
        // set up state
        
        _theFancyUsername = theFancyUsername;
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://m.thefancy.com/%@/following#continue", theFancyUsername] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        _web = [[UIWebView alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prepare navigation bar
    
    UIBarButtonItem *btn_finishedAddingFriends = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
    [self.navigationItem setRightBarButtonItem:btn_finishedAddingFriends];
    
    // prepare web view
    
    [_web setDelegate:self];
    [_web setFrame:self.view.bounds];
    [self.view addSubview:_web];
    
    [_web loadRequest:_request];
    
    ALog(@"");
    
}

- (void)finish
{
    
    [_delegate selectedRSS:@""];
    
}

#pragma mark - Jumping over login

- (void)showManuallyGoBackToLoginButton
{
    
    ALog(@"");
    
    // TODO: make button an arrow
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(manuallyGoBackToLogin)];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    
}

- (void)manuallyGoBackToLogin
{
    
    ALog(@"");
    
    [_delegate manuallyGoBackToLogin];
    
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = request.URL.description;
    
    if ([self typeOfURL:url] == kIsFriendList) {
        
        // TODO: show activity indicator
        
        return YES;
        
    } else {
        
        if ([self typeOfURL:url] == kIsProfile) {
            
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
    
    // TODO: hide activity indicator
    
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
    if ([lastComponent isEqualToString:@"following#continue"]) return kIsFriendList;
    
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
