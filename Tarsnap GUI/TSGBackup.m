//
//  TSGBackup.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGBackup.h"

@implementation TSGBackup

@synthesize name = i_name, dateCreated = i_dateCreated;

- (id)initWithName:(NSString *)theName date:(NSDate *)theDate;
{
    if ((self = [self init])) {
        i_name = [theName copy];
        i_dateCreated = [theDate copy];
    }
    
    return self;
}

+ (id)backupWithName:(NSString *)theName date:(NSDate *)theDate;
{
    return [[[self alloc] initWithName:theName date:theDate] autorelease];
}

@end
