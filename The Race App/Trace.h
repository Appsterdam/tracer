//
//  Trace.h
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol TraceDelegate;

@interface Trace : NSObject

@property(nonatomic, assign) id<TraceDelegate> delegate;

@property(nonatomic, readonly) NSDate * startTime;
@property(nonatomic, readonly) NSDate * endTime;

- (void)addPoint:(CLLocation *)point withTimestamp:(NSDate *)timestamp;

@end

@protocol TraceDelegate <NSObject>

- (void)trace:(Trace *)trace didAddPoint:(CLLocation *) point withTimestamp:(NSDate *)timestamp;
			   
@end
