//
//  LocationTracer.m
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceTracer.h"
#import "Trace.h"
#import "GPSTracePlayer.h"
#import <MapKit/MapKit.h>

static NSUInteger CheckpointMetersThreshold = 15;

@interface RaceTracer ()

@property(nonatomic, assign) BOOL                     userLocated;
@property(nonatomic, assign) BOOL                     racing;

@property(nonatomic, assign) id<RaceTracerDelegate>   delegate;
@property(nonatomic, retain) CLLocationManager      * locationManager;
@property(nonatomic, retain) Trace                  * currentTrace;
@property(nonatomic, retain) GPSTracePlayer         * tracePlayer;

@property(nonatomic, assign)   NSUInteger             checkpointToPassIndex;
@property(nonatomic, readonly) MKPointAnnotation    * checkpointToPass;

@property(nonatomic, retain)   MKPointAnnotation    * annotationForDebugTrace;

- (void)incrementCheckpointToPass;

@end

@implementation RaceTracer

@synthesize userLocated;
@synthesize delegate;
@synthesize locationManager;
@synthesize currentTrace;
@synthesize tracePlayer;
@synthesize checkpoints;
@synthesize checkpointToPassIndex;
@synthesize checkpointsLeft;
@synthesize headingToNextCheckpoint;
@synthesize racing;
@synthesize annotationForDebugTrace;

- (id)initWithDelegate:(id<RaceTracerDelegate>)aDelegate;
{
    if (![super init])
        return nil;
	
	self.delegate = aDelegate;
	
	// Set up the location manager to track user position.
	// We want updates every meter to keep an accurate trace.
	self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1;
	
	// Set up trace "simulator" with a default trace.
	self.tracePlayer = [[[GPSTracePlayer alloc] init] autorelease];
	self.tracePlayer.trace = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"default-trace"
																										ofType:nil]];
	
    return self;
}

- (void)dealloc;
{
	self.locationManager = nil;
	self.tracePlayer = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)startLocationServices;
{
	// We start tracking user location to guide him to the starting point in the race
	// but we don't record his trace because the race is not started yet.

	[self.locationManager startUpdatingLocation];
	[self.locationManager startUpdatingHeading];
}

- (void)startRace;
{
	self.racing = YES;
	self.checkpointsLeft = self.checkpoints.count;
	[self incrementCheckpointToPass];
}

- (void)stopRace;
{
	// Stop location services
	
	[self.locationManager stopUpdatingLocation];
	[self.locationManager stopUpdatingHeading];
	
	self.racing = NO;
}

- (void)playDebugTrace;
{
	self.tracePlayer.playerAsLocationManager.delegate = self;
	self.annotationForDebugTrace = [[[MKPointAnnotation alloc] init] autorelease];
	[self.tracePlayer startPlayingTrace];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
	if (self.annotationForDebugTrace != nil)
		self.annotationForDebugTrace.coordinate = newLocation.coordinate;
	
	if (!self.userLocated)
	{
		// Wait until we get a recent location, to filter out cached ones.
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		
		[self.delegate raceTracer:self gotFirstFix:newLocation];
		self.userLocated = YES;
		
		return;
	}
	
	// -------
	
	CLLocation * checkpointLocation = [[[CLLocation alloc] initWithLatitude:self.checkpointToPass.coordinate.latitude
																  longitude:self.checkpointToPass.coordinate.longitude] autorelease];
	
	CLLocationDistance distanceToNextCheckpoint = [newLocation distanceFromLocation:checkpointLocation];
	
	if (distanceToNextCheckpoint > CheckpointMetersThreshold)
		return;
	
	// REACHED CHECKPOINT
	
	if (self.checkpointToPassIndex == 0)
		[self.delegate raceTracerReachedStartPoint:self];
	
	if (self.racing == YES)
	{
		if (self.checkpointToPass == [checkpoints lastObject])
		{
			[self.delegate raceTracerReachedStartPoint:self];
			[self stopRace];
		}
		else
		{
			[self.delegate raceTracer:self reachedCheckpointAtIndex:self.checkpointToPassIndex];
			[self incrementCheckpointToPass];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	// Discard inaccurate headings.
	if (newHeading.headingAccuracy < 0)
		return;
	
	self.headingToNextCheckpoint = -newHeading.trueHeading * M_PI / 180;
}

- (MKPointAnnotation *)checkpointToPass;
{
	return [self.checkpoints objectAtIndex:self.checkpointToPassIndex];
}

- (void)incrementCheckpointToPass;
{
	self.checkpointToPassIndex = self.checkpointToPassIndex + 1;
	self.checkpointsLeft       = self.checkpointsLeft - 1;
}

@end
