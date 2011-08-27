//
//  TSGTarsnapCommand.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSGTarsnapKey;

@interface TSGTarsnapCommand : NSObject

@property (readonly, retain) TSGTarsnapKey *key;
@property (retain) NSTask *task;

- (id)initWithTarsnapKey:(TSGTarsnapKey *)theTarsnapKey;

+ (NSURL *)tarsnapLocation;
+ (NSURL *)tarsnapKeyManagementLocation;

- (void)run;
@end
