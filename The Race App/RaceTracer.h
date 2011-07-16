//
//  LocationTracer.h
//  The Race App
//
//  Created by Matteo Manferdini on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class MKPointAnnotation;

@protocol RaceTracerDelegate;

@interface RaceTracer : NSObject <CLLocationManagerDelegate>

@property(nonatomic, retain) NSArray    * checkpoints;
@property(nonatomic, assign) NSUInteger   checkpointsLeft;

@property(nonatomic, assign) float        headingToNextCheckpoint;

- (id)initWithDelegate:(id<RaceTracerDelegate>)aDelegate;

- (void)startLocationServices;
- (void)startRace;
- (void)stopRace;

@property(nonatomic, retain, readonly) MKPointAnnotation * annotationForDebugTrace;
- (void)playDebugTrace;

@end

@protocol RaceTracerDelegate <NSObject>

- (void)raceTracer:(RaceTracer *)tracer gotFirstFix:(CLLocation *)userLocation;
- (void)raceTracer:(RaceTracer *)tracer reachedCheckpointAtIndex:(NSUInteger)checkpointReachedIdx;

- (void)raceTracerReachedStartPoint:(RaceTracer *)tracer;
- (void)raceTracerReachedEndPoint:(RaceTracer *)tracer;

@end
