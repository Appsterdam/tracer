//
//  RaceTracksViewController.m
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceTracksViewController.h"
#import "RaceTrackTableViewCell.h"
#import "RaceViewController.h"
#import "Track.h"
#import "MBProgressHUD.h"


@implementation RaceTracksViewController
@synthesize tableView;
@synthesize tracks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        UITabBarItem* raceTracksItem = [[[UITabBarItem alloc] initWithTitle:@"Tracks" 
                                                                      image:[UIImage imageNamed:@"racemap.png"] 
                                                                        tag:0] autorelease];
        
        self.tabBarItem = raceTracksItem;
        self.tracks = [NSArray array];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - instance methods
-(void)getTracksFromAPI
{
    [api getTracks];
}
#pragma mark - api delegate
-(void)gotResponse:(NSArray *)_arr
{
    [self performSelectorOnMainThread:@selector(updateDataWithTracks:) withObject:_arr waitUntilDone:NO];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView* ownView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ownView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    ownView.clipsToBounds = YES;
    ownView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    self.view = ownView;

    tableView = [[UITableView alloc] initWithFrame:self.view.bounds 
                                             style:UITableViewStylePlain];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.clipsToBounds = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60.0;
    
    [self.view addSubview:tableView];

}

-(void)makeHardcodedTracks
{
    NSMutableArray* raceTrackArray = [NSMutableArray arrayWithCapacity:5];

    for (int i = 0; i < 20; ++i)
    {
        NSMutableDictionary* trackDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
        [trackDictionary setObject:[NSString stringWithFormat:@"Test Track %d", i] forKey:@"trackName"];
        [raceTrackArray addObject:trackDictionary];
        [trackDictionary release];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Race Tracks";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.tabBarItem = self.tabBarItem;
    
    
    //create a pretty hud
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"Loading tracks...";
    hud.animationType = MBProgressHUDAnimationZoom;
    [self.view addSubview:hud];
    
    //api
    api = [[RaceApi alloc] init];
    [api setDelegate:self];
    [hud showWhileExecuting:@selector(getTracksFromAPI) onTarget:self withObject:nil animated:YES];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [hud release];
    [api release];

    tableView.delegate = nil;
    tableView.dataSource = nil;
    
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)dealloc
{
    if (self.isViewLoaded)
    {
        [self viewDidUnload];
    }

    [tracks release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tracks count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"raceTrackCell";
    
    RaceTrackTableViewCell* cell = (RaceTrackTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil)
    {
        cell = [[[RaceTrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    Track* track = [tracks objectAtIndex:indexPath.row];
    cell.trackNameLabel.text = track.trackName;
    cell.winnerNameLabel.text = track.trackWinner;
    cell.winnerTimeLabel.text = track.trackScore;
    cell.checkPointCountLabel = [NSString stringWithFormat:@"%d checkpoints", [track.trackData count]];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
	MKPointAnnotation *startPointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	startPointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376416, 4.922218);
	MKPointAnnotation *checkpointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	checkpointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376962, 4.922468);
	MKPointAnnotation *endPointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	endPointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376627, 4.922283);
	NSArray *checkpoints = [NSArray arrayWithObjects:
							startPointAnnotation,
							checkpointAnnotation,
							endPointAnnotation, 
							nil];
	
	RaceViewController *raceController = [[[RaceViewController alloc] initWithCheckpoints:checkpoints] autorelease];
	[self.navigationController pushViewController:raceController animated:YES];
}

-(void)updateDataWithTracks:(NSArray*)aTracks
{
    self.tracks = aTracks;
    [tableView reloadData];
    [super dataSourceDidFinishLoadingNewData:[NSDate date]];
}

#pragma mark -
#pragma mark Reloading

- (void)reloadTableViewDataSource
{
    [api getTracksAsynchronous];
}


@end
