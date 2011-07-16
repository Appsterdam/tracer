//
//  RaceViewController.m
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceViewController.h"
#import "Trace.h"
#import "TraceOverlayView.h"
#import "GPSTracePlayer.h"

@interface RaceViewController ()

@property(nonatomic, retain) Trace             * currentTrace;
@property(nonatomic, retain) TraceOverlayView  * currentTraceView;

@property(nonatomic, retain) GPSTracePlayer    * tracePlayer;

@property(nonatomic, retain) MKPointAnnotation * ghostAnnotation;

- (void)userLocationDetected:(CLLocation *)newLocation;
- (void)userIsAtStartCheckPoint;
- (void)updateNextCheckpoint;
- (void)startStopwatch;
- (void)updateCheckpointsLabel;

@end


static NSUInteger CheckpointMetersThreshold = 15;

@implementation RaceViewController

@synthesize currentTrace;
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

@synthesize tracePlayer;
@synthesize ghostAnnotation;

- (id)initWithCheckpoints:(NSArray *)points {
	if (![super init])
		return nil;
	
	checkpoints = [points retain];
	nextCheckpoint = [points objectAtIndex:0];
	
	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
	
	self.tracePlayer = [[[GPSTracePlayer alloc] init] autorelease];
	
	return self;
}

- (void)dealloc {
	self.currentTrace = nil;
	self.currentTraceView = nil;

	self.saveTraceButton = nil;
	self.playTraceButton = nil;
	
	self.tracePlayer = nil;
	
	[locationManager release];
	[mapView release];
	[startRaceView release];
	[startButton release];
	[startLabel release];
	[raceStatsView release];
	[stopwatchLabel release];
	[checkpointsLabel release];
	[arrowImageView release];
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
	
    [locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
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

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	[self.currentTrace addPoint:newLocation];
	
	self.ghostAnnotation.coordinate = newLocation.coordinate;
	
	if (!userLocated) {
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		[self userLocationDetected:newLocation];
		return;
	}
	
	CLLocation *nextCheckpointLocation = [[[CLLocation alloc] initWithLatitude:nextCheckpoint.coordinate.latitude
																	 longitude:nextCheckpoint.coordinate.longitude] autorelease];
	distanceFromNextCheckpoint = [newLocation distanceFromLocation:nextCheckpointLocation];
	verticalDistanceFromNextCheckpoint = nextCheckpoint.coordinate.latitude - newLocation.coordinate.latitude;
	if (distanceFromNextCheckpoint > CheckpointMetersThreshold)
		return;
	
	MKPinAnnotationView *checkPointPinView = (MKPinAnnotationView *)[mapView viewForAnnotation:nextCheckpoint];
	if ([checkpoints indexOfObject:nextCheckpoint] == 0)
		[self userIsAtStartCheckPoint];
	
	if (!racing)
		return;
	
	checkPointPinView.pinColor = MKPinAnnotationColorGreen;
	if (nextCheckpoint == [checkpoints lastObject]) {
		UIAlertView *raceCompletedAlertView = [[[UIAlertView alloc] initWithTitle:@"Race completed!" 
																		  message:@"You did it!"
																		 delegate:nil
																cancelButtonTitle:@"Yes, I'm cool"
																otherButtonTitles:nil] autorelease];
		[raceCompletedAlertView show];
		[locationManager stopUpdatingLocation];
		[locationManager stopUpdatingHeading];
		return;
	}
	
	[self updateNextCheckpoint];
	[self updateCheckpointsLabel];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if (newHeading.headingAccuracy < 0)
		return;
	
	
	arrowImageView.transform = CGAffineTransformMakeRotation(-newHeading.trueHeading * M_PI / 180);
}

#pragma mark -
#pragma mark IBAction

- (IBAction)startRace:(id)sender {
	racing = YES;
	[self startStopwatch];
	[self updateCheckpointsLabel];
	
	raceStatsView.frame = startRaceView.frame;
	raceStatsView.transform = CGAffineTransformMakeTranslation(raceStatsView.frame.size.width, 0);
	[self.view addSubview:raceStatsView];
	[UIView animateWithDuration:0.5 animations:^(void) {
		raceStatsView.transform = CGAffineTransformIdentity;
		startRaceView.transform = CGAffineTransformMakeTranslation(-startRaceView.frame.size.width, 0);
	} completion:^(BOOL finished) {
		[startRaceView removeFromSuperview];
	}];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	// If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	if (annotation == self.ghostAnnotation)
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
		checkpointView.pinColor = MKPinAnnotationColorRed;
		checkpointView.animatesDrop = YES;
	}
	else
		checkpointView.annotation = annotation;
	
	return checkpointView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
{
	if (overlay == self.currentTrace) return self.currentTraceView;
	return nil;
}


#pragma mark -
#pragma mark Private

- (void)userLocationDetected:(CLLocation *)newLocation {
	userLocated = YES;
	[progressHUD hide:YES];
	CLLocationDistance maxDistanceFromUser = 0;
	for (MKPointAnnotation *checkpoint in checkpoints) {
		CLLocation *checkpointLocation = [[[CLLocation alloc] initWithLatitude:checkpoint.coordinate.latitude
																	 longitude:checkpoint.coordinate.longitude] autorelease];
		maxDistanceFromUser = MAX(maxDistanceFromUser, [newLocation distanceFromLocation:checkpointLocation]);
	}
	
	[mapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate,
														  maxDistanceFromUser * 2,
														  maxDistanceFromUser * 2)
			  animated:YES];
	[mapView addAnnotations:checkpoints];
	
	self.currentTrace     = [[[Trace alloc] init] autorelease];
	self.currentTraceView = [[[TraceOverlayView alloc] initWithOverlay:self.currentTrace] autorelease];
	
	[mapView addOverlay:self.currentTrace];
	
	[UIView animateWithDuration:1 animations:^(void) {
		startRaceView.alpha = 1;
	}];	
}

- (void)userIsAtStartCheckPoint {
	MKPointAnnotation *startAnnotation = [checkpoints objectAtIndex:0];
	MKPinAnnotationView *checkPointPinView = (MKPinAnnotationView *)[mapView viewForAnnotation:startAnnotation];
	checkPointPinView.pinColor = MKPinAnnotationColorGreen;
	[UIView animateWithDuration:1 animations:^(void) {
		startButton.alpha = 1;
		startLabel.alpha = 0;
	}];
	[self updateNextCheckpoint];
}

- (void)updateNextCheckpoint {
	nextCheckpoint = [checkpoints objectAtIndex:([checkpoints indexOfObject:nextCheckpoint] + 1)];
}

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

- (void)updateCheckpointsLabel {
	checkpointsLabel.text = [NSString stringWithFormat:@"%d Checkpoints to go", [checkpoints count] - [checkpoints indexOfObject:nextCheckpoint]];
}


- (IBAction)saveTrace:(id)sender;
{
	NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"trace"];
					   
	[NSKeyedArchiver archiveRootObject:self.currentTrace
								toFile:path];
}

- (IBAction)playTrace:(id)sender;
{
	[locationManager release];
	
	locationManager = [self.tracePlayer.playerAsLocationManager retain];
	locationManager.delegate = self;
	
	self.tracePlayer.trace = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"default-trace" ofType:nil]];
	
	[self.tracePlayer startPlayingTrace];
	
	self.ghostAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	[mapView addAnnotation:self.ghostAnnotation];
}

@end
