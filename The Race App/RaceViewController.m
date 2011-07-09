//
//  RaceViewController.m
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceViewController.h"


@interface RaceViewController (Private)

- (void)userLocationDetected:(CLLocation *)newLocation;
- (void)userIsAtStartCheckPoint;
- (void)updateNextCheckpoint;
- (void)startStopwatch;
- (void)updateCheckpointsLabel;

@end


static NSUInteger CheckpointMetersThreshold = 15;

@implementation RaceViewController
@synthesize mapView;
@synthesize startRaceView;
@synthesize startButton;
@synthesize startLabel;
@synthesize raceStatsView;
@synthesize stopwatchLabel;
@synthesize checkpointsLabel;

- (id)initWithCheckpoints:(NSArray *)points {
	if (![super init])
		return nil;
	checkpoints = [points retain];
	nextCheckpoint = [points objectAtIndex:0];
	return self;
}

- (void)dealloc {
	[locationManager release];
	[mapView release];
	[startRaceView release];
	[startButton release];
	[startLabel release];
	[raceStatsView release];
	[stopwatchLabel release];
	[checkpointsLabel release];
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
	
	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload {
	[self setMapView:nil];
	[self setStartRaceView:nil];
	[self setStartButton:nil];
	[self setStartLabel:nil];
	[self setRaceStatsView:nil];
	[self setStopwatchLabel:nil];
	[self setCheckpointsLabel:nil];
	[super viewDidUnload];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!userLocated) {
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		[self userLocationDetected:newLocation];
		return;
	}
	
	CLLocation *nextCheckpointLocation = [[[CLLocation alloc] initWithLatitude:nextCheckpoint.coordinate.latitude
																	 longitude:nextCheckpoint.coordinate.longitude] autorelease];
	CLLocationDistance distanceFromNextCheckPoint = [newLocation distanceFromLocation:nextCheckpointLocation];
	if (distanceFromNextCheckPoint > CheckpointMetersThreshold)
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
		[locationManager stopUpdatingHeading];
		return;
	}
	
	[self updateNextCheckpoint];
	[self updateCheckpointsLabel];
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

@end
