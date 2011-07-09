//
//  RaceViewController.m
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceViewController.h"


@implementation RaceViewController
@synthesize mapView;
@synthesize statsView;
@synthesize startButton;
@synthesize startLabel;

- (id)initWithCheckpoints:(NSArray *)points {
	if (![super init])
		return nil;
	checkpoints = [points retain];
	nextCheckpoint = [points objectAtIndex:0];
	return self;
}

- (void)dealloc {
	[nextCheckpoint release];
	[locationManager release];
	[mapView release];
	[statsView release];
	[startButton release];
	[startLabel release];
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
	[self setStatsView:nil];
	[self setStartButton:nil];
	[self setStartLabel:nil];
	[super viewDidUnload];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (!userLocated) {
		if ([newLocation.timestamp timeIntervalSinceNow] > 15)
			return;
		
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
			statsView.alpha = 1;
		}];
		return;
	}
	
	CLLocation *nextCheckpointLocation = [[[CLLocation alloc] initWithLatitude:nextCheckpoint.coordinate.latitude
																	 longitude:nextCheckpoint.coordinate.longitude] autorelease];
	CLLocationDistance distanceFromNextCheckPoint = [newLocation distanceFromLocation:nextCheckpointLocation];
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

@end
