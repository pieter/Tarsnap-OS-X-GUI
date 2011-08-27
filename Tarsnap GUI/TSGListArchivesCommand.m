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

#import "TSGStreamingArray.h"

@interface TSGListArchivesCommand ()
@property (retain) TSGStreamingArray *output;
@end

@implementation TSGListArchivesCommand

@synthesize output = i_output;

- (void)run;
{
    self.output = [[[TSGStreamingArray alloc] initWithSeparator:'\n'] autorelease];

    self.task = [[[NSTask alloc] init] autorelease];
    [self.task setLaunchPath:[[[self class] tarsnapLocation] path]];
    self.task.arguments = [NSArray arrayWithObjects:@"-v", @"--list-archives", @"--keyfile", [self.key.keyURL path], nil];

    NSPipe *outPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [outPipe fileHandleForReading];
    self.task.standardOutput = outPipe;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapDidSendOutput:) name:NSFileHandleReadCompletionNotification object:readHandle];
    [readHandle readInBackgroundAndNotify];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinished:) name:NSTaskDidTerminateNotification object:self.task];
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

- (void)tarsnapDidSendOutput:(NSNotification *)theNotification;
{
    NSData *newData = [[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self.output readData:newData];

    NSArray *newItems = [self.output nextItems];
    for (NSData *item in newItems) {
        NSString *outputString = [[[NSString alloc] initWithData:item encoding:NSISOLatin1StringEncoding] autorelease];
        // Skip small items, such as empty newlines.
        if ([outputString length] < 2)
            continue;

        NSArray *components = [outputString componentsSeparatedByString:@"\t"];
        NSString *name = [components objectAtIndex:0];
        NSString *dateStr = [components objectAtIndex:1];
        NSDate *date = [NSDate dateWithNaturalLanguageString:dateStr];
        TSGBackup *backupItem = [TSGBackup backupWithName:name date:date];
        [self.key command:self foundArchive:backupItem];
    }
    [[theNotification object] readInBackgroundAndNotify];
}

- (void)taskFinished:(NSNotification *)theNotification;
{
    [self.key commandFinishedListingArchives:self];
}

@end
