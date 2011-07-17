//
//  TraceOverlayView.m
//  The Race App
//
//  Created by Appsterdam on 16/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "TraceOverlayView.h"

@interface TraceOverlayView() <TraceDelegate>
@property(nonatomic, retain) Trace * trace;
@end

@implementation TraceOverlayView

@synthesize trace;

- (id)initWithOverlay:(id<MKOverlay>)overlay
{
	if ((self = [super init]) == nil)
		return nil;
	
	self.trace = (Trace *)overlay;
	
    return self;
}

- (void)dealloc;
{
	self.trace = nil;
	[super dealloc];
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;
{
	// TODO: cull points
	
	for (NSInteger i = 0; i < self.trace.count; i++)
	{
		CLLocationCoordinate2D coord    = [self.trace pointAtIndex:i].coordinate;
		MKMapPoint             mapPoint = MKMapPointForCoordinate(coord);
		CGPoint                point    = [self pointForMapPoint:mapPoint];
		
		if (i == 0)
			CGContextMoveToPoint(context, point.x, point.y);
		else
			CGContextAddLineToPoint(context, point.x, point.y);
	}
	
	CGAffineTransform t = CGContextGetCTM(context);
	CGContextSetLineWidth(context, 1 / t.a * 5);
	
	CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
	CGContextStrokePath(context);
}

// maybe not needed...
- (void)trace:(Trace *)trace didAddPoint:(CLLocation *)point withTimestamp:(NSDate *)timestamp;
{

}

@end
