//
//  TSGDocument.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TSGTarsnapKey.h"

@interface TSGDocument : NSDocument<TSGTarsnapKeyDelegate> {
}

@property (readonly, retain) NSArray *backups;
@property (readonly, retain) TSGTarsnapKey *key;
@property (readonly, assign, getter=isLoading) BOOL loading;

- (IBAction)deleteBackupsWithNames:(NSArray *)theBackupNames;

- (void)passwordEntered:(NSString *)thePassword;

@end
