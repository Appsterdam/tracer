//
//  TraceOverlayView.m
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "TraceOverlayView.h"

@interface TraceOverlayView() <TraceDelegate>
@property(nonatomic, retain) Trace * trace;
@end

@implementation TraceOverlayView

@synthesize trace;

- (id)initForTrace:(Trace *)theTrace;
{
	if ((self = [super init]) == nil)
		return nil;
	
	self.trace = theTrace;
	theTrace.delegate = self;
	
    return self;
}

- (void)dealloc;
{
	self.trace = nil;
	[super dealloc];
}

// maybe not needed...
- (void)trace:(Trace *)trace didAddPoint:(CLLocation *)point withTimestamp:(NSDate *)timestamp;
{

}

@end
