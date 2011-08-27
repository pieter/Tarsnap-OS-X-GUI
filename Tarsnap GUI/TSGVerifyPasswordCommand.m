//
//  TSGVerifyPasswordCommand.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGVerifyPasswordCommand.h"
#import "TSGTarsnapKey.h"

@implementation TSGVerifyPasswordCommand

- (void)run;
{
    NSParameterAssert(self.key.password);

    self.task = [[[NSTask alloc] init] autorelease];
    [self.task setLaunchPath:[[[self class] tarsnapKeyManagementLocation] path]];
    [self.task setArguments:[NSArray arrayWithObjects: @"--outkeyfile", @"/tmp/emptykey", [self.key.keyURL path], nil]];
    
    self.task.standardInput = [NSPipe pipe];
    [[self.task.standardInput fileHandleForWriting] writeData:[self.key.password dataUsingEncoding:NSUTF8StringEncoding]];
    [[self.task.standardInput fileHandleForWriting] closeFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tarsnapCommandFinished:) name:NSTaskDidTerminateNotification object:self.task];
    [self.task launch];
}

- (void)tarsnapCommandFinished:(NSNotification *)theNotification;
{
    NSTask *originalTask = [theNotification object];
    [self.key command:self determinedPasswordValid:[originalTask terminationStatus] == 0];
}

@end
