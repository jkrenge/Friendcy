//
//  FriendAdder.m
//  Friendsy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "FriendAdder.h"

@interface FriendAdder ()

@end

@implementation FriendAdder

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // present login only if no user data is inserted yet
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *theFancyUsername = [defaults stringForKey:@"theFancyUsername"];

        if (theFancyUsername == nil || [theFancyUsername isEqualToString:@""]) {
            
            Login *login = [[Login alloc] initWithNibName:@"Login" bundle:nil];
            [login setDelegate:self];
            
            navController = [[UINavigationController alloc] initWithRootViewController:login];
            
        } else {
            
            ProfileViewer *profileViewer = [[ProfileViewer alloc] initWithNibName:nil bundle:nil andUsername:theFancyUsername];
            [profileViewer showManuallyGoBackToLoginButton];
            [profileViewer setDelegate:self];
            
            navController = [[UINavigationController alloc] initWithRootViewController:profileViewer];
            
        }
        
        // present navigation controller
    
        [navController.view setFrame:self.view.bounds];
        [self.view addSubview:navController.view];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Handle navigation

- (void)didFinishUserInput:(NSString *)theFancyUsername
{
    
    // prepare the next screen 
    
    ProfileViewer *profileViewer = [[ProfileViewer alloc] initWithNibName:nil bundle:nil andUsername:theFancyUsername];
    [profileViewer setDelegate:self];
    
    // present next screen

    [navController pushViewController:profileViewer animated:YES];
    
}

- (void)manuallyGoBackToLogin
{
    
    ALog(@"");
    
    // TODO: make it actually work
    
    Login *login = [[Login alloc] initWithNibName:@"Login" bundle:nil];
    [login setDelegate:self];
    
    NSMutableArray *vcs =  [NSMutableArray arrayWithArray:navController.navigationController.viewControllers];
    [vcs insertObject:login atIndex:0];
    [navController.navigationController setViewControllers:vcs animated:NO];
    
    [navController.navigationController popViewControllerAnimated:YES];
    
}

- (void)selectedRSS:(NSString *)rss
{
    
    if ([rss isEqualToString:@""]) {
        
        [_delegate finishedAddingFriends];
        
    } else {
        
        [_delegate addedFriendURL:rss];
        
    }
    
}

#pragma mark - Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
