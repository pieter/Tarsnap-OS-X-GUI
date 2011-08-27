//
//  TSGBackupListLoader.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGListArchivesCommand.h"

// TODO: Automatically locate tarsnap, or ship it with the app
static NSString * const TARSNAP_LOCATION = @"/usr/local/bin/tarsnap";

@interface TSGListArchivesCommand ()

@property (readonly, copy) NSURL *keyURL;
@property (readwrite, copy) TSGBackupListLoaderCallback itemCallback;
@property (readwrite, copy) TSGBackupListLoaderFinishedCallback finishedCallback;

@property (retain) NSTask *task;
@end

@implementation TSGListArchivesCommand

@synthesize keyURL = i_keyURL, itemCallback = i_callback, finishedCallback = i_finishedCallback, task = i_task;

- (id)initWithKeyURL:(NSURL *)theKeyURL;
{
    if ((self = [self init])) {
        i_keyURL = [theKeyURL copy];
    }
    
    return self;
}

- (void)loadListWithItemCallback:(TSGBackupListLoaderCallback)theItemCallback finishedCallback:(TSGBackupListLoaderFinishedCallback)theFinishedCallback;
{

    self.itemCallback = theItemCallback;
    self.finishedCallback = theFinishedCallback;
    self.task = [[[NSTask alloc] init] autorelease];
    self.task.launchPath = TARSNAP_LOCATION;
    self.task.arguments = [NSArray arrayWithObjects:@"-v", @"--list-archives", @"--keyfile", [self.keyURL path], nil];

    NSPipe *outPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [outPipe fileHandleForReading];
    self.task.standardOutput = outPipe;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapDidFinish:) name:NSFileHandleReadToEndOfFileCompletionNotification object:readHandle];
    // TODO: Handle incremental loading of backup names
    [readHandle readToEndOfFileInBackgroundAndNotify];
    
    NSPipe *errorPipe = [NSPipe pipe];
    NSFileHandle *errorHandle = [errorPipe fileHandleForReading];
    self.task.standardError = errorPipe;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapDidSendError:) name:NSFileHandleReadCompletionNotification object:errorHandle];
    [errorHandle readInBackgroundAndNotify];

    self.task.standardInput = [NSPipe pipe];
    NSData *outData = [@"hoihoi" dataUsingEncoding:NSISOLatin1StringEncoding];
    [[self.task.standardInput fileHandleForWriting] writeData:outData];
    [[self.task.standardInput fileHandleForWriting] closeFile];

    NSLog(@"Launching task!");
    [self.task launch];
}

- (void)tarsnapDidSendError:(NSNotification *)theNotification;
{
    NSData *data = [[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSLog(@"Did send error! Data: %@, class: %@", data, [data class]);
    NSString *errorString = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease]; // Chose latin1 because it supports all data
    if (errorString && [errorString length] > 0) {
        NSLog(@"Received an error: %@", errorString);
        if ([errorString hasPrefix:@"Please enter passphrase for keyfile"]) {
            NSLog(@"The warning asks for a password! Handle: %@", self.task.standardInput);
//            [[(NSPipe *)self.task.standardInput fileHandleForWriting] writeData:outData];
            
        }
    }

}

- (void)tarsnapDidFinish:(NSNotification *)theNotification;
{
    NSData *theData = [[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *dataAsString = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
    // FIXME: handle potential errors here, such as not conforming to NSUTF8StringEncoding
    
    NSArray *items = [dataAsString componentsSeparatedByString:@"\n"];
    for (NSString *item in items) {
        // Skip small items, such as empty newlines.
        if ([item length] < 2)
            continue;

        NSArray *components = [item componentsSeparatedByString:@"\t"];
        NSString *name = [components objectAtIndex:0];
        NSString *dateStr = [components objectAtIndex:1];
        NSDate *date = [NSDate dateWithNaturalLanguageString:dateStr];
        TSGBackup *backupItem = [TSGBackup backupWithName:name date:date];

        self.itemCallback(backupItem);
    }
    [[self retain] autorelease];
    self.finishedCallback();
    self.itemCallback = nil;
    self.finishedCallback = nil;
}

- (void)dealloc;
{
    [i_keyURL release];
    [i_callback release];
    [i_finishedCallback release];
    
    [super dealloc];
}
@end
