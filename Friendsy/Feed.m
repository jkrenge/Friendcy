//
//  Feed.m
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "Feed.h"

#import "FeedItem.h"

#import "Defines.h"

@interface Feed ()

@end

@implementation Feed

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.title = @"Friendcy";

        // set up feeds
        
        [self loadFeeds];
        
        // set up table source
        
        feedItems = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)loadFeeds
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *currentFeeds = [defaults arrayForKey:@"feeds"];
    
    if (currentFeeds == nil) feeds = [[NSMutableArray alloc] init];
    else feeds = [currentFeeds mutableCopy];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm 'am' dd.MM.yy"];
    
    // appearance of navigation bar
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"UINavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      cDarkColor,
      UITextAttributeTextColor,
      [UIColor colorWithRed:255. green:255. blue:255. alpha:1.],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:sHeaderFont size:sHeaderSize],
      UITextAttributeFont,
      nil]];

    // set up button to start friend adder
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"UIBarItem-group"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 38, 28)];
    [btn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:barBtn];
    
    // set up refresher
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to Refresh"]];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // style table
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:cLightColor];
    
    // prepare scroll shadow
    
    scrollShadow = [[PassthroughView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBar-shadow"] andFrame:CGRectMake(0, 44, 320, 44) beingVisible:NO];
    [self.navigationController.view addSubview:scrollShadow];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    if (feedItems.count == 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *theFancyUsername = [defaults stringForKey:@"theFancyUsername"];
        
        if (!(theFancyUsername == nil || [theFancyUsername isEqualToString:@""]))
            [self refreshViewShouldStart];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Feed Parser

- (void)refreshContent
{
    
    ALog(@"");
    
    // break if the user didn't add any feeds to the stream
    
    if (feeds.count == 0) {
        
        UIAlertView *noFeedsAlert = [[UIAlertView alloc] initWithTitle:@"No feeds" message:@"You didn't add anyone yet!" delegate:nil cancelButtonTitle:@"Oh, okay" otherButtonTitles:nil];
        [noFeedsAlert show];
        
        return;
        
    }
    
    // add all feeds to the parser queue
    
    feedItems = [[NSMutableArray alloc] init];
    feedChecklist = [feeds mutableCopy];
    
    for (NSString *feed in feeds) {
        
        MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:[NSURL URLWithString:feed]];
        [feedParser setDelegate:self];
        
        [feedParser setFeedParseType:ParseTypeItemsOnly];
        [feedParser setConnectionType:ConnectionTypeSynchronously];
        
        [feedParser parse];
        
    }
    
}

-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
    
    NSString *username = [[parser.url.description componentsSeparatedByString:@"/"] lastObject];
    NSString *errorMessage = [NSString stringWithFormat:@"%@ for user %@", EXCERPT(error.description, 30), username];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    
//    ALog(@"%@", item.description);
    
    FeedItem *feedItem = [[FeedItem alloc] initWithFeedItem:item];
    [feedItems addObject:feedItem];
    
}

-(void)feedParserDidFinish:(MWFeedParser *)parser
{
    
    [self.tableView reloadData];
    
    NSString *finishedFeed = parser.url.description;
    [feedChecklist removeObject:finishedFeed];
    
    if (feedChecklist.count == 0) {
        
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO];
        [feedItems sortUsingDescriptors:[NSArray arrayWithObjects:sortByDate, sortByTitle, nil]];
        
        NSMutableIndexSet *indexesToBeRemoved = [[NSMutableIndexSet alloc] init];
        
        for (int i = 0; i < feedItems.count-1; i++) {
            FeedItem *checkForDuplicate = [feedItems objectAtIndex:i];
            
            for (int j = i+1; j < feedItems.count; j++) {
                FeedItem *compareAsDuplicate = [feedItems objectAtIndex:j];
                
                if ([checkForDuplicate equals:compareAsDuplicate]) {
                    [indexesToBeRemoved addIndex:i];
                    break;
                }
            }
        }
        
        [feedItems removeObjectsAtIndexes:indexesToBeRemoved];
        
        [self refreshViewDidFinish];
        
    }
    
}

