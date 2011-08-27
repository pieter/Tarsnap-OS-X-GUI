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

@end

@interface TSGTarsnapKey (InternalCallbacks)
- (void)command:(TSGTarsnapCommand *)theCommand determinedPasswordRequired:(BOOL)thePasswordRequired;
@end