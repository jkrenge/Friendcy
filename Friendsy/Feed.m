//
//  Feed.m
//  Friendsy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "Feed.h"

#import "FeedCell.h"
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
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *currentFeeds = [defaults arrayForKey:@"feeds"];
        
        if (currentFeeds == nil) feeds = [[NSMutableArray alloc] init];
        else feeds = [currentFeeds mutableCopy];
        
        // set up table source
        
        feedItems = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm 'am' dd.MM.yy"];

    // set up button to start friend adder
    
    UIBarButtonItem *btn_loadFriendAdder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadFriendAdder)];
    [self.navigationItem setRightBarButtonItem:btn_loadFriendAdder];
    
    // set up refresher
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to Refresh"]];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // style table
    
    [self.tableView setRowHeight:gFeedCellHeight];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:.95 green:.95 blue:.98 alpha:1.]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *theFancyUsername = [defaults stringForKey:@"theFancyUsername"];
//    
//    if (!(theFancyUsername == nil || [theFancyUsername isEqualToString:@""]))
//        [self refreshViewShouldStart];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - FriendAdder

- (void)loadFriendAdder
{
    
    FriendAdder *friendAdder = [[FriendAdder alloc] initWithNibName:nil bundle:nil];
    [friendAdder setDelegate:self];
    
    [self presentViewController:friendAdder animated:YES completion:nil];
    
}

- (void)finishedAddingFriends
{
    
    ALog(@"");
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self refreshViewShouldStart];
    }];
    
}

- (void)addedFriendURL:(NSString *)rssURL
{
    
    ALog(@"Added %@", rssURL);
    
    [feeds addObject:rssURL];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feeds forKey:@"feeds"];
    [defaults synchronize];
    
}

#pragma mark - Feed Parser

- (void)refreshContent
{
    
    ALog(@"");
    
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
    
    return gFeedCellHeight;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // prepare cell
    
    static NSString *CellIdentifier = @"FeedCell";
    
    FeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // fill cell

    FeedItem *item = [feedItems objectAtIndex:indexPath.row];
    
    [cell setItemImage:item.imageURL];
    [cell setItemTitle:item.title];
    [cell setItemAuthor:item.author];
    [cell setItemDate:[dateFormatter stringFromDate:item.date]];
    
    return cell;
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // this is handled by the cell itself
    
}

@end
