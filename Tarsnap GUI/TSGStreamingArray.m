//
//  TSGStreamingArray.m
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSGStreamingArray.h"

@interface TSGStreamingArray ()
@property (retain) NSMutableData *unusedData;
@end


@implementation TSGStreamingArray

@synthesize separator = i_separator;
@synthesize unusedData = i_unusedData;

- (id)initWithSeparator:(char)theSeparator;
{
    if ((self = [self init])) {
        i_separator = theSeparator;
        i_unusedData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)dealloc;
{
    [i_unusedData release];
    
    [super dealloc];
}

- (void)readData:(NSData *)theData;
{ 
    [self.unusedData appendData:theData];
}

- (NSData *)readNextItem;
{
    size_t dataIndex = 0;
    char const *bytes = (char const *)[self.unusedData bytes];
    for (dataIndex = 0; dataIndex < [self.unusedData length]; dataIndex++) {
        if (bytes[dataIndex] == self.separator) {
            // dataIndex is the separator. Everything before dataIndex should be returned.
            // everything after dataIndex (dataIndex+1) should remain in the data
            NSData *newData = [self.unusedData subdataWithRange:NSMakeRange(0, dataIndex)];
            [self.unusedData replaceBytesInRange:NSMakeRange(0, dataIndex+1) withBytes:NULL length:0];
            return newData;
        }
    }

    return nil;
}

- (NSArray *)nextItems;
{
    NSMutableArray *items = [NSMutableArray array];

    NSData *item = nil;
    while ((item = [self readNextItem]))
        [items addObject:item];
    
    return items;
}

@end
