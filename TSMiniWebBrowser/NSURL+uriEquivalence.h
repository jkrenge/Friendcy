//
//  NSURL+uriEquivalence.h
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (uriEquivalence)

- (BOOL)isEquivalent:(NSURL *)aURL;

@end
