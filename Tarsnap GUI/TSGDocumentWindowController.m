//
//  TSGDocumentWindowController.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGDocumentWindowController.h"
#import "TSGRequestPasswordWindowController.h"
#import "TSGDocument.h"

@interface TSGDocumentWindowController ()
@property (retain) TSGRequestPasswordWindowController *requestPasswordController;
@end

@implementation TSGDocumentWindowController

@synthesize pathLabel = i_pathLabel;
@synthesize backupsController = i_backupsController;
@synthesize requestPasswordController = i_requestPasswordController;

- (id)init
{
    if (self = [super initWithWindowNibName:@"TSGDocument"]) {
        i_requestPasswordController = [[TSGRequestPasswordWindowController alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [i_requestPasswordController release];
}

- (void)awakeFromNib
{
    [self.pathLabel setStringValue:[[self document].fileURL path]];
    [self.backupsController bind:NSContentArrayBinding toObject:self.document withKeyPath:@"backups" options:0];
}

- (TSGDocument *)document
{
    return (TSGDocument *)[super document];
}

- (IBAction)deleteSelectedBackups:(id)theSender;
{
    NSLog(@"Auch!");
}
@end
