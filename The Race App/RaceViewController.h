//
//  RaceViewController.h
//  The Race App
//
//  Created by Appsterdam on 09/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
	CLLocationDistance distanceFromNextCheckpoint;
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

@property (nonatomic, retain) IBOutlet UIButton * saveTraceButton;
@property (nonatomic, retain) IBOutlet UIButton * playTraceButton;

- (IBAction)playTrace:(id)sender;

@end