#pragma mark - Refresh Control

- (void)refreshViewShouldStart {
    
    [self.refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
            [self refreshView];
            
        }];
        
    }
}

- (void)refreshView
{
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl beginRefreshing];
    
    [self refreshContent];
    
}

- (void)refreshViewDidFinish
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refreshControl endRefreshing];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feedItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return gFeedCellHeight+gFeedSeparatorHeight;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // prepare cell
    
    static NSString *CellIdentifier = @"FeedCell";
    
    FeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell setDelegate:self];
    
    // fill cell

    FeedItem *item = [feedItems objectAtIndex:indexPath.row];
    
    [cell setItemImage:item.imageURL];
    [cell setItemTitle:item.title];
    [cell setItemAuthor:item.author];
    [cell setItemDate:[dateFormatter stringFromDate:item.date]];
    
    return cell;
    
}

#pragma mark - Scroll view delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [scrollShadow show];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [self hideScrollShadow];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (!decelerate) {
        [self hideScrollShadow];
    }
    
}

- (void)hideScrollShadow
{
    
    int offset = self.tableView.contentOffset.y;
    offset %= gFeedCellHeight+gFeedSeparatorHeight;
    
    int smallerThan = 10;
    int greaterThan = gFeedCellHeight-gFeedSeparatorHeight-4;
    
    BOOL hide = NO;
    if (offset < smallerThan || offset > greaterThan) hide = YES;
    
    ALog(@"%@", (hide ? @"hide" : @"still visible"));
    if (hide) [scrollShadow hide];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath*)indexPath withAction:(ActionKey)action
{
    
    FeedItem *item = [feedItems objectAtIndex:indexPath.row];
    
    switch (action) {
        case ActionKeyShowDetails:
            [self presentDetailsForItem:item];
            break;
            
        case ActionKeyShowSharingOptions:
            [self presentSharingOptionsForItem:item];
            break;
            
        default:
            break;
    }
    
}

- (void)didBeginInteractionWithCell
{
    
    [self.tableView setScrollEnabled:NO];
    
}

- (void)didEndInteractionWithCell
{
    
    [self.tableView setScrollEnabled:YES];
    
}

#pragma mark - Navigation

- (void)showMenu
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:nToggleDrawer object:nil];
    
}

- (void)didSelectFeed:(NSString *)feed
{
    
    if ([feed isEqualToString:@""]) [self loadFeeds];
    else feeds = [[NSMutableArray alloc] initWithObjects:feed, nil];
    
    [self refreshView];
    
}

- (void)presentDetailsForItem:(FeedItem*)item
{
    
    // prepare browser
    
    if (webBrowser == nil) {
        webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:item.url]];
        [webBrowser setMode:TSMiniWebBrowserModeNavigation];
        [webBrowser setBarStyle:UIBarStyleDefault];
        
        [webBrowser setShowURLStringOnActionSheetTitle:YES];
        [webBrowser setShowPageTitleOnTitleBar:YES];
        [webBrowser setShowActionButton:YES];
        [webBrowser setShowReloadButton:NO];
    }
    
    // load required content
    
    [webBrowser loadURL:[NSURL URLWithString:item.url]];
    
    // push view
    
    [self.navigationController pushViewController:webBrowser animated:YES];
    
}

- (void)presentSharingOptionsForItem:(FeedItem*)item
{
    
    NSString *shareText = item.title;
    NSString *shareLink = item.url;
    NSArray *activityItems = @[shareText, shareLink];
    
    UIActivityViewController *shareOptions = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [shareOptions setExcludedActivityTypes:@[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypePrint]];
    
    [self presentViewController:shareOptions animated:YES completion:nil];
    
}

@end
