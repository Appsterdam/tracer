//
//  Trace.m
//  The Race App
//
//  Created by Appsterdam on 16/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "Trace.h"
#import <pthread.h>

@interface Trace()
@property(nonatomic, retain)   NSMutableArray   * trace;
@property(nonatomic, assign)   pthread_rwlock_t   _rwLock;
@property(nonatomic, readonly) pthread_rwlock_t * lock;
@end

@implementation Trace

@synthesize trace;
@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize _rwLock;

- (id)init;
{
	if ((self = [super init]) == nil)
		return nil;
	
	self.trace = [NSMutableArray array];
	
	self.coordinate      = (CLLocationCoordinate2D) { .latitude = 0, .longitude = 0 };
	self.boundingMapRect = MKMapRectNull;
	pthread_rwlock_init(self.lock, NULL);
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
	[aCoder encodeObject:trace forKey:@"trace"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if ((self = [self init]) == nil)
		return nil;
	
	NSArray * thePoints = [aDecoder decodeObjectForKey:@"trace"];
	for (CLLocation * p in thePoints)
		[self addPoint:p];
	
    return self;
}

- (void)dealloc;
{
	self.trace = nil;
	[super dealloc];
}

- (NSUInteger)count;
{
	return self.trace.count;
}

- (void)addPoint:(CLLocation *)point;
{	
	[self lockForReading];

	[self.trace addObject:point];
	
	if (0)
	{
		MKMapPoint mapPoint  = MKMapPointForCoordinate(point.coordinate);
		MKMapRect  pointRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0, 0);
		
		if (MKMapRectIsNull(self.boundingMapRect) == YES)
		{
			self.boundingMapRect = pointRect;
		}
		else
		{
			MKMapRect extended   = MKMapRectUnion(self.boundingMapRect, pointRect);
			self.boundingMapRect = extended;
		}
		
		self.coordinate = point.coordinate;
	}
	
	if (MKMapRectIsNull(self.boundingMapRect) == YES)
	{
		// bite off up to 1/4 of the world to draw into.
		
        MKMapPoint origin = MKMapPointForCoordinate(point.coordinate);
		
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
		
        self.boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        self.boundingMapRect = MKMapRectIntersection(self.boundingMapRect, worldRect);
	}
	
	[self unlockForReading];
}

- (CLLocation *)pointAtIndex:(NSUInteger)i;
{
	return [self.trace objectAtIndex:i];
}

- (NSDate *)startTime;
{
	if (self.trace.count == 0)
		return nil;
	
	return [[self pointAtIndex:0].timestamp copy];
}

- (NSDate *)endTime;
{
	if (self.trace.count == 0)
		return nil;
	
	return [[self pointAtIndex:self.trace.count - 1].timestamp copy];
}

- (MKMapRect)boundingMapRect;
{
	return boundingMapRect;
}

- (void)lockForReading
{
    pthread_rwlock_rdlock(self.lock);
}

- (void)unlockForReading
{
    pthread_rwlock_unlock(self.lock);
}

- (pthread_rwlock_t *)lock;
{
	return &(_rwLock);
}

@end
