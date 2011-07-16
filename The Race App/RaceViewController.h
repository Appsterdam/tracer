//
//  RaceViewController.h
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "RaceTracer.h"


@interface RaceViewController : UIViewController <MKMapViewDelegate, RaceTracerDelegate> {
	BOOL racing;
	NSUInteger stopwatchTime;
	NSArray *checkpoints;
	MBProgressHUD *progressHUD;
	RaceTracer *raceTracer;
	MKPointAnnotation *nextCheckpoint;
	CLLocationDistance distanceFromNextCheckpoint;
	float verticalDistanceFromNextCheckpoint;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *startRaceView;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *startLabel;
@property (nonatomic, retain) IBOutlet UIView *raceStatsView;
@property (nonatomic, retain) IBOutlet UILabel *stopwatchLabel;
@property (nonatomic, retain) IBOutlet UILabel *checkpointsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;

- (id)initWithCheckpoints:(NSArray *)points;
- (IBAction)startRace:(id)sender;

@end
