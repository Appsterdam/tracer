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
@synthesize mapView, tableView, coordinates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.coordinates = [NSMutableArray array];
        
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTrack:)];
        [self.navigationItem setRightBarButtonItem:saveItem];
        [saveItem release];
    }
    return self;
}

- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:{
            [self.tableView setHidden:YES];
            [self.mapView setHidden:NO];
        }
            break;
        case 1:{
            [self.mapView setHidden:YES];
            [self.tableView setHidden:NO];
            [self.tableView reloadData];
        }
            break;
        default:
            break;
    }
}

- (IBAction)addPin:(id)sender {
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:[[self.mapView userLocation]location].coordinate addressDictionary:nil] autorelease];
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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.coordinates count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    CLLocationCoordinate2D coordinate = ((DDAnnotation*)[self.coordinates objectAtIndex:[indexPath row]]).coordinate;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f %f", coordinate.latitude, coordinate.longitude];
    cell.textLabel.text = ((DDAnnotation*)[self.coordinates objectAtIndex:[indexPath row]]).title;
    
    return cell;
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
    [self.mapView setCenterCoordinate:[[self.mapView userLocation]location].coordinate];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
