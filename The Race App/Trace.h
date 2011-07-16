//
//  Trace.h
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol TraceDelegate;

@interface Trace : NSObject <NSCoding, MKOverlay>

@property(nonatomic, assign) id<TraceDelegate> delegate;

@property(nonatomic, readonly) NSUInteger count;

@property(nonatomic, readonly) NSDate * startTime;
@property(nonatomic, readonly) NSDate * endTime;

@property (nonatomic, assign)  CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)  MKMapRect              boundingMapRect;

- (void)addPoint:(CLLocation *)point;
- (CLLocation *)pointAtIndex:(NSUInteger)i;

@end


// Maybe not needed...
@protocol TraceDelegate <NSObject>

- (void)trace:(Trace *)trace didAddPoint:(CLLocation *) point withTimestamp:(NSDate *)timestamp;
			   
@end
