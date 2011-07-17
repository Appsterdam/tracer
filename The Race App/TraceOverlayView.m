//
//  TraceOverlayView.m
//  The Race App
//
//  Created by Antonio Willy Malara on 16/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "TraceOverlayView.h"

static inline BOOL    LineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r);
static inline CGFloat pow2(CGFloat a);

@interface TraceOverlayView()

@property(nonatomic, retain) Trace * trace;

- (CGPathRef)newPathWithClipRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale;

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
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);
    
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    
    [self.trace lockForReading];
    CGPathRef path = [self newPathWithClipRect:clipRect
								  zoomScale:zoomScale];
    [self.trace unlockForReading];
    
    if (path != nil)
    {
        CGContextAddPath(context, path);
        CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 0.5f);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }	
}

- (CGPathRef)newPathWithClipRect:(MKMapRect)mapRect
					   zoomScale:(MKZoomScale)zoomScale;
{
	static double MinimumPointDistance = 5.0f;
	
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.  
    // While it is possible to just add all the points and let CoreGraphics 
    // handle clipping and flatness, it is much faster to do it yourself:
    //
	
    if (self.trace.count < 2)
        return NULL;
    
    CGMutablePathRef path      = NULL;
    BOOL             needsMove = YES;
        
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
	
    double minPointDelta = MinimumPointDistance / zoomScale;
    double c2 = pow2(minPointDelta);
    
	CLLocationCoordinate2D pointCoordinate = [self.trace pointAtIndex:0].coordinate;
    MKMapPoint point, lastPoint = MKMapPointForCoordinate(pointCoordinate);
    NSUInteger i;
	
    for (i = 1; i < self.trace.count - 1; i++)
    {
		pointCoordinate = [self.trace pointAtIndex:i].coordinate;
		point = MKMapPointForCoordinate(pointCoordinate);
		
        double a2b2 = pow2(point.x - lastPoint.x) + pow2(point.y - lastPoint.y);
		
        if (a2b2 >= c2)
		{
            if (LineIntersectsRect(point, lastPoint, mapRect))
            {
                if (!path) 
                    path = CGPathCreateMutable();
                if (needsMove)
                {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
				
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
            }
            else
            {
                // discontinuity, lift the pen
                needsMove = YES;
            }
			
            lastPoint = point;
        }
    }
	
    // If the last line segment intersects the mapRect at all, add it unconditionally
	pointCoordinate = [self.trace pointAtIndex:self.trace.count - 1].coordinate;
	point = MKMapPointForCoordinate(pointCoordinate);
	
    if (LineIntersectsRect(lastPoint, point, mapRect))
    {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove)
        {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
		
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

@end

static inline BOOL LineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

static inline CGFloat pow2(CGFloat a)
{
	return a * a;
}
