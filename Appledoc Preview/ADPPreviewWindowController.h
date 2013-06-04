//
//  ADPPreviewWindowController.h
//  Appledoc Preview
//
//  Created by Thibaut on 29/5/13.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface ADPPreviewWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet WebView *webView;

- (id)initWithFileURL:(NSURL*)fileURL;
- (BOOL)isFileURL:(NSURL*)fileURL;

- (IBAction)refreshContent:(id)sender;

@end
