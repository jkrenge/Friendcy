//
//  Feed.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FeedCell.h"
#import "PassthroughView.h"
#import "Menu.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MWFeedParser.h"
#import "TSMiniWebBrowser.h"
#import "MBProgressHUD.h"

#import "NSString+HTML.h"
#import "NSDate+InternetDateTime.h"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionUp,
    ScrollDirectionDown
} ScrollDirection;

#define AlertViewTag_scrollToTop 1

@interface Feed : UITableViewController <MWFeedParserDelegate, FeedCellActionDelegate, MenuDelegate, UIAlertViewDelegate>
{
    
    NSDateFormatter *dateFormatter;
    
    UIRefreshControl *refreshControl;
    MBProgressHUD *activityIndicator;
    int numOfTasks;
    PassthroughView *scrollShadow;
    NSInteger lastScrollOffset;
    
    NSMutableArray *feeds;
    NSMutableArray *feedChecklist;
    NSMutableArray *feedItems;
    
    UINavigationController *webBrowserContainer;
    TSMiniWebBrowser *webBrowser;
    
}

@end
