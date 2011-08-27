//
//  TSGDocumentWindowController.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGDocumentWindowController.h"
#import "TSGRequestPasswordWindowController.h"
#import "TSGDocument.h"

@interface TSGDocumentWindowController ()
@property (retain) TSGRequestPasswordWindowController *requestPasswordController;
@end

@implementation TSGDocumentWindowController

@synthesize pathLabel = i_pathLabel;
@synthesize backupsController = i_backupsController;
@synthesize requestPasswordController = i_requestPasswordController;

- (id)init
{
    if (self = [super initWithWindowNibName:@"TSGDocument"]) {
        i_requestPasswordController = [[TSGRequestPasswordWindowController alloc] init];
        [i_requestPasswordController setDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [i_requestPasswordController release];
}

- (void)awakeFromNib
{
    if ([[self document].fileURL path])
        [self.pathLabel setStringValue:[[self document].fileURL path]];
    [self.backupsController bind:NSContentArrayBinding toObject:self.document withKeyPath:@"backups" options:0];
}

- (void)requestPassword;
{
    [i_requestPasswordController showInWindow:self.window];
}

- (TSGDocument *)document
{
    return (TSGDocument *)[super document];
}

- (IBAction)deleteSelectedBackups:(id)theSender;
{
    NSArray *backupNames = [[self.backupsController selectedObjects] valueForKey:@"name"];
    if ([backupNames count] == 0)
        return;

    NSString *warning = nil;
    if ([backupNames count] == 1)
        warning = [NSString stringWithFormat:@"Are you sure you want to delete '%@'?", [backupNames objectAtIndex:0]];
    else
        warning = [NSString stringWithFormat:@"Are you sure you want to delete %lu backups?", [backupNames count]];

    NSAlert *alert = [NSAlert alertWithMessageText:warning defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"This action is irreversible"];
    alert.alertStyle = NSCriticalAlertStyle;
    CFRetain(backupNames);

    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(backupDeleteAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:(void *)backupNames];
}

- (void)backupDeleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    NSArray *selectedNames = (NSArray *)contextInfo;
    [[selectedNames retain] autorelease];
    CFRelease(selectedNames);
    
    if (returnCode == NSAlertAlternateReturn)
        return;
    
    [self.document deleteBackupsWithNames:selectedNames];
}

#pragma mark SubWindowController delegate methods

- (void)passwordRequestController:(TSGRequestPasswordWindowController *)theController FinishedWithPassword:(NSString *)thePassword;
{
    [self.document passwordEntered:thePassword];
}

@end
