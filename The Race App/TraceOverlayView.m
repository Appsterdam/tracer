//
//  TraceOverlayView.m
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "TraceOverlayView.h"
#import "Trace.h"

@interface TraceOverlayView()
@property(nonatomic, retain) Trace * trace;
@end

@implementation TraceOverlayView

@synthesize trace;

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

- (void)addPoint:(CLLocation *)location;
{
	
}

@end
