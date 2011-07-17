//
//  RaceViewController.m
//  The Race App
//
//  Created by Appsterdam on 09/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "RaceViewController.h"
#import "Trace.h"
#import "TraceOverlayView.h"
#import "GPSTracePlayer.h"
#import "AppSpecificValues.h"

#define kPinNumberTag 343

@interface RaceViewController ()

@property(nonatomic, retain) TraceOverlayView  * currentTraceView;
@property(nonatomic, retain) MKPointAnnotation * ghostAnnotation;

- (void)startStopwatch;

@end

@implementation RaceViewController

@synthesize currentTraceView;
@synthesize mapView;
@synthesize startRaceView;
@synthesize startButton;
@synthesize startLabel;
@synthesize raceStatsView;
@synthesize stopwatchLabel;
@synthesize checkpointsLabel;
@synthesize arrowImageView;

@synthesize playTraceButton;
@synthesize saveTraceButton;

@synthesize ghostAnnotation;

@synthesize track;

- (id)initWithCheckpoints:(NSArray *)points {
	if (![super init])
		return nil;
	
	checkpoints = [points retain];
	raceTracer = [[RaceTracer alloc] initWithDelegate:self];
	raceTracer.checkpoints = checkpoints;
	
	return self;
}

- (void)dealloc {
	self.currentTraceView = nil;

	self.saveTraceButton = nil;
	self.playTraceButton = nil;
	
	[raceTracer release];
	[mapView release];
	[startRaceView release];
	[startButton release];
	[startLabel release];
	[raceStatsView release];
	[stopwatchLabel release];
	[checkpointsLabel release];
	[arrowImageView release];
    [track release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	progressHUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
	progressHUD.labelText = @"Getting your location";
	[self.view addSubview:progressHUD];
	[progressHUD show:YES];
	
	[raceTracer startLocationServices];
}

- (void)viewDidUnload {
	self.currentTraceView = nil;	
	self.saveTraceButton = nil;
	self.playTraceButton = nil;
	self.ghostAnnotation = nil;

	[self setMapView:nil];
	[self setStartRaceView:nil];
	[self setStartButton:nil];
	[self setStartLabel:nil];
	[self setRaceStatsView:nil];
	[self setStopwatchLabel:nil];
	[self setCheckpointsLabel:nil];
	[self setArrowImageView:nil];
	[super viewDidUnload];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    api = [[RaceApi alloc] init];
    [api setDelegate:self];
    
}

#pragma mark RaceAPI delegate
-(void)finishedRace:(NSDictionary *)_dict{
    NSLog(@"%@", _dict);
}
-(void)startedRace:(NSDictionary *)_dict{
    NSLog(@"%@", _dict);
}

#pragma mark -
#pragma mark LocationTracerDelegate

- (void)raceTracer:(RaceTracer *)tracer gotFirstFix:(CLLocation *)newLocation;
{
	[progressHUD hide:YES];
	
	[UIView animateWithDuration:1
					 animations:^{ startRaceView.alpha = 1; }];	
	
	{	
		CLLocationDistance maxDistanceFromUser = 0;
		
		for (MKPointAnnotation *checkpoint in checkpoints)
		{
			CLLocation *checkpointLocation = [[[CLLocation alloc] initWithLatitude:checkpoint.coordinate.latitude
																		 longitude:checkpoint.coordinate.longitude] autorelease];
			maxDistanceFromUser = MAX(maxDistanceFromUser, [newLocation distanceFromLocation:checkpointLocation]);
		}
		
		[mapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate,
															  maxDistanceFromUser * 2,
															  maxDistanceFromUser * 2)
				  animated:YES];
		
		[mapView addAnnotations:checkpoints];
	}	
}

- (void)raceTracer:(RaceTracer *)tracer reachedCheckpointAtIndex:(NSUInteger)checkpointReachedIdx;
{
	MKPointAnnotation   * startAnnotation   = [checkpoints objectAtIndex:checkpointReachedIdx];
	MKPinAnnotationView * checkPointPinView = (MKPinAnnotationView *)[mapView viewForAnnotation:startAnnotation];
	
	checkPointPinView.pinColor = MKPinAnnotationColorGreen;
    UIImageView *imgView = (UIImageView*)[checkPointPinView viewWithTag:kPinNumberTag];
    UIImage *newImage = [UIImage imageNamed:[NSString stringWithFormat:@"PinNumberGreen%d.png", checkpointReachedIdx+1]];
    [imgView setImage:newImage];
}

- (void)raceTracerReachedStartPoint:(RaceTracer *)tracer;
{
	MKPointAnnotation   * startAnnotation   = [checkpoints objectAtIndex:0];
	MKPinAnnotationView * checkPointPinView = (MKPinAnnotationView *)[mapView viewForAnnotation:startAnnotation];
	
	checkPointPinView.pinColor = MKPinAnnotationColorGreen;
    UIImageView * imgView = (UIImageView*)[checkPointPinView viewWithTag:kPinNumberTag];
    [imgView setImage:[UIImage imageNamed:@"PinNumberGreen1.png"]];
	
	[UIView animateWithDuration:1
					 animations:^{
						 startButton.alpha = 1;
						 startLabel.alpha = 0;
					 }];
}

