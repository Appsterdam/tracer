//
//  RaceViewController.h
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface RaceViewController : UIViewController <MKMapViewDelegate> {
	NSArray *checkpoints;
	MKMapView *mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (id)initWithCheckpoints:(NSArray *)points;

@end
