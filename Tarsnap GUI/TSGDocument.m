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

@interface TSGDocument ()
- (void)loadBackupData;
@property (readwrite, retain) TSGBackupListLoader *loader;
@end

@implementation TSGDocument

@synthesize backupsController = i_backupsController, loader = i_loader;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"TSGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    [self loadBackupData];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    if (![absoluteURL isFileURL]) {
        if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:readErr userInfo:[NSDictionary dictionaryWithObject:@"Unable to read from URL's" forKey:NSLocalizedDescriptionKey]];
        return NO;
    }
    
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)loadBackupData;
{
    NSLog(@"Loading backups :), %@", self.backupsController);
    self.loader = [[[TSGBackupListLoader alloc] initWithKeyURL:self.fileURL] autorelease];
    [self.loader loadListWithCallback:^(TSGBackup *item) {
        NSLog(@"Got item: %@", item);
        [self.backupsController addObject:item]; 
    }];
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
}
@end
