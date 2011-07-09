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

- (id)initWithCheckpoints:(NSArray *)points {
	if (![super init])
		return nil;
	checkpoints = [points retain];
	return self;
}

- (void)dealloc {
	[mapView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[mapView addAnnotations:checkpoints];
}

- (void)viewDidUnload {
	[self setMapView:nil];
	[super viewDidUnload];
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
