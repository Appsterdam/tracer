//
//  GPSTracePlayer.h
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Trace.h"

@interface GPSTracePlayer : NSObject

@property(nonatomic, assign) id<CLLocationManagerDelegate> delegate;
@property(nonatomic, retain) Trace * trace;
@property(nonatomic, readonly) CLLocationManager * playerAsLocationManager;
@property(nonatomic, assign, readonly) BOOL isPlaying;

- (void)startPlayingTrace;

@end
