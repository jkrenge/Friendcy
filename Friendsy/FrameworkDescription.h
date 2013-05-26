//
//  FrameworkDescription.h
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameworkDescription : NSObject

@property NSString *name;
@property NSString *description;
@property NSString *url;
@property BOOL modified;

- (id)framework:(NSString*)_name withUrl:(NSString*)_url andDescription:(NSString*)_description wasModified:(BOOL)_modified;

@end
