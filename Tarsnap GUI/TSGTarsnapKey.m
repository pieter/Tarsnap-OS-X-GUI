//
//  TSGTarsnapKey.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGTarsnapKey.h"
#import "TSGCheckPasswordRequiredCommand.h"
@implementation TSGTarsnapKey

@synthesize delegate = i_delegate, keyURL = i_keyURL, password = i_password;

- (id)initWithKeyURL:(NSURL *)theKeyURL;
{
    if ((self = [self init])) {
        i_keyURL = [theKeyURL copy];
    }
    
    return self;
}

- (void)dealloc;
{
    i_delegate = nil;
    [i_keyURL release];
    [i_password release];
    
    [super dealloc];
}

- (void)performPasswordRequiredCheck;
{
    TSGCheckPasswordRequiredCommand *command = [[TSGCheckPasswordRequiredCommand alloc] initWithTarsnapKey:self];
    [command run];
}

- (void)testPassword:(NSString *)thePassword;
{
    
}


@end
