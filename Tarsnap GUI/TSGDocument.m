//
//  TSGDocument.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGDocument.h"
#import "TSGBackup.h"
#import "TSGListArchivesCommand.h"
#import "TSGRequestPasswordWindowController.h"
#import "TSGDocumentWindowController.h"
#import "TSGTarsnapKey.h"

@interface TSGDocument ()
- (void)loadBackupData;

@property (readwrite, retain) NSArray *backups;
@property (readwrite, retain) TSGTarsnapKey *key;
@property (readwrite, retain) TSGListArchivesCommand *loader;
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
    self.loader = [[TSGListArchivesCommand alloc] initWithTarsnapKey:self.key];
    self.backups = [NSArray array];
    [self.loader run];
    self.loading = YES;
}

- (IBAction)deleteBackupsWithNames:(NSArray *)theBackupNames;
{
    if ([theBackupNames count] == 0)
        return;
    
    NSLog(@"Would delete backups with names: %@", theBackupNames);
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
        [[self windowController] requestPassword];
    }
}

- (void)passwordEntered:(NSString *)thePassword;
{
    [self.key testPassword:thePassword];
}

- (void)tarsnapKey:(TSGTarsnapKey *)theKey acceptedPassword:(BOOL)theAcceptedPassword;
{
    if (!theAcceptedPassword)
        NSLog(@"Password input failed");
    else {
        NSLog(@"Password entered successfully!");
        [self loadBackupData];
    }
}

@end
