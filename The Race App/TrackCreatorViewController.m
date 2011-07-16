//
//  TrackCreatorViewController.m
//  The Race App
//
//  Created by Robbert van Ginkel on 16-07-11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "TrackCreatorViewController.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"

@implementation TrackCreatorViewController
@synthesize mapView, tableView, coordinates, name;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.coordinates = [NSMutableArray array];
        
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTrack:)];
        [self.navigationItem setRightBarButtonItem:saveItem];
        [self.navigationItem rightBarButtonItem].enabled = NO;
        [saveItem release];
    }
    return self;
}

//Alertview is active when the view appears. If the user doesn't give in a track name pop the viewcontroller
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([((UITextField *)[alertView viewWithTag:99]).text length]==0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UITextField *txt = (UITextField *)[alertView viewWithTag:99];
        self.title = txt.text;
        
        [self.mapView setRegion:MKCoordinateRegionMake([[self.mapView userLocation] location].coordinate, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
    }
}

- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:{ //show Map
            [self.tableView setHidden:YES];
            [self.mapView setHidden:NO];
            [self.navigationItem rightBarButtonItem].enabled = NO;
        }
            break;
        case 1:{ //show Tableview
            [self.mapView setHidden:YES];
            [self.tableView setHidden:NO];
            [self.tableView reloadData];
            [self.navigationItem rightBarButtonItem].enabled = YES;
        }
            break;
        default:
            break;
    }
}

- (void)saveTrack:(id)sender {
    if ([self.coordinates count]<2) {
        UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle:@"Not enough checkpoints!" 
																		  message:@"Please create at least 2 checkpoints to proceed."
																		 delegate:nil
																cancelButtonTitle:@"Dismiss"
																otherButtonTitles:nil] autorelease];
		[errorAlert show];
		return;
    } else {
        //Save track and pass it on to some object.
        NSMutableArray *locationArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<[self.coordinates count]; i++) {
            DDAnnotation *ann = [self.coordinates objectAtIndex:i];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:ann.coordinate.latitude
                                                         longitude:ann.coordinate.longitude];
            [locationArray addObject:loc];
            [loc release];
        }
#warning Incomplete implementation! Still have to upload the LocationArray to server.
        [locationArray release];
    }
}

- (void)handleLongPress:(id)sender {
    UILongPressGestureRecognizer *gestureRecognizer = (UILongPressGestureRecognizer*)sender;
    if ([gestureRecognizer state]==UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        CLLocationCoordinate2D coord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:coord addressDictionary:nil] autorelease];
        annotation.title = [NSString stringWithFormat:@"Checkpoint: %d", [self.coordinates count]+1];;
        annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
        
        [self.mapView addAnnotation:annotation];
        [self.coordinates addObject:annotation];
        
        if (![self.tableView isHidden]) {
            [self.tableView reloadData];
        }
    }
}

//Tableview enter editmode
- (void)editTrack:(id)sender {
    [tableView setEditing: YES animated: YES];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
    [self.navigationItem setRightBarButtonItem:saveItem];
    [saveItem release];
}

- (void)doneEditing:(id)sender {
    [tableView setEditing: NO animated: YES];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTrack:)];
    [self.navigationItem setRightBarButtonItem:saveItem];
    [saveItem release];
}

- (IBAction)addPin:(id)sender {
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:[self.mapView centerCoordinate] addressDictionary:nil] autorelease];
	annotation.title = [NSString stringWithFormat:@"Checkpoint: %d", [self.coordinates count]+1];;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	
	[self.mapView addAnnotation:annotation];
    [self.coordinates addObject:annotation];
    
    if (![self.tableView isHidden]) {
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    [self.mapView release];
    [self.tableView release];
    [self.coordinates release];
    [self.name release];
    [super dealloc];
}


#pragma mark - 
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.coordinates count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.showsReorderControl = YES;
    }
    
    CLLocationCoordinate2D coordinate = ((DDAnnotation*)[self.coordinates objectAtIndex:[indexPath row]]).coordinate;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f %f", coordinate.latitude, coordinate.longitude];
    cell.textLabel.text = [NSString stringWithFormat:@"Checkpoint: %d", [indexPath row]+1];
    
    //Update the checkpoint number of the pin.
    ((DDAnnotation*)[self.coordinates objectAtIndex:[indexPath row]]).title = [NSString stringWithFormat:@"Checkpoint: %d", [indexPath row]+1];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    DDAnnotation *object = [[self.coordinates objectAtIndex:[fromIndexPath row]] retain];
    [self.coordinates removeObject:object];
	[self.coordinates insertObject:object atIndex:[toIndexPath row]];
    [object release];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.mapView removeAnnotation:[self.coordinates objectAtIndex:[indexPath row]]];
        [self.coordinates removeObjectAtIndex:[indexPath row]];
        [self.tableView reloadData]; 
    }

}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification {
	
	DDAnnotation *annotation = notification.object;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
        
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}		
	
	return draggablePinView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView setDelegate:self];
    
    
    //Add gesture recognizer to get notified when a user holds down his finger.
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
    [longPress release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
