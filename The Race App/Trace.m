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
@end

@implementation Trace

@synthesize trace;
@synthesize delegate;
@synthesize coordinate;
@synthesize boundingMapRect;

- (id)init;
{
	if ((self = [super init]) == nil)
		return nil;
	
	self.trace = [NSMutableArray array];
	
	self.coordinate = (CLLocationCoordinate2D) { .latitude = 0, .longitude = 0 };
	self.boundingMapRect = (MKMapRect) { .origin = { .x = 0, .y = 0 }, .size = { .width = 0, .height = 0 } };
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
	[aCoder encodeObject:trace forKey:@"trace"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if ((self = [self init]) == nil)
		return nil;
	
	NSArray * thePoints = [aDecoder decodeObjectForKey:@"trace"];
	for (CLLocation * p in thePoints)
		[self addPoint:p];
	
    return self;
}

- (void)dealloc;
{
	self.trace = nil;
	[super dealloc];
}

- (NSUInteger)count;
{
	return self.trace.count;
}

- (void)addPoint:(CLLocation *)point;
{
	[self.trace addObject:point];
	//[self.delegate trace:self didAddPoint:point withTimestamp:timestamp];
}

- (CLLocation *)pointAtIndex:(NSUInteger)i;
{
	return [self.trace objectAtIndex:i];
}

- (NSDate *)startTime;
{
	if (self.trace.count == 0)
		return nil;
	
	return [[self pointAtIndex:0].timestamp copy];
}

- (NSDate *)endTime;
{
	if (self.trace.count == 0)
		return nil;
	
	return [[self pointAtIndex:self.trace.count - 1].timestamp copy];
}


@end