- (void)raceTracerReachedEndPoint:(RaceTracer *)tracer;
{
    [api finishRaceWithTime:[NSNumber numberWithInt:stopwatchTime] andTrackURI:track.trackURI];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kDidFinshTrackNotifiction object:nil];
    
	[[[[UIAlertView alloc] initWithTitle:@"Race completed!" 
								 message:@"You did it!"
								delegate:nil
					   cancelButtonTitle:@"Yes, I'm cool"
					   otherButtonTitles:nil] autorelease] show];
}

- (void)raceTracer:(RaceTracer *)tracer didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
	MKMapRect dirtyMapRect = MKMapRectNull;
    
	{
		MKMapPoint newPoint = MKMapPointForCoordinate(newLocation.coordinate);
		MKMapPoint oldPoint = MKMapPointForCoordinate(oldLocation.coordinate);
        
		MKMapRect  oldRect  = MKMapRectMake(oldPoint.x, oldPoint.y, 0, 0);
		MKMapRect  newRect  = MKMapRectMake(newPoint.x, newPoint.y, 0, 0);
        
		dirtyMapRect = MKMapRectUnion(dirtyMapRect, oldRect);
		dirtyMapRect = MKMapRectUnion(dirtyMapRect, newRect);
	}
    
	{
		// There is a non null update rect.
		// Compute the currently visible map zoom scale
		MKZoomScale currentZoomScale = (CGFloat)(mapView.bounds.size.width / mapView.visibleMapRect.size.width);
		// Find out the line width at this zoom scale and outset the updateRect by that amount
		CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
		dirtyMapRect = MKMapRectInset(dirtyMapRect, -lineWidth, -lineWidth);
	}
    
	[self.currentTraceView setNeedsDisplayInMapRect:dirtyMapRect];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (object != raceTracer)
		return;
	
	if ([keyPath isEqualToString:@"checkpointsLeft"])
		checkpointsLabel.text = [NSString stringWithFormat:@"%d Checkpoints to go", raceTracer.checkpointsLeft];
	
	if ([keyPath isEqualToString:@"headingToNextCheckpoint"])
		arrowImageView.transform = CGAffineTransformMakeRotation(raceTracer.headingToNextCheckpoint);
}

#pragma mark -
#pragma mark IBAction

- (IBAction)startRace:(id)sender;
{
	[raceTracer startRace];
	
    
    [api startRaceWithTrackURI:track.trackStartURI andUsername:@"USERNAME"];
    
    
    
	[self startStopwatch];
	
	raceStatsView.frame = startRaceView.frame;
	raceStatsView.transform = CGAffineTransformMakeTranslation(raceStatsView.frame.size.width, 0);
	[self.view addSubview:raceStatsView];
	
	[UIView animateWithDuration:0.5
					 animations:^(void) {
									raceStatsView.transform = CGAffineTransformIdentity;
									startRaceView.transform = CGAffineTransformMakeTranslation(-startRaceView.frame.size.width, 0);
								}
					 completion:^(BOOL finished) {
									[startRaceView removeFromSuperview];
								}];
	
	[raceTracer addObserver:self
				 forKeyPath:@"checkpointsLeft"
					options:NSKeyValueObservingOptionInitial
					context:nil];

	[raceTracer addObserver:self
				 forKeyPath:@"headingToNextCheckpoint"
					options:NSKeyValueObservingOptionInitial
					context:nil];
	
	[self.mapView addOverlay:raceTracer.currentTrace];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	// If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	if (annotation == raceTracer.annotationForDebugTrace)
	{
		static NSString * ghostid = @"ghostid";
		MKPinAnnotationView * ghostView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:ghostid];
		
		if (ghostView == nil)
		{
			ghostView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
														 reuseIdentifier:ghostid] autorelease];
			ghostView.pinColor = MKPinAnnotationColorGreen;
		}
		
		return ghostView;
	}
	
	static NSString *checkpointViewIdentifier = @"checkpointViewIdentifier";
	MKPinAnnotationView *checkpointView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:checkpointViewIdentifier];
	if (!checkpointView) {
		checkpointView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:checkpointViewIdentifier] autorelease];
        
        NSUInteger index = [checkpoints indexOfObject:annotation];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"PinNumber%d.png", index+1]]];
        [image setFrame:CGRectMake(-1, -1, 17, 17)];
        [image setTag:kPinNumberTag];
        [checkpointView addSubview:image];
        [image release];
		checkpointView.pinColor = MKPinAnnotationColorRed;
		checkpointView.animatesDrop = YES;
	}
	else
		checkpointView.annotation = annotation;
	
	return checkpointView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
{
	if (overlay == raceTracer.currentTrace)
	{
		if (self.currentTraceView == nil)
			self.currentTraceView = [[[TraceOverlayView alloc] initWithOverlay:overlay] autorelease];
		
		return self.currentTraceView;
	}
	
	return nil;
}


#pragma mark -
#pragma mark Private

- (void)startStopwatch {
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(stopwatchTimerFired) userInfo:nil repeats:YES];
}

- (void)stopwatchTimerFired {
	stopwatchTime++;
	stopwatchLabel.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d.%d",
						   stopwatchTime / 36000,
						   (stopwatchTime / 600) % 60,
						   (stopwatchTime / 10) % 60,
						   stopwatchTime % 10];
}

- (IBAction)playTrace:(id)sender;
{
	[raceTracer playDebugTrace];
	[mapView addAnnotation:raceTracer.annotationForDebugTrace];
}

@end
