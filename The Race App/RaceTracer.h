//
//  LocationTracer.h
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol RaceTracerDelegate <NSObject>

- (void)userFirstLocationDetected:(CLLocation *)userLocation;
- (void)userMovedToNewLocation:(CLLocation *)newLocation;
- (void)usedChangedHeading:(CLHeading *)newHeading;

@end


@interface RaceTracer : NSObject <CLLocationManagerDelegate> {
	BOOL userLocated;
	id<RaceTracerDelegate> delegate;
	CLLocationManager *locationManager;
}

- (id)initWithDelegate:(id<RaceTracerDelegate>)aDelegate;
- (void)startTrackingUserLocation;
- (void)startTrackingUserHeading;
- (void)startRecordingUserLocation;
- (void)stopTrackingUserLocation;
- (void)stopTrackingUserHeading;

@end
