//
//  Trace.m
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "Trace.h"

@interface Trace()
@property(nonatomic, retain) NSMutableArray * trace;
@property(nonatomic, retain) NSMutableArray * timestamps;
@end

@implementation Trace

@synthesize trace;
@synthesize timestamps;
@synthesize delegate;

- (id)init;
{
	if ((self = [super init]) == nil)
		return nil;
	
	
    return self;
}

- (void)dealloc;
{
	self.trace = nil;
	[super dealloc];
}


- (void)addPoint:(CLLocation *)point withTimestamp:(NSDate *)timestamp;
{
	[self.trace addObject:point];
	[self.timestamps addObject:timestamp];
	
	[self.delegate trace:self didAddPoint:point withTimestamp:timestamp];
}

- (NSDate *)startTime;
{
	if (self.timestamps.count == 0)
		return nil;
	
	return [[self.timestamps objectAtIndex:0] copy];
}

- (NSDate *)endTime;
{
	if (self.timestamps.count == 0)
		return nil;
	
	return [[self.timestamps lastObject] copy];
}

@end
