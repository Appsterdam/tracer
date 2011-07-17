//
//  GPSTracePlayer.m
//  The Race App
//
//  Created by Appsterdam on 16/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "GPSTracePlayer.h"

@interface GPSTracePlayer ()

@property(nonatomic, assign) BOOL             isPlaying;
@property(nonatomic, assign) NSUInteger       currentIndex;
@property(nonatomic, retain) NSDate         * currentTimestamp;
@property(nonatomic, assign) NSTimeInterval   logToPlayerStartDelta;

- (void)synthesizeNextEvent;

/* - */

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
@synthesize logToPlayerStartDelta;

- (CLLocationManager *)playerAsLocationManager;
{
	return (CLLocationManager *)self;
}

- (void)startPlayingTrace;
{
	self.isPlaying              = YES;
	self.currentIndex           = NSNotFound;
	self.currentTimestamp       = nil;
	self.logToPlayerStartDelta  = - [self.trace.startTime timeIntervalSinceNow];
	
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
	
	CLLocation * event            = [self.trace pointAtIndex:self.currentIndex];
	CLLocation * nextEvent        = [self nextEvent];
	CLLocation * timeRebasedEvent;;
	
	{
		timeRebasedEvent = [[CLLocation alloc] initWithCoordinate:event.coordinate
														 altitude:event.altitude
											   horizontalAccuracy:event.horizontalAccuracy
												 verticalAccuracy:event.verticalAccuracy
														timestamp:[event.timestamp dateByAddingTimeInterval:self.logToPlayerStartDelta]];
	}
	
	[self.delegate locationManager:self.playerAsLocationManager
			   didUpdateToLocation:timeRebasedEvent
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
