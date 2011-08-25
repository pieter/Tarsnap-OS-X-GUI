//
//  TSGBackup.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSGBackup : NSObject

@property (readonly, copy) NSString *name;
@property (readonly, copy) NSDate *dateCreated;

- (id)initWithName:(NSString *)theName date:(NSDate *)theDate;
+ (id)backupWithName:(NSString *)theName date:(NSDate *)theDate;
@end
