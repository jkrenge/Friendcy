//
//  OptionsTable.m
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "OptionsTable.h"

#import "FrameworkDescription.h"

#import "Defines.h"

#define kHeightOfRow 52.
#define kHeightOfSeparator 8.

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
    
    // set up button to dismiss modal
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"UIBarItem-check"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 38, 28)];
    [btn addTarget:self action:@selector(finished) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:barBtn];
    
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
    
    // style table
    
    [self.tableView setRowHeight:kHeightOfRow+kHeightOfSeparator];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:cLightColor];
    
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
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 1) return 40;
    else return 0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 1)
    {
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [header setBackgroundColor:cLightColor];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 29)];
        [title setFont:[UIFont fontWithName:sHeaderFont size:sHeaderSize-4]];
        [title setTextColor:cDarkColor];
        [title setBackgroundColor:cLightColor];
        [title setText:@"Used frameworks"];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, 200, 1)];
        [line setBackgroundColor:cDarkColor];
        
        [header addSubview:title];
        [header addSubview:line];
        
        return header;
        
    }
    
    else return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) return 1;
    else if (section == 1) return usedFrameworks.count;
    
    else return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // prepare cell
    
    static NSString *OptionCellIdentifier = @"OptionsCell";
    static NSString *LinkCellIdentifier = @"LinkCell";
    
    UITableViewCell* cell;
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:OptionCellIdentifier];
        [cell setFrame:CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, kHeightOfRow)];
        
        // set content
        
        [cell.imageView setImage:[UIImage imageNamed:@"486-fancy"]];
        [cell.textLabel setText:@"username"];
        
        // prepare textfield
        
        int width = 160;
        int height = 30;
        
        username = [[UITextField alloc] initWithFrame:CGRectMake(cell.viewForBaselineLayout.frame.size.width-width-20, (kHeightOfRow-height)/2+8, width, height)];
        
        // style textfield
        
        [username setBackgroundColor:[UIColor clearColor]];
        [username setClearButtonMode:UITextFieldViewModeWhileEditing];
        [username setClearsOnBeginEditing:YES];
        
        [username setReturnKeyType:UIReturnKeyDone];
        
        // install textfield
        
        [username setDelegate:self];
        [cell.viewForBaselineLayout addSubview:username];
        
        // read value
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [username setText:[defaults objectForKey:UDUsername]];
        
    } else if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:LinkCellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LinkCellIdentifier];
        [cell setFrame:CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, kHeightOfRow)];
        
        // get content
        
        FrameworkDescription *content = [usedFrameworks objectAtIndex:indexPath.row];
        
        // set content of cell
        
        [cell.textLabel setText:content.name];
        [cell.textLabel setTextColor:cDarkColor];
        [cell.detailTextLabel setText:content.description];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    else if (indexPath.section == 1)
    {
        
        FrameworkDescription *content = [usedFrameworks objectAtIndex:indexPath.row];
        
        // prepare browser
        
        if (webBrowser == nil) {
            webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:content.url]];
            [webBrowser setMode:TSMiniWebBrowserModeNavigation];
            
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
    
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username.text forKey:UDUsername];
    [defaults synchronize];
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username.text forKey:UDUsername];
    [defaults synchronize];
    
    [username resignFirstResponder];
    return YES;
    
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
                           framework:@"MMDrawerController"
                           withUrl:@"https://github.com/jdg/MBProgressHUD"
                           andDescription:@"Activity and progress indicators"
                           wasModified:YES]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"MBProgressHUD"
                           withUrl:@"https://github.com/michaelhenry/MHFacebookImageViewer"
                           andDescription:@"Full screen view for images"
                           wasModified:YES]];
    
    [frameworks addObject:[[FrameworkDescription alloc]
                           framework:@"MHFacebookImageViewer"
                           withUrl:@"https://github.com/michaelhenry/MHFacebookImageViewer"
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
