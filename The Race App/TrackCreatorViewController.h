//
//  TrackCreatorViewController.h
//  The Race App
//
//  Created by Robbert van Ginkel on 16-07-11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface TrackCreatorViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
    IBOutlet UITableView *tableView;
    
    NSMutableArray *coordinates;
    NSString *name;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *coordinates;
@property (nonatomic, retain) NSString *name;

- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)addPin:(id)sender;
- (IBAction)saveTrack:(id)sender;

@end