//
//  Login.m
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "Login.h"

#import "Defines.h"

@implementation Login

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.title = @"Login";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // set up button to dismiss modal
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"UIBarItem-cancel"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 38, 28)];
    [btn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:barBtn];
    
    [self.navigationItem setLeftBarButtonItem:nil];
    
    // style view
    
    [self.view setBackgroundColor:cLightColor];
    [button_continue.titleLabel setFont:[UIFont fontWithName:sHeaderFont size:sHeaderSize]];
    [button_continue setTitleColor:cDarkColor forState:UIControlStateNormal];
    
    // activate input field
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [input_fancyName setText:[defaults objectForKey:UDUsername]];
    
    [input_fancyName becomeFirstResponder];
    [input_fancyName setDelegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)cancel
{
    
    [_delegate didFinishUserInput:@""];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self presentNextScreen:nil];
    
    return NO;
    
}

- (IBAction)presentNextScreen:(id)sender
{
    
    NSString *username = input_fancyName.text;
    
    // TODO: Check for valid username
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:UDUsername];
    [defaults synchronize];
    
    [_delegate didFinishUserInput:username];
    
}

@end
