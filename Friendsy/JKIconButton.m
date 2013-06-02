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

- (id)initWithFrame:(CGRect)frame andIcon:(UIImage*)image
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
        int labelHeight = self.titleLabel.bounds.size.height;
        int btnHeight = self.bounds.size.height;
        
        int startYofIcon = (btnHeight/2) - (iconHeight/2);
        int startXofIcon = startYofIcon;
        int startYofLabel = (btnHeight/2) - (labelHeight/2);
        int startXofLabel = iconWidth;
        
        // apply positions
        
        [icon setFrame:CGRectMake(startXofIcon, startYofIcon, iconWidth, iconHeight)];
        [self addSubview:icon];
        
        [self.titleLabel setFrame:CGRectMake(startXofLabel, startYofLabel, self.titleLabel.bounds.size.width, labelHeight)];
        
        // style label
        
        [self.titleLabel setFont:[UIFont fontWithName:sHeaderFont size:sHeaderSize-6]];
        
    }
    return self;
}

@end
