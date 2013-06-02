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

@interface Menu : UITableViewController <FriendAdderDelegate, OptionsDelegate>
{
    
    NSMutableArray *feeds;
    
}

@end
