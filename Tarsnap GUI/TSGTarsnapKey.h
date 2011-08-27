//
//  TSGTarsnapKey.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSGTarsnapKeyDelegate;
@class TSGTarsnapCommand;
@class TSGBackup;

@interface TSGTarsnapKey : NSObject

@property (readwrite, assign) id<TSGTarsnapKeyDelegate> delegate;
@property (readonly, copy) NSURL *keyURL;
@property (readonly, copy) NSString *password;

- (id)initWithKeyURL:(NSURL *)theKeyURL;

- (void)performPasswordRequiredCheck;
- (void)testPassword:(NSString *)thePassword;

@end

@protocol TSGTarsnapKeyDelegate <NSObject>

- (void)tarsnapKey:(TSGTarsnapKey *)theKey requiresPassword:(BOOL)theRequiresPassword;
- (void)tarsnapKey:(TSGTarsnapKey *)theKey acceptedPassword:(BOOL)theAcceptedPassword;

- (void)tarsnapKey:(TSGTarsnapKey *)theKey foundArchive:(TSGBackup *)theArchive;
- (void)tarsnapKeyFinishedListingArchives:(TSGTarsnapKey *)theKey;
@end

@interface TSGTarsnapKey (InternalCallbacks)
- (void)command:(TSGTarsnapCommand *)theCommand determinedPasswordRequired:(BOOL)thePasswordRequired;
- (void)command:(TSGTarsnapCommand *)theCommand determinedPasswordValid:(BOOL)thePasswordValid;

- (void)command:(TSGTarsnapCommand *)theCommand foundArchive:(TSGBackup *)theArchive;
- (void)commandFinishedListingArchives:(TSGTarsnapCommand *)theCommand;
@end