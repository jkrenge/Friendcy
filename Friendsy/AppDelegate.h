//
//  AppDelegate.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MMDrawerController *drawerController;

@end
