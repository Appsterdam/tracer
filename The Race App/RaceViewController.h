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


@interface RaceViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	BOOL userLocated;
	NSArray *checkpoints;
	CLLocationManager *locationManager;
	MBProgressHUD *progressHUD;
	MKPointAnnotation *nextCheckpoint;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *startLabel;

- (id)initWithCheckpoints:(NSArray *)points;

@end
