//
//  TSGTarsnapCommand.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGTarsnapCommand.h"
#import "TSGTarsnapKey.h"

static NSString * const Tarsnap_Location = @"/usr/local/bin/";

@interface TSGTarsnapCommand ()
@property (readwrite, retain) TSGTarsnapKey *key;
@end

@implementation TSGTarsnapCommand

@synthesize key = i_key, task = i_task;

- (id)initWithTarsnapKey:(TSGTarsnapKey *)theTarsnapKey;
{
    
    if ((self = [self init])) {
        i_key = [theTarsnapKey retain];
    }
    
    return self;
}

- (void)dealloc;
{
    NSLog(@"Deallocing command: %@", self);
    [i_key release];
    [i_task release];
    
    [super dealloc];
}

+ (NSURL *)tarsnapLocation;
{
    return [[NSURL fileURLWithPath:Tarsnap_Location] URLByAppendingPathComponent:@"tarsnap"];
}

+ (NSURL *)tarsnapKeyManagementLocation;
{
    return [[NSURL fileURLWithPath:Tarsnap_Location] URLByAppendingPathComponent:@"tarsnap-keymgmt"];
}

- (void)run;
{
    // Don't do anything yet, do something in the subclass
}

@end
