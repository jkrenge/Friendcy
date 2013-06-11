//
//  Login.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginDelegate <NSObject>
- (void)didFinishUserInput:(NSString*)theFancyUsername;
@end

@interface Login : UIViewController <UITextFieldDelegate>
{
    
    IBOutlet UITextField *input_fancyName;
    IBOutlet UIButton *button_continue;
    
}

@property (nonatomic, assign) id<LoginDelegate> delegate;

- (IBAction)presentNextScreen:(id)sender;

@end
