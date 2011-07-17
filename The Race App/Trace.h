//
//  Trace.h
//  The Race App
//
//  Created by Appsterdam on 16/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Trace : NSObject <NSCoding, MKOverlay>

@property(nonatomic, readonly) NSUInteger count;

@property(nonatomic, readonly) NSDate * startTime;
@property(nonatomic, readonly) NSDate * endTime;

@property (nonatomic, assign)  CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)  MKMapRect              boundingMapRect;

- (void)addPoint:(CLLocation *)point;
- (CLLocation *)pointAtIndex:(NSUInteger)i;

- (void)lockForReading;
- (void)unlockForReading;

@end
