//
//  LocationTracer.m
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceTracer.h"


@implementation RaceTracer

- (id)initWithDelegate:(id<LocationTracerDelegate>)aDelegate {
    if (![super init])
        return nil;
	
	delegate = aDelegate;
	trace = [[NSMutableArray array] retain];
	
	// Set up the location manager to track user position.
	// We want updates every meter to keep an accurate trace.
	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    return self;
}

- (void)dealloc {
    [trace release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)startTrackingUserLocation {
	[locationManager startUpdatingLocation];
}

- (void)startTrackingUserHeading {
	[locationManager startUpdatingHeading];
}

- (void)startRecordingUserLocation {
	
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
	[trace addObject:newLocation];
	[delegate userMovedToNewLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	// Discard inaccurate headings.
	if (newHeading.headingAccuracy < 0)
		return;
	[delegate usedChangedHeading:newHeading];
}

@end
