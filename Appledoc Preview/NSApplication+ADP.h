//
//  NSApplication+ADP.h
//  Appledoc Preview
//
//  Created by Thibaut on 3/6/13.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (ADP)

+ (NSString*)applicationCacheDirectory;
+ (NSString*)htmlCacheDirectory;
+ (void)cleanupCacheDirectory;
+ (NSString*)appledocExecutableLocation;

@end
