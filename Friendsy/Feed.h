//
//  Feed.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAdder.h"
#import "OptionsTable.h"
#import "FeedCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MWFeedParser.h"
#import "TSMiniWebBrowser.h"

#import "NSString+HTML.h"
#import "NSDate+InternetDateTime.h"

@interface Feed : UITableViewController <FriendAdderDelegate, MWFeedParserDelegate, FeedCellActionDelegate, OptionsDelegate>
{
    
    NSDateFormatter *dateFormatter;
    
    UIRefreshControl *refreshControl;
    
    NSMutableArray *feeds;
    NSMutableArray *feedChecklist;
    NSMutableArray *feedItems;
    
    UINavigationController *webBrowserContainer;
    TSMiniWebBrowser *webBrowser;
    
}

@end
