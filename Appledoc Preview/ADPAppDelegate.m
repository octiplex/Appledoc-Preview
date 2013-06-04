//
//  ADPAppDelegate.m
//  Appledoc Preview
//
//  Created by Thibaut on 29/5/13.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import "ADPAppDelegate.h"
#import "ADPPreviewWindowController.h"
#import "NSApplication+ADP.h"

@implementation ADPAppDelegate
{
    NSMutableArray *_previewWindowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    [NSApplication cleanupCacheDirectory];
    [self openDocument:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if ( !flag )
        [self openDocument:nil];
    return YES;
}

- (void)openDocument:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = @[@"h"];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if ( result)
        {
            [self openPreviewWindowsWithFileURLs:panel.URLs];
        }
    }];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:filenames.count];
    
    for ( NSString *filename in filenames )
        [array addObject:[NSURL fileURLWithPath:filename]];
    
    [self openPreviewWindowsWithFileURLs:array];
}

- (void)openPreviewWindowsWithFileURLs:(NSArray*)fileURLs
{
    for ( NSURL *fileURL in fileURLs )
    {
        if ( [[fileURL pathExtension] isEqualToString:@"h"] )
        {
            if ( !_previewWindowController )
                _previewWindowController = [NSMutableArray new];
            
            NSIndexSet *indexSet = [_previewWindowController indexesOfObjectsPassingTest:^BOOL(ADPPreviewWindowController *windowController, NSUInteger idx, BOOL *stop) {
                BOOL result = [windowController isFileURL:fileURL];
                if ( result )
                    *stop = YES;
                return result;
            }];
            
            ADPPreviewWindowController *windowController = indexSet.count ? _previewWindowController[indexSet.firstIndex] : nil;
            
            if ( windowController )
                [windowController showWindow:nil];
            
            else
            {
                ADPPreviewWindowController *windowController = [[ADPPreviewWindowController alloc] initWithFileURL:fileURL];
                [_previewWindowController addObject:windowController];
                [windowController showWindow:nil];
            }
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSWindow *window = notification.object;
    if ( window.windowController )
        [_previewWindowController removeObject:window.windowController];
}

@end
