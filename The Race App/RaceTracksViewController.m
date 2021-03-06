//
//  RaceTracksViewController.m
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "RaceTracksViewController.h"
#import "RaceTrackTableViewCell.h"
#import "RaceViewController.h"
#import "Track.h"
#import "MBProgressHUD.h"
#import "TrackCreatorViewController.h"


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
    [api getTracksAsynchronousAround:@"Amsterdam"];
}
#pragma mark - api delegate
-(void)gotResponse:(NSArray *)_arr forRequest:(RaceRequestType)_type{
    [self performSelectorOnMainThread:@selector(updateDataWithTracks:) withObject:_arr waitUntilDone:NO];
}
-(void)gotError:(NSError *)_err forRequest:(RaceRequestType)_type{
    
}
-(void)gotTracks:(NSArray *)_arr{
    self.tracks = _arr;
    [tableView reloadData];
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
    [ownView release];

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Race Tracks";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.tabBarItem = self.tabBarItem;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newTrack:)];
    [self.navigationItem setRightBarButtonItem:addItem];
    [addItem release];
    
		
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


- (void)newTrack:(id)sender {
    TrackCreatorViewController *creationController = [[TrackCreatorViewController alloc] initWithNibName:@"TrackCreatorViewController" bundle:nil];
    [creationController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:creationController animated:YES];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name your track" message:@"\n"
                                                           delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    UITextField *textField= [[UITextField alloc] initWithFrame:CGRectMake(16,42,252,25)];
    textField.font = [UIFont systemFontOfSize:18];
    textField.backgroundColor = [UIColor whiteColor];
    textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    textField.borderStyle = UITextBorderStyleLine;
    [textField setTag:99];
    
    [textField becomeFirstResponder];
    [alert addSubview:textField];
    [textField release];
    [alert show];
    [alert setTransform:CGAffineTransformMakeTranslation(0,99)];
    [alert setDelegate:creationController];
    [alert release];
    [creationController release];
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
    cell.trackThumbnail.track = track;
	
//#warning "Hardcoded!"
//    cell.checkPointCountLabel.text = [NSString stringWithFormat:@"%d checkpoints",
//                                      indexPath.row + 3/*[track.trackData count]*/];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
	NSMutableArray *checkpoints = [[NSMutableArray alloc] init];
    for (CLLocation *loc in [[tracks objectAtIndex:indexPath.row] trackData]) {
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = loc.coordinate;
        [checkpoints addObject:annot];
        [annot release];
        annot = nil;
    }
	RaceViewController *raceController = [[[RaceViewController alloc] initWithCheckpoints:checkpoints] autorelease];
    raceController.track = [tracks objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:raceController animated:YES];
}

-(void)updateDataWithTracks:(NSArray*)aTracks
{
#warning "API results are NOT used. Hardcoded data is used instead!"
    //self.tracks = aTracks;
    
    [tableView reloadData];
    [super dataSourceDidFinishLoadingNewData:[NSDate date]];
}

#pragma mark -
#pragma mark Reloading

- (void)reloadTableViewDataSource
{
    [api getTracksAsynchronousAround:@"Amsterdam"];
}


@end
