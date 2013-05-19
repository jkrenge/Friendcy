//
//  FriendAdder.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Login.h"
#import "ProfileViewer.h"

@protocol FriendAdderDelegate <NSObject>
- (void)addedFriendURL:(NSString*)rssURL;
- (void)finishedAddingFriends;
@end


@interface FriendAdder : UIViewController <LoginDelegate, ProfileViewerDelegate>
{
    
    UINavigationController *navController;
    
}

@property (nonatomic, assign) id<FriendAdderDelegate> delegate;

@end
