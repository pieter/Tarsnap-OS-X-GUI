//
//  TSGRequestPasswordWindowController.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TSGRequestPasswordWindowControllerDelegate;

@interface TSGRequestPasswordWindowController : NSWindowController
{
}

@property (assign) IBOutlet NSSecureTextField *passwordField;
@property (assign) id<TSGRequestPasswordWindowControllerDelegate> delegate;

- (void)showInWindow:(NSWindow *)theWindow;

- (IBAction)sendPassword:(id)sender;
- (IBAction)cancelPasswordRequest:(id)sender;

@end

@protocol TSGRequestPasswordWindowControllerDelegate <NSObject>

- (void)passwordRequestController:(TSGRequestPasswordWindowController *)theController FinishedWithPassword:(NSString *)thePassword;

@end