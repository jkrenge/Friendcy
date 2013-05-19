//
//  Defines.h
//  Friendsy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#ifndef Friendsy_Defines_h
#define Friendsy_Defines_h

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define EXCERPT(str, len) (([str length] > len) ? [[str substringToIndex:len-1] stringByAppendingString:@"…"] : str)

#define gRSSurlPrefix @"http://www.thefancy.com/rss/"
#define gFeedCellHeight 280
#define gPlaceholderImage @""

#endif
