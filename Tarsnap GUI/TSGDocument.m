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
#import "TSGTarsnapKey.h"

@interface TSGDocument ()
- (void)loadBackupData;

@property (readwrite, retain) TSGTarsnapKey *key;
@property (readwrite, retain) TSGBackupListLoader *loader;
@property (readwrite, assign, getter=isLoading) BOOL loading;


@end

@implementation TSGDocument

@synthesize backupsController = i_backupsController, loader = i_loader, loading = i_loading, key = i_key;

- (NSString *)windowNibName
{
    return @"TSGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    [self.key performPasswordRequiredCheck];
//    [self loadBackupData];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    if (![absoluteURL isFileURL]) {
        if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:readErr userInfo:[NSDictionary dictionaryWithObject:@"Unable to read from URL's" forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    
    self.key = [[[TSGTarsnapKey alloc] initWithKeyURL:self.fileURL] autorelease];
    
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)loadBackupData;
{
    self.loader = [[[TSGBackupListLoader alloc] initWithKeyURL:self.fileURL] autorelease];
    
    [self.loader loadListWithItemCallback:^(TSGBackup *item) {
        [self.backupsController addObject:item]; 
    } finishedCallback:^() {
        self.loader = nil;
        self.loading = NO;
    }];
    self.loading = YES;
}

- (IBAction)deleteSelectedBackups:(id)theSender;
{
    NSArray *selectedBackups = [self.backupsController selectedObjects];
    NSArray *selectedNames = [selectedBackups valueForKey:@"name"];
    if ([selectedNames count] == 0)
        return;

    NSString *warning = nil;
    if ([selectedNames count] == 1)
        warning = [NSString stringWithFormat:@"Are you sure you want to delete '%@'?", [selectedNames objectAtIndex:0]];
    else
        warning = [NSString stringWithFormat:@"Are you sure you want to delete %lu backups?", [selectedNames count]];

    NSAlert *alert = [NSAlert alertWithMessageText:warning defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"This action is irreversible"];
    alert.alertStyle = NSCriticalAlertStyle;
    CFRetain(selectedNames);
    [alert beginSheetModalForWindow:[[[self windowControllers] objectAtIndex:0] window] modalDelegate:self didEndSelector:@selector(backupDeleteAlertDidEnd:returnCode:contextInfo:) contextInfo:(void *)selectedNames];
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
@end
