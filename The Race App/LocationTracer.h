//
//  LocationTracer.h
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol LocationTracerDelegate <NSObject>

- (void)userLocationDetected:(CLLocation *)userLocation;

@end


@interface LocationTracer : NSObject <CLLocationManagerDelegate> {
	BOOL userLocated;
	id<LocationTracerDelegate> delegate;
	CLLocationManager *locationManager;
}

- (void)startTrackingUserLocation;

@end
