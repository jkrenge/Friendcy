//
//  OptionsTable.h
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMiniWebBrowser.h"

@protocol OptionsDelegate <NSObject>
- (void)didFinishOptions;
@end

@interface OptionsTable : UITableViewController
{
    
    NSArray *usedFrameworks;
    
    TSMiniWebBrowser *webBrowser;
    
}

@property (nonatomic, assign) id<OptionsDelegate> delegate;

@end
