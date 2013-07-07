//
//  Menu.h
//  Friendcy
//
//  Created by Julian Krenge on 02.06.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAdder.h"
#import "OptionsTable.h"

#import "WSCoachMarksView.h"

#define AlertViewTag_deleteFeed 1

@protocol MenuDelegate <NSObject>
- (void)didSelectFeed:(NSString*)feed;
@end

@interface Menu : UITableViewController <FriendAdderDelegate, OptionsDelegate>
{
    
    NSMutableArray *feeds;
    NSString *feedToBeDeleted;
    int selectedStream;
    
    
}

@property (nonatomic, assign) id<MenuDelegate> delegate;

@end
