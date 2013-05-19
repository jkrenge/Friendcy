//
//  FeedItem.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MWFeedItem.h"

@interface FeedItem : NSObject
{
    
    
    
}

@property NSString *url;
@property NSString *title;
@property NSDate *date;
@property NSString *imageURL;
@property NSString *author;

- (id)initWithFeedItem:(MWFeedItem*)source;

- (BOOL)equals:(FeedItem*)compare;

@end
