//
//  TSGTarsnapKey.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGTarsnapKey.h"

#import "TSGCheckPasswordRequiredCommand.h"
#import "TSGVerifyPasswordCommand.h"

@interface TSGTarsnapKey ()
@property (readwrite, copy) NSString *password;
@end

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
    TSGCheckPasswordRequiredCommand *command = [[TSGCheckPasswordRequiredCommand alloc] initWithTarsnapKey:self]; // Leaking
    [command run];
}

- (void)testPassword:(NSString *)thePassword;
{
    NSLog(@"Going to test password: %@", thePassword);
    self.password = thePassword;
    
    TSGVerifyPasswordCommand *command = [[TSGVerifyPasswordCommand alloc] initWithTarsnapKey:self]; // Leaking
    [command run];
}

- (void)command:(TSGTarsnapCommand *)theCommand determinedPasswordRequired:(BOOL)thePasswordRequired;
{
    [self.delegate tarsnapKey:self requiresPassword:thePasswordRequired];
}

- (void)command:(TSGTarsnapCommand *)theCommand determinedPasswordValid:(BOOL)thePasswordValid;
{
    [self.delegate tarsnapKey:self acceptedPassword:thePasswordValid];
}

- (void)command:(TSGTarsnapCommand *)theCommand foundArchive:(TSGBackup *)theArchive;
{
    [self.delegate tarsnapKey:self foundArchive:theArchive];
}
- (void)commandFinishedListingArchives:(TSGTarsnapCommand *)theCommand;
{
    [self.delegate tarsnapKeyFinishedListingArchives:self];
}

@end
