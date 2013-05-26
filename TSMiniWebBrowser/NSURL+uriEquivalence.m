//
//  NSURL+uriEquivalence.m
//  Friendcy
//
//  Created by Julian Krenge on 26.05.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "NSURL+uriEquivalence.h"

@implementation NSURL (uriEquivalence)

- (BOOL)isEquivalent:(NSURL *)aURL {
    
    if ([self isEqual:aURL]) return YES;
    
    if ([[self scheme] caseInsensitiveCompare:[aURL scheme]] != NSOrderedSame) return NO;
    if ([[self host] caseInsensitiveCompare:[aURL host]] != NSOrderedSame) return NO;
    if ([[self path] compare:[aURL path]] != NSOrderedSame) return NO;
    if ([[self port] compare:[aURL port]] != NSOrderedSame) return NO;
    if ([[self query] compare:[aURL query]] != NSOrderedSame) return NO;
    
    return YES;
    
}

@end
