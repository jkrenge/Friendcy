//
//  Defines.h
//  Friendcy
//
//  Created by Julian Krenge on 27.04.13.
//  Copyright (c) 2013 Julian Krenge. All rights reserved.
//

#ifndef Friendcy_Defines_h
#define Friendcy_Defines_h

// methods

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define EXCERPT(str, len) (([str length] > len) ? [[str substringToIndex:len-1] stringByAppendingString:@"…"] : str)

// feed options

#define gRSSurlPrefix @"http://www.thefancy.com/rss/"
#define gFeedCellHeight 280
#define gFeedSeparatorHeight 12
#define gPlaceholderImage @"FeedCellImagePlaceholder"

// styling

#define sHeaderFont @"Novecentowide-Bold"
#define sHeaderSize 20.

#define cDarkColor [UIColor colorWithRed:61/255. green:67/255. blue:77/255. alpha:1.]
#define cLightColor [UIColor colorWithRed:238/255. green:240/255. blue:243/255. alpha:1.]

// notifications

#define nToggleDrawer @"notification-toggleMainDrawer"
#define nModalCall @"notification-callModal"
#define nModalDismiss @"notification-dismissModal"
#define nRefreshFeed @"notification-refreshFeed"

// NSUserDefaults

#define UDUsername @"theFancyUsername"

#endif
