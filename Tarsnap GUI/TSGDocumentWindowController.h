//
//  TSGDocumentWindowController.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSGDocument;

@interface TSGDocumentWindowController : NSWindowController {
}

@property (assign) IBOutlet NSTextField *pathLabel;
@property (assign) IBOutlet NSArrayController *backupsController;

@property (readonly, assign) TSGDocument *document;

@end
