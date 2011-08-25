//
//  TSGDocument.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TSGDocument : NSDocument {
}

@property (retain) IBOutlet NSArrayController *backupsController;
@property (readonly, assign, getter=isLoading) BOOL loading;

- (IBAction)deleteSelectedBackups:(id)theSender;

@end
