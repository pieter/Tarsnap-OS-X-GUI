//
//  TSGDocumentWindowController.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TSGRequestPasswordWindowController.h"

@class TSGDocument;

@interface TSGDocumentWindowController : NSWindowController<TSGRequestPasswordWindowControllerDelegate> {
}

@property (assign) IBOutlet NSTextField *pathLabel;
@property (assign) IBOutlet NSArrayController *backupsController;

@property (readonly, assign) TSGDocument *document;

- (void)requestPassword;

@end
