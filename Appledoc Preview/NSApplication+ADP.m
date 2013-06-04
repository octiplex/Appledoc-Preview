//
//  NSApplication+ADP.m
//  Appledoc Preview
//
//  Created by Thibaut on 3/6/13.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import "NSApplication+ADP.h"

@implementation NSApplication (ADP)

+ (NSString*)applicationCacheDirectory
{
    static NSString *_applicationCacheDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _applicationCacheDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier] isDirectory:YES].path;
    });
    
    return _applicationCacheDirectory;
}

+ (NSString*)htmlCacheDirectory
{
    static NSString *_htmlCacheDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _htmlCacheDirectory = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"html"];
    });
    
    return _htmlCacheDirectory;
}

+ (void)cleanupCacheDirectory
{
    [[NSFileManager defaultManager] removeItemAtPath:[self htmlCacheDirectory] error:nil];
}

+ (NSString*)appledocExecutableLocation
{
    return [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"appledoc"];
}

@end
