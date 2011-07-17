//
//  TrackCreatorViewController.h
//  The Race App
//
//  Created by Appsterdam on 16-07-11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
