//
//  TSGBackupListLoader.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGListArchivesCommand.h"

#import "TSGTarsnapKey.h"
#import "TSGBackup.h"

@implementation TSGListArchivesCommand

- (void)run;
{
    self.task = [[[NSTask alloc] init] autorelease];
    [self.task setLaunchPath:[[[self class] tarsnapLocation] path]];
    self.task.arguments = [NSArray arrayWithObjects:@"-v", @"--list-archives", @"--keyfile", [self.key.keyURL path], nil];

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

    if (self.key.password) {
        self.task.standardInput = [NSPipe pipe];
        [[self.task.standardInput fileHandleForWriting] writeData:[self.key.password dataUsingEncoding:NSUTF8StringEncoding]];
        [[self.task.standardInput fileHandleForWriting] closeFile];
    }

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
    }

}

- (void)tarsnapDidFinish:(NSNotification *)theNotification;
{
    NSData *theData = [[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *dataAsString = [[[NSString alloc] initWithData:theData encoding:NSISOLatin1StringEncoding] autorelease];
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
        [self.key command:self foundArchive:backupItem];
    }
    [self.key commandFinishedListingArchives:self];
}

@end
