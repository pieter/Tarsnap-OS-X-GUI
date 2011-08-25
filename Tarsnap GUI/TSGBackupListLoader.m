//
//  TSGBackupListLoader.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGBackupListLoader.h"

// TODO: Automatically locate tarsnap, or ship it with the app
static NSString * const TARSNAP_LOCATION = @"/usr/local/bin/tarsnap";

@interface TSGBackupListLoader ()

@property (readonly, copy) NSURL *keyURL;
@property (readwrite, copy) TSGBackupListLoaderCallback callback;
@end

@implementation TSGBackupListLoader

@synthesize keyURL = i_keyURL, callback = i_callback;

- (id)initWithKeyURL:(NSURL *)theKeyURL;
{
    if ((self = [self init])) {
        i_keyURL = [theKeyURL copy];
    }
    
    return self;
}

- (void)loadListWithCallback:(TSGBackupListLoaderCallback)theCallback;
{
    self.callback = theCallback;
    NSTask *task = [[[NSTask alloc] init] autorelease];
    task.launchPath = TARSNAP_LOCATION;
    task.arguments = [NSArray arrayWithObjects:@"-v", @"--list-archives", @"--keyfile", [self.keyURL path], nil];
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *readHandle = [pipe fileHandleForReading];
    task.standardOutput = pipe;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapDidFinish:) name:NSFileHandleReadToEndOfFileCompletionNotification object:readHandle];
    
    // TODO: Handle incremental loading of backup names
    [readHandle readToEndOfFileInBackgroundAndNotify];
    [task launch];
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

        self.callback(backupItem);
    }
    self.callback = nil;
}

- (void)dealloc;
{
    [i_keyURL release];
    [i_callback release];
    
    [super dealloc];
}
@end
