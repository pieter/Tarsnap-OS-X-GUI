//
//  TSGCheckPasswordRequiredCommand.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGCheckPasswordRequiredCommand.h"
#import "TSGTarsnapKey.h"

@interface TSGCheckPasswordRequiredCommand ()
@property (assign) BOOL gotPasswordRequest;
@end

@implementation TSGCheckPasswordRequiredCommand

@synthesize  gotPasswordRequest = i_gotPasswordRequest;

- (void)run;
{
    self.task = [[[NSTask alloc] init] autorelease];
    [self.task setLaunchPath:[[[self class] tarsnapKeyManagementLocation] path]];
    [self.task setArguments:[NSArray arrayWithObjects: @"--outkeyfile", @"/tmp/emptykey", [self.key.keyURL path], nil]];
    
    NSPipe *stdErrPipe = [NSPipe pipe];
    NSFileHandle *handle = [stdErrPipe fileHandleForReading];
    self.task.standardError = stdErrPipe;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapDidFinish:) name:NSFileHandleReadCompletionNotification object:handle];
    [handle readInBackgroundAndNotify];
    
    [self.task launch];
}

- (void)tarsnapDidFinish:(NSNotification *)theNotification;
{
    NSData *data = [[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];

    NSString *text = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    if ([text hasPrefix:@"Please enter passphrase for keyfile"]) {
        self.gotPasswordRequest = YES;
    }
    
    [self.key command:self determinedPasswordRequired:self.gotPasswordRequest];
}

@end
