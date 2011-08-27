//
//  TSGRequestPasswordWindowController.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGRequestPasswordWindowController.h"

@implementation TSGRequestPasswordWindowController

- (id)init
{
    if (self = [super initWithWindowNibName:@"RequestPasswordSheet"]) {

    }
    
    return self;
}

- (void)showInWindow:(NSWindow *)theWindow;
{
    [NSApp beginSheet:self.window
       modalForWindow:theWindow
        modalDelegate:self
       didEndSelector:@selector(requestPasswordWindowDidClose:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (void)requestPasswordWindowDidClose:(NSWindow *)theSheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    NSLog(@"Finished the window!");
    [theSheet close];
}

- (IBAction)sendPassword:(id)sender {
    [NSApp endSheet:self.window];
}



@end
