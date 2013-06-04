//
//  ADPPreviewWindowController.m
//  Appledoc Preview
//
//  Created by Thibaut on 29/5/13.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import "ADPPreviewWindowController.h"
#import <WebKit/WebKit.h>
#import "NSApplication+ADP.h"

@implementation ADPPreviewWindowController
{
    NSString *_fileCacheDirectory;
    NSTimer *_timer;
    NSData *_fileBookmarkData;
    NSDate *_fileModificationDate;
}

- (id)initWithFileURL:(NSURL*)fileURL
{
    self = [super initWithWindowNibName:@"ADPPreviewWindowController"];
    if (self)
    {
        [self updateFileBookmarkDataWithURL:fileURL];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self tryRefreshContent:nil];
    
    [_webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self htmlIndexFile]]]];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tryRefreshContent:) userInfo:nil repeats:YES];
}

- (void)updateFileBookmarkDataWithURL:(NSURL*)url
{
    _fileBookmarkData = [url bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
}

- (NSURL*)fileURL
{
    return [NSURL URLByResolvingBookmarkData:_fileBookmarkData options:0 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
}

- (BOOL)isFileURL:(NSURL*)fileURL
{
    return fileURL ? [self.fileURL isEqualTo:fileURL] : NO;
}

- (IBAction)tryRefreshContent:(id)sender
{
    NSURL *url = [self fileURL];
    
    NSDate *fileModificationDate = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil].fileModificationDate;
    BOOL modified = ( _fileModificationDate != fileModificationDate && ( !fileModificationDate || ![_fileModificationDate isEqualToDate:fileModificationDate] ) ) ? YES : NO;
    
    
    if ( modified || !url || ![self.window.representedURL isEqualTo:url] )
    {
        self.window.representedURL = url;
        self.window.title = url.lastPathComponent ? : @"";
        [self updateFileBookmarkDataWithURL:url];
    }
    
    if ( modified )
    {
        _fileModificationDate = fileModificationDate;
        [self refreshContent:sender];
    }
}

- (IBAction)refreshContent:(id)sender
{
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = [NSApplication applicationCacheDirectory];
    task.launchPath = [NSApplication appledocExecutableLocation];
    task.arguments = [self appledocArgumentsWithFilePath:[self fileURL].path outputDir:[self fileCacheDirectory]];
    
    [task launch];
    [task waitUntilExit];
    
    [_webView.mainFrame reload];
}

- (NSArray*)appledocArgumentsWithFilePath:(NSString*)filePath outputDir:(NSString*)outputDir
{
    return @
    [
     @"--project-company", @"My Company",
     @"--project-name", @"My Project",
     @"--no-create-docset",
     @"--create-html",
     @"--output", outputDir,
     @"--verbose", @"0",
     @"--logformat", @"1",
     filePath ? : @""
    ];
    
}

- (NSString*)fileCacheDirectory
{
    if ( !_fileCacheDirectory )
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        CFRelease(uuidRef);
        
        _fileCacheDirectory = [[NSApplication htmlCacheDirectory] stringByAppendingPathComponent:uuid];
        
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath:_fileCacheDirectory] )
            [[NSFileManager defaultManager] createDirectoryAtPath:_fileCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _fileCacheDirectory;
}

- (NSString*)htmlIndexFile
{
    return [[[self fileCacheDirectory] stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"index.html"];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSFileManager defaultManager] removeItemAtPath:[self fileCacheDirectory] error:nil];
}

@end
