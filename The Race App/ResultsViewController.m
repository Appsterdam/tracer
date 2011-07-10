//
//  ResultViewController.m
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "ResultsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResultsViewController

@synthesize bestTimeLabel;
@synthesize bestResultNameLabel;
@synthesize resultTextLabel;
@synthesize ownTimeLabel;
@synthesize tableView;
@synthesize results;

-(NSArray*)makeHardcodedResults
{
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:5];
    
    [resultArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Peter", @"racerName", @"5:25", @"racerTime", nil]];
    [resultArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Matteo", @"racerName", @"5:51", @"racerTime", nil]];
    [resultArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Kate", @"racerName", @"6:04", @"racerTime", nil]];
    [resultArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sergey", @"racerName", @"6:07", @"racerTime", nil]];
    
    return resultArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        UITabBarItem* raceTracksItem = 
            [[[UITabBarItem alloc] initWithTitle:@"Results" 
                                          image:[UIImage imageNamed:@"trophy.png"] 
                                            tag:1] autorelease];
        
        self.tabBarItem = raceTracksItem;
        
        self.results = [self makeHardcodedResults];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.navigationItem.title = @"Results";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    tableView.layer.masksToBounds = YES;
    tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tableView.layer.borderWidth = 1.0;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [super viewDidLoad];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.ownTimeLabel = nil;
    self.bestTimeLabel = nil;
    self.bestResultNameLabel = nil;
    self.resultTextLabel = nil;
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
    
    [results release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"raceResultCell";
    
    UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    
    NSDictionary* result = [results objectAtIndex:indexPath.row];

    cell.textLabel.text = [result objectForKey:@"racerName"];
    cell.detailTextLabel.text = [result objectForKey:@"racerTime"];
     
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)updateDataWithResults:(NSArray*)aResults
{
    self.results = aResults;
    [tableView reloadData];
    [super dataSourceDidFinishLoadingNewData:[NSDate date]];
}

#pragma mark -
#pragma mark Reloading

- (void)reloadTableViewDataSource
{
    // [api getTracksAsynchronous];
    [super dataSourceDidFinishLoadingNewData:[NSDate date]];
}




@end
