//
//  LoginViewController.m
//  The Race App
//
//  Created by Sergey Novitsky on 7/16/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "The_Race_AppAppDelegate.h"
#import "MBProgressHUD.h"
#import "RaceAppUser.h"

@interface LoginViewController ()

-(void)getUserInfo;

@property(nonatomic, retain) UIBarButtonItem*    loginBarButtonItem;
@property(nonatomic, retain) UIBarButtonItem*    logoutBarButtonItem;
@property(nonatomic, retain) Facebook*           faceBookApi;
@property(nonatomic, retain) FBRequest*          fbGetUserInfoRequest;

@end

@implementation LoginViewController

@synthesize loginBarButtonItem;
@synthesize logoutBarButtonItem;
@synthesize faceBookApi;
@synthesize fbGetUserInfoRequest;
@synthesize loggedInUser;
@synthesize loggedInUserInfoLabel;
@synthesize loginStatusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        UITabBarItem* ownTabBarItem = 
            [[[UITabBarItem alloc] initWithTitle:@"Login"
                                           image:[UIImage imageNamed:@"login_user.png"]
                                             tag:2] autorelease];
        
        //self.tabBarItem.
        // TODO: Please replace when icons are available!
        self.tabBarItem = ownTabBarItem;
        The_Race_AppAppDelegate* appDelegate = (The_Race_AppAppDelegate*)[UIApplication sharedApplication].delegate;
        self.faceBookApi = appDelegate.faceBookApi;
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
    UIView* ownView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = ownView;
    [ownView release];

    ownView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    ownView.clipsToBounds = YES;
    ownView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
}
*/

-(void)configureViewForLoggedInState:(BOOL)aLoggedIn
{
    if (!aLoggedIn)
    {
        self.navigationItem.rightBarButtonItem = loginBarButtonItem;
        self.loginStatusLabel.text = @"Not logged in";
        self.loggedInUserInfoLabel.text = nil;

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBExpirationDate"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:faceBookApi.accessToken forKey:@"FBAccessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:faceBookApi.expirationDate forKey:@"FBExpirationDate"];
        
        self.navigationItem.rightBarButtonItem = logoutBarButtonItem;
        self.loginStatusLabel.text = @"Logged In As";
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Login";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" 
                                                          style:UIBarButtonItemStyleBordered 
                                                         target:self 
                                                         action:@selector(loginToFaceBook)];
    
    logoutBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
                                                           style:UIBarButtonItemStyleBordered 
                                                          target:self 
                                                          action:@selector(logoutFromFaceBook)];
    
    BOOL loggedIn = [faceBookApi isSessionValid];
    [self configureViewForLoggedInState:loggedIn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([faceBookApi isSessionValid] && loggedInUser == nil)
    {
        // User has logged in to Facebook, now get their userId from Facebook
        [self getUserInfo];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loginBarButtonItem = nil;
    self.logoutBarButtonItem = nil;
    self.loggedInUserInfoLabel = nil;
    self.loginStatusLabel = nil;
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
    
    fbGetUserInfoRequest.delegate = nil;
    [fbGetUserInfoRequest release];
    
    [loggedInUser release];
    [faceBookApi release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark FaceBook

-(void)loginToFaceBook
{
    //arrayWithObjects:@"user_about_me", nil
    NSArray* fbPermissions = [NSArray array];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [faceBookApi authorize:fbPermissions delegate:self];
}

-(void)logoutFromFaceBook
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [faceBookApi logout:self];
}

-(void)getUserInfo
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.fbGetUserInfoRequest = [faceBookApi requestWithGraphPath:@"me" 
                               andDelegate:self];
}

- (void)fbDidLogin
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self configureViewForLoggedInState:YES];
    
    // User has logged in to Facebook, now get their userId from Facebook
    [self getUserInfo];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self configureViewForLoggedInState:NO];
}

- (void)fbDidLogout
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self configureViewForLoggedInState:NO];
}

-(void)request:(FBRequest *)aRequest didLoad:(id)result
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Loaded request: %@", [aRequest description]);
    if (aRequest == fbGetUserInfoRequest)
    {
        RaceAppUser* raceAppUser = [[[RaceAppUser alloc] init] autorelease];
        
        raceAppUser.faceBookUID = [result objectForKey:@"id"];
        raceAppUser.firstName = [result objectForKey:@"first_name"];
        raceAppUser.lastName = [result objectForKey:@"last_name"];
        raceAppUser.middleName = [result objectForKey:@"middle_name"];
        raceAppUser.homeTown = [[result objectForKey:@"hometown"] objectForKey:@"name"];
        
        self.loggedInUser = raceAppUser;
        self.fbGetUserInfoRequest = nil;
        
        // self.loggedInUserInfoLabel.text =
        NSMutableString* userInfoString = [NSMutableString stringWithCapacity:256];
        if (raceAppUser.firstName != nil && [raceAppUser.firstName length] > 0)
        {
            [userInfoString appendString:raceAppUser.firstName];
        }
        
        if ([userInfoString length] > 0)
        {
            [userInfoString appendString:@" "];
        }
        
        if (raceAppUser.lastName != nil && [raceAppUser.lastName length] > 0)
        {
            [userInfoString appendString:raceAppUser.lastName];
        }
        
        if (   [userInfoString length] > 0
            && raceAppUser.homeTown != nil
            && [raceAppUser.homeTown length] > 0)
        {
            [userInfoString appendFormat:@" from %@", raceAppUser.homeTown];
        }
        
        self.loggedInUserInfoLabel.text = userInfoString;
    }
}

-(void)request:(FBRequest *)aRequest didFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Could not load request: %@, error: %@", [aRequest description],
          [error localizedDescription]);
    
    if (aRequest == fbGetUserInfoRequest)
    {
        self.fbGetUserInfoRequest = nil;
        self.loggedInUserInfoLabel.text = nil;
    }
}



@end
