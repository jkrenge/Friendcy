//
//  FriendAdder.m
//  Friendcy
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
        NSString *theFancyUsername = [defaults stringForKey:UDUsername];
        
        Login *login = [[Login alloc] initWithNibName:@"Login" bundle:nil];
        [login setDelegate:self];
        
        navController = [[UINavigationController alloc] initWithRootViewController:login];

        if (theFancyUsername == nil || [theFancyUsername isEqualToString:@""]) {
            
            // empty
            
        } else {
            
            ProfileViewer *profileViewer = [[ProfileViewer alloc] initWithNibName:nil bundle:nil andUsername:theFancyUsername];
            [profileViewer setDelegate:self];
            
            [navController pushViewController:profileViewer animated:NO];
            
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
    
    if ([theFancyUsername isEqualToString:@""]) {
        
        [_delegate finishedAddingFriends];
        
    } else {
        
        // prepare the next screen
        
        ProfileViewer *profileViewer = [[ProfileViewer alloc] initWithNibName:nil bundle:nil andUsername:theFancyUsername];
        [profileViewer setDelegate:self];
        
        // present next screen
        
        [navController pushViewController:profileViewer animated:YES];
        
    }
    
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
