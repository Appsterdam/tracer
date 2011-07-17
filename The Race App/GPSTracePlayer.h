//
//  GPSTracePlayer.h
//  The Race App
//
//  Created by Appsterdam on 16/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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