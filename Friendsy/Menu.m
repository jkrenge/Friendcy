//
//  Menu.m
//  Friendcy
//
//  Created by Julian Krenge on 02.06.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "Menu.h"

#import "Defines.h"

@implementation Menu

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        self.title = @"Feeds";
        
        feedToBeDeleted = nil;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadMenuContents];
    
    selectedStream = 0;
    
    // set up button to start friend adder
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"UIBarItem-info"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 38, 28)];
    [btn addTarget:self action:@selector(presentOptions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:barBtn];
    
    // detect long press on table view
    
    UILongPressGestureRecognizer *longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPressRec setMinimumPressDuration:1.];
    [self.tableView addGestureRecognizer:longPressRec];
    
    // appearance of navigation bar
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"UINavigationBar-dark"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      cLightColor,
      UITextAttributeTextColor,
      [UIColor colorWithRed:255. green:255. blue:255. alpha:1.],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:sHeaderFont size:sHeaderSize],
      UITextAttributeFont,
      nil]];
    
    // style table
    
    [self.tableView setRowHeight:52.];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:cDarkColor];
    
    // display help
    
    if (feeds.count == 0) {
        
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{1,46},{233,53}}],
                                    @"caption": @"You can add your close friends to your stream right here."
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{1,102},{233,116}}],
                                    @"caption": @"Afterwards your friends will be listed here."
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{200,6},{32,32}}],
                                    @"caption": @"For any additional info or settings go to options."
                                    }
                                ];
        
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
        [self.navigationController.view addSubview:coachMarksView];
        [coachMarksView start];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [self loadMenuContents];
    
    // handle selection
    
    if (selectedStream < [self.tableView numberOfRowsInSection:1]) {
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:selectedStream inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
    } else {
        
        selectedStream = 0;
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:selectedStream inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
    }
    
}

- (void)loadMenuContents
{
    
    // set up feeds
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *currentFeeds = [defaults arrayForKey:@"feeds"];
    
    if (currentFeeds == nil) feeds = [[NSMutableArray alloc] init];
    else feeds = [currentFeeds mutableCopy];
    
    // reload
    
    [self.tableView reloadData];
    
}

- (void)deleteFeedFromMenu:(NSString*)feed
{
    
    // find feed in current set
    int deleteIndex = [feeds indexOfObject:feed];
    if (deleteIndex >= 0 && deleteIndex < feeds.count) {
        
        // animate
        NSIndexPath *indexPathToRemove = [NSIndexPath indexPathForItem:deleteIndex+1 inSection:1];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToRemove] withRowAnimation:UITableViewRowAnimationLeft];
        
        // delete from NSUserDefaults
        [feeds removeObjectAtIndex:deleteIndex];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:feeds forKey:@"feeds"];
        [defaults synchronize];
        
        // reload
        [self.tableView endUpdates];
        
    }
    
    feedToBeDeleted = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section) return 1;
    else return feeds.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // prepare cell
    
    static NSString *CellIdentifier = @"MenuCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    // set content of cell
    
    if (!indexPath.section) {
        
        [cell.textLabel setText:@"Add more friends..."];
        
    } else {
        
        if (!indexPath.row) {
            
            [cell.textLabel setText:@"All friends"];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AccessoryView-group"]]];
            
        } else {
            
            [cell.textLabel setText:[[feeds objectAtIndex:indexPath.row-1] stringByReplacingOccurrencesOfString:gRSSurlPrefix withString:@""]];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AccessoryView-one"]]];
            
        }
        
    }
    
    // style cell
    
    [cell.textLabel setTextColor:cLightColor];
    [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITabelView-Menu-selectedBG"]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (!indexPath.section) {
        
        [self loadFriendAdder];
        
    } else {
        
        selectedStream = indexPath.row;
        
        if (!indexPath.row) [_delegate didSelectFeed:@""];
        else [_delegate didSelectFeed:[feeds objectAtIndex:indexPath.row-1]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:nToggleDrawer object:nil];
        
    }
    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)longPressRec
{
    
    // calculate index path from tap
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[longPressRec locationInView:self.tableView]];
    
    // call action if needed
    
    if (indexPath != nil && (indexPath.section > 0 && indexPath.row > 0)) {
        
        [self tableView:self.tableView didLongHoldRowAtIndexPath:indexPath];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didLongHoldRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (feedToBeDeleted == nil) {
        
        NSString *nameOfFeed = [[feeds objectAtIndex:indexPath.row-1] stringByReplacingOccurrencesOfString:gRSSurlPrefix withString:@""];
        feedToBeDeleted = [feeds objectAtIndex:indexPath.row-1];
        
        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"Delete feed for user %@?", nameOfFeed] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [deleteAlert setTag:AlertViewTag_deleteFeed];
        [deleteAlert show];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == AlertViewTag_deleteFeed) {
        
        if (buttonIndex) {
            
            [self deleteFeedFromMenu:[feedToBeDeleted copy]];
            
        }
        
    }
    
}

#pragma mark - FriendAdder

- (void)loadFriendAdder
{
    
    FriendAdder *friendAdder = [[FriendAdder alloc] initWithNibName:nil bundle:nil];
    [friendAdder setDelegate:self];
    
    [self presentViewController:friendAdder animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:nModalCall object:nil];
    
}

- (void)finishedAddingFriends
{
    
    [self loadMenuContents];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:nModalDismiss object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}

- (void)addedFriendURL:(NSString *)rssURL
{
    
    ALog(@"Added %@", rssURL);
    
    [feeds addObject:rssURL];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feeds forKey:@"feeds"];
    [defaults synchronize];
    
}

#pragma mark - Options

- (void)presentOptions
{

    [[NSNotificationCenter defaultCenter] postNotificationName:nModalCall object:nil];
    
    OptionsTable *options = [[OptionsTable alloc] initWithStyle:UITableViewStylePlain];
    [options setDelegate:self];
    UINavigationController *optionsContainer = [[UINavigationController alloc] initWithRootViewController:options];

    [self.navigationController presentViewController:optionsContainer animated:YES completion:nil];

}

- (void)didFinishOptions
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:nModalDismiss object:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

@end
