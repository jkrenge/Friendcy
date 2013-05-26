//
//  FrameworkDescription.m
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "FrameworkDescription.h"

@implementation FrameworkDescription

@synthesize name, description, url, modified;

- (id)framework:(NSString*)_name withUrl:(NSString*)_url andDescription:(NSString*)_description wasModified:(BOOL)_modified
{
    
    self.name = _name;
    self.description = _description;
    self.url = _url;
    self.modified = _modified;
    
    return self;
    
}

@end
