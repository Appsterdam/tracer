//
//  LocationTracer.m
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "LocationTracer.h"


@implementation LocationTracer

- (id)initWithDelegate:(id<LocationTracerDelegate>)aDelegate {
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

#pragma mark -
#pragma mark Public

- (void)startTrackingUserLocation {
	[locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!userLocated) {
		// Wait until we get a recent location, to filter out cached ones.
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		[delegate userLocationDetected:newLocation];
		userLocated = YES;
		return;
	}
}

@end
