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
    
    UITapGestureRecognizer *tapScrollToTop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouldScrollToTop)];
    [self.navigationController.navigationBar addGestureRecognizer:tapScrollToTop];
    
    UISwipeGestureRecognizer *swipeLeftRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    [swipeLeftRec setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView.backgroundView addGestureRecognizer:swipeLeftRec];
    
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
    [refreshControl setTintColor:cDarkColor];
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
    
    if (feeds.count == 0) {
        
        // startup guide
        
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{280,6},{32,32}}],
                                    @"caption": @"To set up the app, please open the menu."
                                    }
                                ];
        
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
        [self.navigationController.view addSubview:coachMarksView];
        [coachMarksView start];
        
    }
    
    if (feedItems.count == 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *theFancyUsername = [defaults stringForKey:UDUsername];
        
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
    
    // break if the user didn't add any feeds to the stream
    
    if (feeds.count == 0) {
        
//        UIAlertView *noFeedsAlert = [[UIAlertView alloc] initWithTitle:@"No feeds" message:@"You didn't add anyone yet!" delegate:nil cancelButtonTitle:@"Oh, okay" otherButtonTitles:nil];
//        [noFeedsAlert show];
        
        [self refreshViewDidFinish];
        
        return;
        
    }
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // prepare progress indicator
        
        numOfTasks = feeds.count + 1;
        
        // add all feeds to the parser queue
        
        feedItems = [[NSMutableArray alloc] init];
        feedChecklist = [feeds mutableCopy];
        
        for (NSString *feed in feeds) {
            
            MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:[NSURL URLWithString:feed]];
            [feedParser setDelegate:self];
            
            [feedParser setFeedParseType:ParseTypeItemsOnly];
            [feedParser setConnectionType:ConnectionTypeAsynchronously];
            
            [feedParser parse];
            
        }
        
    });
    
}

-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
    
    // mark feed as done
    
    NSString *finishedFeed = parser.url.description;
    [feedChecklist removeObject:finishedFeed];
    
    [self feedParserCompleteParsing];
    
    // show error
    
    NSString *username = [[parser.url.description componentsSeparatedByString:@"/"] lastObject];
    NSString *errorMessage = [NSString stringWithFormat:@"%@ for user %@", EXCERPT(error.description, 30), username];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    
    FeedItem *feedItem = [[FeedItem alloc] initWithFeedItem:item];
    [feedItems addObject:feedItem];
    
}

-(void)feedParserDidFinish:(MWFeedParser *)parser
{
    
    ALog(@"");
    
    [self.tableView reloadData];
    
    // mark feed as done
    
    NSString *finishedFeed = parser.url.description;
    [feedChecklist removeObject:finishedFeed];
    
    [self feedParserCompleteParsing];
    
}

- (void)feedParserCompleteParsing
{
    
    if (feedChecklist.count == 0) {
        
        ALog(@"done");
        
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO];
        [feedItems sortUsingDescriptors:[NSArray arrayWithObjects:sortByDate, sortByTitle, nil]];
        
        if (feedItems.count > 0) {
            
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
            
        }
        
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

- (void)shouldScrollToTop
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scroll to top?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Go to top", nil];
    [alert setTag:AlertViewTag_scrollToTop];
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == AlertViewTag_scrollToTop) {
        
        if (buttonIndex) {
            
            [self scrollToTop];
            
        }
        
    }
    
}

- (void)scrollToTop
{
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hideScrollShadow];
    });
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [scrollShadow show];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [self hideScrollShadow];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (!decelerate) {
        [self hideScrollShadow];
    }
    
}

- (void)hideScrollShadow
{
    
    // get current relative position to cell
    
    int offset = self.tableView.contentOffset.y;
    offset %= gFeedCellHeight+gFeedSeparatorHeight;
    
    // set boundaries
    
    int smallerThan = 10;
    int greaterThan = gFeedCellHeight-gFeedSeparatorHeight-4;
    
    // hide shadow if possible
    
    BOOL hide = NO;
    if (offset < smallerThan || offset > greaterThan) hide = YES;
    if (hide) [scrollShadow hide];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    // determine scroll direction
    
    ScrollDirection scrollDirection;
    int scrollOffset = self.tableView.contentOffset.y;
    if (lastScrollOffset < scrollOffset) scrollDirection = ScrollDirectionDown;
    else if (lastScrollOffset > scrollOffset) scrollDirection = ScrollDirectionUp;
    else scrollDirection = ScrollDirectionNone;
    lastScrollOffset = scrollOffset;
    
    // check whether cell disappeared
    
    int hidingBorder = 105+gFeedSeparatorHeight;
    int rowHeight = gFeedCellHeight+gFeedSeparatorHeight;
    int rowToHide = -1;
    int hide = NO;
    
    if (scrollDirection == ScrollDirectionDown) {
        
        rowToHide = scrollOffset / rowHeight;
        scrollOffset %= rowHeight;
        
        if (scrollOffset > rowHeight-hidingBorder) hide = YES;
        
    } else if (scrollDirection == ScrollDirectionUp) {
        
        scrollOffset += self.view.bounds.size.height;
        rowToHide = scrollOffset / rowHeight;
        scrollOffset %= rowHeight;
        
        if (scrollOffset < hidingBorder) hide = YES;
        
    }
    
    // hide disappearing cell
    
    if (hide) {
        
        if (0 <= rowToHide && rowToHide < [self tableView:self.tableView numberOfRowsInSection:0]) {
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:rowToHide inSection:0];
            FeedCell *cell = (FeedCell*)[self.tableView cellForRowAtIndexPath:ip];
            [cell hideSubDrawerFromScrolling];
            
        }
                
    }
    
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
            
        case ActionKeyShowMenu:
            [self showMenu];
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
    
    [self refreshViewShouldStart];
    
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
    [shareOptions setExcludedActivityTypes:@[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage]];
    
    [self presentViewController:shareOptions animated:YES completion:nil];
    
}

@end
