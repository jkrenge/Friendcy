//
//  FeedItem.m
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "FeedItem.h"

#import "Defines.h"
#define kImageURLprefix @"http://media"

@implementation FeedItem

@synthesize url, title, date, imageURL, author;

- (id)initWithFeedItem:(MWFeedItem*)source
{
    
    self.url = [source.link stringByReplacingOccurrencesOfString:@"http://www." withString:@"http://m."];
    self.title = source.title;
    self.date = source.date;
    
    // save image url
    
    self.imageURL = @"";
    NSArray *summaryComponents = [source.summary componentsSeparatedByString:@"\""];
    for (NSString *component in summaryComponents) {
        if (component.length > 12) {
            if ([[component substringToIndex:kImageURLprefix.length] isEqualToString:kImageURLprefix]) {
                self.imageURL = component;
            }
        }
    }
    
    // save author name
    
    self.author = [source.source stringByReplacingOccurrencesOfString:gRSSurlPrefix withString:@""];
    
    return self;
    
}

- (BOOL)equals:(FeedItem*)compare
{
    
    if ([self.url isEqualToString:compare.url] && [self.author isEqualToString:compare.author]) return YES;
    else return NO;
    
}

@end
