//
//  TSGDocument.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGDocument.h"
#import "TSGBackup.h"
#import "TSGBackupListLoader.h"
#import "TSGRequestPasswordWindowController.h"
#import "TSGDocumentWindowController.h"
#import "TSGTarsnapKey.h"

@interface TSGDocument ()
- (void)loadBackupData;

@property (readwrite, retain) NSArray *backups;
@property (readwrite, retain) TSGTarsnapKey *key;
@property (readwrite, retain) TSGBackupListLoader *loader;
@property (readwrite, assign, getter=isLoading) BOOL loading;

@property (retain) TSGDocumentWindowController *windowController;

@end

@implementation TSGDocument

@synthesize key = i_key;
@synthesize backups = i_backups;

@synthesize windowController = i_windowController;
@synthesize loader = i_loader;
@synthesize loading = i_loading;

- (void)makeWindowControllers
{
    // We currently only have one window controller
    self.windowController = [[[TSGDocumentWindowController alloc] init] autorelease];
    [self addWindowController:self.windowController];

    [self.key performPasswordRequiredCheck];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    if (![absoluteURL isFileURL]) {
        if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:readErr userInfo:[NSDictionary dictionaryWithObject:@"Unable to read from URL's" forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    
    self.key = [[[TSGTarsnapKey alloc] initWithKeyURL:self.fileURL] autorelease];
    self.key.delegate = self;

    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)loadBackupData;
{
    self.loader = [[[TSGBackupListLoader alloc] initWithKeyURL:self.fileURL] autorelease];
    self.backups = [NSArray array];
    [self.loader loadListWithItemCallback:^(TSGBackup *item) {
        self.backups = [self.backups arrayByAddingObject:item];
    } finishedCallback:^() {
        self.loader = nil;
        self.loading = NO;
    }];
    self.loading = YES;
}

- (IBAction)deleteBackupsWithNames:(NSArray *)theBackupNames;
{
    if ([theBackupNames count] == 0)
        return;

//    NSString *warning = nil;
//    if ([theBackupNames count] == 1)
//        warning = [NSString stringWithFormat:@"Are you sure you want to delete '%@'?", [selectedNames objectAtIndex:0]];
//    else
//        warning = [NSString stringWithFormat:@"Are you sure you want to delete %lu backups?", [selectedNames count]];
//
//    NSAlert *alert = [NSAlert alertWithMessageText:warning defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"This action is irreversible"];
//    alert.alertStyle = NSCriticalAlertStyle;
//    CFRetain(selectedNames);
//    [alert beginSheetModalForWindow:[[[self windowControllers] objectAtIndex:0] window] modalDelegate:self didEndSelector:@selector(backupDeleteAlertDidEnd:returnCode:contextInfo:) contextInfo:(void *)selectedNames];
}

- (void)backupDeleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    NSArray *selectedNames = (NSArray *)contextInfo;
    [[selectedNames retain] autorelease];
    CFRelease(selectedNames);
    
    if (returnCode == NSAlertAlternateReturn)
        return;
    
    NSLog(@"Deleting backups: %@", selectedNames);
    // TODO: Actually implement deleting the backups
}

- (void)dealloc;
{
    [i_loader release];
    
    [super dealloc];
}


#pragma Key delegate callbacks
- (void)tarsnapKey:(TSGTarsnapKey *)theKey requiresPassword:(BOOL)theRequiresPassword;
{
    if (!theRequiresPassword)
        [self loadBackupData];
    else {
        NSWindow *showWindow = [[self.windowControllers objectAtIndex:0] window];
        TSGRequestPasswordWindowController *wc = [[TSGRequestPasswordWindowController alloc] init]; // FIXME: leaking
        [wc showInWindow:showWindow];
    }
}

- (void)tarsnapKey:(TSGTarsnapKey *)theKey acceptedPassword:(BOOL)theAcceptedPassword;
{
    
}
@end
