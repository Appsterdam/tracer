//
//  The_Race_AppAppDelegate.m
//  The Race App
//
//  Created by Appsterdam on 09/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <MapKit/MapKit.h>
#import "The_Race_AppAppDelegate.h"
#import "RaceTracksViewController.h"
#import "ResultsViewController.h"
#import "LoginViewController.h"
#import "FBConnect.h"
#import "GameCenterManager.h"

#import "RaceApi.h"

#define RACE_APP_FACEBOOK_APP_ID @"198763226840194"


@implementation The_Race_AppAppDelegate

@synthesize window=_window;
@synthesize tabBarController;
@synthesize faceBookApi;
@synthesize gameCenterManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    faceBookApi = [[Facebook alloc] initWithAppId:RACE_APP_FACEBOOK_APP_ID];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* accessToken = [userDefaults objectForKey:@"FBAccessToken"];
    NSDate* expirationDate = [userDefaults objectForKey:@"FBExpirationDate"];

    faceBookApi.accessToken = accessToken;
    faceBookApi.expirationDate = expirationDate;
    
    if([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager= [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate: self];
		[self.gameCenterManager authenticateLocalUser];
		
	}
	else
	{
		//[self showAlertWithTitle: @"Game Center Support Required!"
		//				 message: @"The current device does not support Game Center, which this game requires."];
        UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"Game Center Support Required!" message: @"The current device does not support Game Center, which this game requires." 
                                                       delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] autorelease];
        [alert show];
	}
    
    RaceTracksViewController* raceTrackViewController =
       [[[RaceTracksViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
	UINavigationController* raceTrackNavigationController = [[[UINavigationController alloc] initWithRootViewController:raceTrackViewController] autorelease];

    raceTrackNavigationController.tabBarItem = 
        raceTrackViewController.tabBarItem;
    
    ResultsViewController* resultsViewController =
        [[[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil] autorelease];
    
    UINavigationController* resultsNavigationController =
        [[[UINavigationController alloc] initWithRootViewController:resultsViewController] autorelease];
        
    resultsNavigationController.tabBarItem =
        resultsViewController.tabBarItem;
        
    // -------------------------- Login
    LoginViewController* loginViewController =
        [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    
    UINavigationController* loginNavigationController =
        [[[UINavigationController alloc] initWithRootViewController:loginViewController] autorelease];
    
    loginNavigationController.tabBarItem = loginViewController.tabBarItem;
    
	NSArray* viewControllers = 
	[NSArray arrayWithObjects:raceTrackNavigationController, 
	 resultsNavigationController, 
	 loginNavigationController,
	 nil];
	
    tabBarController.viewControllers = viewControllers;
	
	self.window.rootViewController = tabBarController;
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

- (void)dealloc
{
	[_window release];
    [tabBarController release];
    [faceBookApi release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark FaceBook

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL handled = [faceBookApi handleOpenURL:url];
    return handled;
}

@end
