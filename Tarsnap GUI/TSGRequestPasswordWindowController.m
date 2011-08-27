//
//  TSGRequestPasswordWindowController.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGRequestPasswordWindowController.h"

@implementation TSGRequestPasswordWindowController

@synthesize passwordField = i_passwordField;
@synthesize delegate = i_delegate;

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
    [theSheet close];
    
    if (returnCode == NSAlertDefaultReturn)
        [self.delegate passwordRequestController:self FinishedWithPassword:[self.passwordField stringValue]];
}

- (IBAction)sendPassword:(id)sender;
{
    [NSApp endSheet:self.window returnCode:NSAlertDefaultReturn];
}

- (IBAction)cancelPasswordRequest:(id)sender;
{
    [NSApp endSheet:self.window returnCode:NSAlertAlternateReturn];
}



@end
