//
//  LocationTracer.m
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceTracer.h"


@implementation RaceTracer

- (id)initWithDelegate:(id<RaceTracerDelegate>)aDelegate {
    if (![super init])
        return nil;
	
	delegate = aDelegate;
	
	// Set up the location manager to track user position.
	// We want updates every meter to keep an accurate trace.
	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)startTrackingUserLocation {
	// We start tracking user location to guide him to the starting point in the race
	// but we don't record his trace because the race is not started yet.
	[locationManager startUpdatingLocation];
}

- (void)startTrackingUserHeading {
	[locationManager startUpdatingHeading];
}

- (void)startRecordingUserLocation {
	// Start recording user trace when the race starts.
}

- (void)stopTrackingUserLocation {
	[locationManager stopUpdatingLocation];
}

- (void)stopTrackingUserHeading {
	[locationManager stopUpdatingHeading];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!userLocated) {
		// Wait until we get a recent location, to filter out cached ones.
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		[delegate userFirstLocationDetected:newLocation];
		userLocated = YES;
		return;
	}
	
	// Save the new location in the trace and pass it to the delegate
	[delegate userMovedToNewLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	// Discard inaccurate headings.
	if (newHeading.headingAccuracy < 0)
		return;
	
	[delegate usedChangedHeading:newHeading];
}

@end
