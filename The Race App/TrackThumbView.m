//
//  TrackThumbView.m
//  The Race App
//
//  Created by Antonio Willy Malara on 17/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "TrackThumbView.h"
#import <Mapkit/Mapkit.h>

@implementation TrackThumbView

@synthesize track;

- (void)dealloc;
{
	self.track = nil;
	[super dealloc];
}

- (UIViewContentMode)contentMode;
{
	return UIViewContentModeRedraw;
}

- (void)setTrack:(Track *)aTrack;
{
	if (aTrack == track) return;
	[track autorelease];
	track = [aTrack retain];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
	NSUInteger   numberOfPoints = self.track.trackData.count;
	MKMapPoint * mapPoints  = (MKMapPoint *)malloc(numberOfPoints * sizeof(MKMapPoint));
	MKMapPoint   topLeft;
	MKMapPoint   bottomRight;
	
	for (int i = 0; i < numberOfPoints; i++)
	{
		CLLocation * loc = [self.track.trackData objectAtIndex:i];
		mapPoints[i] = MKMapPointForCoordinate(loc.coordinate);
		
		if (i == 0)
		{
			topLeft = mapPoints[i];
			bottomRight = mapPoints[i];
		}
		else
		{
			topLeft.x = MAX(mapPoints[i].x, topLeft.x);
			topLeft.y = MAX(mapPoints[i].y, topLeft.y);

			bottomRight.x = MIN(mapPoints[i].x, bottomRight.x);
			bottomRight.y = MIN(mapPoints[i].y, bottomRight.y);
		}
	}
	
	CGRect selfBounds = self.bounds;
	
	double viewScale = 0.6f;
	
	double xspan = topLeft.x - bottomRight.x;
	double yspan = topLeft.y - bottomRight.y;
	
	double mapToNormalizedFactor  = 1 / MAX( xspan, yspan);
	double normalizedToViewFactor = MIN(selfBounds.size.width, selfBounds.size.height) * viewScale;
	double mapToViewFactor        = mapToNormalizedFactor * normalizedToViewFactor;
	
	double xMarginOffset = (selfBounds.size.width  - (selfBounds.size.width  * viewScale)) / 2.0;
	double yMarginOffset = (selfBounds.size.height - (selfBounds.size.height * viewScale)) / 2.0;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (int i = 0; i < numberOfPoints; i++)
	{
		CGPoint point;
		point.x = (mapPoints[i].x - bottomRight.x) * mapToViewFactor + xMarginOffset;
		point.y = (mapPoints[i].y - bottomRight.y) * mapToViewFactor + yMarginOffset;
		
		if (i == 0)
			CGContextMoveToPoint(context, point.x, point.y);
		else
			CGContextAddLineToPoint(context, point.x, point.y);
	}
	
	CGContextSetLineWidth(context, 3);
	CGContextSetRGBStrokeColor(context, 0, 0, 1, 1);
	CGContextStrokePath(context);
	
	free(mapPoints);
}

@end
