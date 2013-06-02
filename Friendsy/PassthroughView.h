//
//  PassthroughView.h
//  Friendcy
//
//  Created by Julian Krenge on 02.06.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassthroughView : UIView

- (id)initWithImage:(UIImage*)image andFrame:(CGRect)frame beingVisible:(BOOL)visible;

- (void)hide;
- (void)show;
- (void)toggleVisibility;

@end
