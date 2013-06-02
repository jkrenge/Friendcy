//
//  PassthroughView.m
//  Friendcy
//
//  Created by Julian Krenge on 02.06.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "PassthroughView.h"

#define kAnimationDuration 0.2f

@implementation PassthroughView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithImage:(UIImage*)image andFrame:(CGRect)frame beingVisible:(BOOL)visible
{
    
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    if (!visible) {
        [self setAlpha:0.0];
    }
    
    return self;
    
}

#pragma mark - Visibility handling

- (void)hide
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration];
    [self setAlpha:0.0f];
    [UIView commitAnimations];
    
}

- (void)show
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration];
    [self setAlpha:1.0f];
    [UIView commitAnimations];
    
}

- (void)toggleVisibility
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration];
    [self setAlpha:([self alpha] > 0.0) ? 0.0f : 1.0f];
    [UIView commitAnimations];
    
}

#pragma mark - Delegate touches (passthrough)

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    
    return NO;
    
}

@end
