//
//  JKIconButton.m
//  Friendcy
//
//  Created by Julian Krenge on 02.06.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#import "JKIconButton.h"

#import "Defines.h"

@implementation JKIconButton

- (id)initWithFrame:(CGRect)frame icon:(UIImage*)image andTitle:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {

        // clean button
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        // prepare icon

        UIImageView *icon = [[UIImageView alloc] initWithImage:image];
        
        // calculate positions
        
        int iconHeight = icon.bounds.size.height;
        int iconWidth = icon.bounds.size.width;
        int btnHeight = self.bounds.size.height;
        
        int startYofIcon = (btnHeight/2) - (iconHeight/2);
        int startXofIcon = startYofIcon;
        int startYofLabel = iconWidth+15;
        
        // apply positions
        
        [icon setFrame:CGRectMake(startXofIcon, startYofIcon, iconWidth, iconHeight)];
        [self addSubview:icon];
        
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, startYofLabel, 0, 0)];
        
        // style label
        
        [self setTitle:title forState:UIControlStateNormal];
        
        [self.titleLabel setFont:[UIFont fontWithName:sHeaderFont size:sHeaderSize-6]];
        [self.titleLabel setTextColor:cDarkColor];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        
    }
    return self;
}

@end
