//
//  TSGStreamingArray.h
//  Tarsnap GUI
//
//  Created by Pieter de Bie on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface TSGStreamingArray : NSObject

@property (readonly, assign) char separator;

- (id)initWithSeparator:(char)theSeparator;

- (void)readData:(NSData *)theData;
- (NSArray *)nextItems;

@end
