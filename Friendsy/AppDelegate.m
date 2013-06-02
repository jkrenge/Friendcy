//
//  AppDelegate.m
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "AppDelegate.h"

#import "Feed.h"
#import "Menu.h"

#import "UIViewController+HCPushBackAnimation.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    Feed *feed = [[Feed alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *feedContainer = [[UINavigationController alloc] initWithRootViewController:feed];
    
    Menu *menu = [[Menu alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *menuContainer = [[UINavigationController alloc] initWithRootViewController:menu];
    
    [menu setDelegate:feed];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:feedContainer rightDrawerViewController:menuContainer];
    
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [self.drawerController setDrawerVisualStateBlock:[MMDrawerVisualState slideAndScaleVisualStateBlock]];
    [self.drawerController setMaximumRightDrawerWidth:240];
    
    [self.window setRootViewController:self.drawerController];
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window makeKeyAndVisible];
    
    // register for notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleDrawer) name:nToggleDrawer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalCalled) name:nModalCall object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalDismissed) name:nModalDismiss object:nil];
    
    // Style
    
    [self styleUINavigationBar];
    [self styleUIToolbar];
    
    return YES;
}

#pragma mark - Global notifications

- (void)toggleDrawer
{
    
    if (self.drawerController.openSide == MMDrawerSideNone) {
        
        [self.drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
        
    } else {
        
        [self.drawerController closeDrawerAnimated:YES completion:nil];
        
    }
    
}

- (void)modalCalled
{
    
    [self.drawerController animationPushBackScaleDown];
    
}

- (void)modalDismissed
{
    
    [self.drawerController animationPopFrontScaleUp];
    
}

#pragma mark - Global styling

- (void)styleUINavigationBar
{
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
}

- (void)styleUIToolbar
{
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"UIToolbar"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
}

#pragma mark - Application delegates

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
