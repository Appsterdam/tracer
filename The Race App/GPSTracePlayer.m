//
//  GPSTracePlayer.m
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "GPSTracePlayer.h"

@interface GPSTracePlayer ()

@property(nonatomic, assign) BOOL         isPlaying;
@property(nonatomic, assign) NSUInteger   currentIndex;
@property(nonatomic, retain) NSDate     * currentTimestamp;

- (void)synthesizeNextEvent;

@property(nonatomic, assign) CLLocationAccuracy desiredAccuracy;
@property(nonatomic, assign) CLLocationDistance distanceFilter;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;


@end


@implementation GPSTracePlayer

@synthesize trace;

@synthesize isPlaying;
@synthesize currentIndex;
@synthesize currentTimestamp;

- (CLLocationManager *)playerAsLocationManager;
{
	return (CLLocationManager *)self;
}

- (void)startPlayingTrace;
{
	self.isPlaying        = YES;
	self.currentIndex     = NSNotFound;
	self.currentTimestamp = nil;
	
	[self synthesizeNextEvent];	
}

- (CLLocation *)nextEvent;
{
	NSUInteger nextEventIndex = self.currentIndex + 1;
	if (nextEventIndex == self.trace.count)
		return nil;
	
	return [self.trace pointAtIndex:nextEventIndex];
}

- (void)synthesizeNextEvent;
{
	self.currentIndex = (self.currentIndex == NSNotFound) ? 0 : self.currentIndex + 1;
	
	if (self.currentIndex == self.trace.count - 1)
	{
		self.isPlaying = NO;
		return;
	}
	
	CLLocation * event     = [self.trace pointAtIndex:self.currentIndex];
	CLLocation * nextEvent = [self nextEvent];
	
	[self.delegate locationManager:self.playerAsLocationManager
			   didUpdateToLocation:event
					  fromLocation:nil]; // we don't use it, so...
	
	if (nextEvent != nil)
	{
		NSTimeInterval delta = [nextEvent.timestamp timeIntervalSinceDate:event.timestamp];
		[self performSelector:@selector(synthesizeNextEvent)
				   withObject:nil
				   afterDelay:delta];
	}
}

@synthesize desiredAccuracy;
@synthesize delegate;
@synthesize distanceFilter;

- (void)startUpdatingLocation; { }
- (void)stopUpdatingLocation;  { }
- (void)startUpdatingHeading;  { }
- (void)stopUpdatingHeading;   { }

@end
