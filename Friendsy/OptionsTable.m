//
//  OptionsTable.m
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "OptionsTable.h"

#import "FrameworkDescription.h"

@interface OptionsTable ()

@end

@implementation OptionsTable

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.title = @"Options";
        
        [self usedFrameworks];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up button
    
    UIBarButtonItem *btn_cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(finished)];
    [self.navigationItem setRightBarButtonItem:btn_cancel];
    
    // style table
    
    [self.tableView setRowHeight:52.];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:.95 green:.95 blue:.98 alpha:1.]];
    
}

- (void)finished
{
    
    [_delegate didFinishOptions];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return usedFrameworks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // prepare cell
    
    static NSString *CellIdentifier = @"OptionsCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OptionsCell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // get content
    
    FrameworkDescription *content = [usedFrameworks objectAtIndex:indexPath.row];
    
    // set content of cell
    
    [cell.textLabel setText:content.name];
    [cell.detailTextLabel setText:content.description];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FrameworkDescription *content = [usedFrameworks objectAtIndex:indexPath.row];

    // prepare browser
    
    if (webBrowser == nil) {
        webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:content.url]];
        [webBrowser setMode:TSMiniWebBrowserModeNavigation];
        [webBrowser setBarStyle:UIBarStyleDefault];
        
        [webBrowser setShowURLStringOnActionSheetTitle:YES];
        [webBrowser setShowPageTitleOnTitleBar:YES];
        [webBrowser setShowActionButton:YES];
        [webBrowser setShowReloadButton:NO];
    }
    
    // load required content
    
    [webBrowser loadURL:[NSURL URLWithString:content.url]];
    
    // push view
    
    [self.navigationController pushViewController:webBrowser animated:YES];
    
}

#pragma mark - Used Frameworks

- (void)usedFrameworks
{
    
    NSMutableArray *frameworks = [[NSMutableArray alloc] init];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"MWFeedParser"
                           withUrl:@"https://github.com/mwaterfall/MWFeedParser"
                           andDescription:@"Load data from Fancy RSS"
                           wasModified:YES]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"SDWebImage"
                           withUrl:@"https://github.com/rs/SDWebImage"
                           andDescription:@"Cached image loader"
                           wasModified:NO]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"GGFullScreenImage"
                           withUrl:@"https://github.com/bogardon/GGFullscreenImageViewController"
                           andDescription:@"Full screen view for images"
                           wasModified:YES]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"TSMiniWebBrowser"
                           withUrl:@"https://github.com/tonisalae/TSMiniWebBrowser"
                           andDescription:@"In-app web browser"
                           wasModified:NO]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"HCPushBackAnimation"
                           withUrl:@"https://github.com/ucu072/HCPushBackAnimation"
                           andDescription:@"Depth animation for modals"
                           wasModified:NO]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"BButton"
                           withUrl:@"https://github.com/mattlawer/BButton"
                           andDescription:@"Beautified buttons"
                           wasModified:NO]];

    usedFrameworks = [frameworks copy];
    
}

@end
