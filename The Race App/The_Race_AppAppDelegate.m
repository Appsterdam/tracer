//
//  The_Race_AppAppDelegate.m
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//


#import <MapKit/MapKit.h>
#import "The_Race_AppAppDelegate.h"
#import "RaceTracksViewController.h"
#import "ResultsViewController.h"
#import "LoginViewController.h"
#import "FBConnect.h"

#define RACE_APP_FACEBOOK_APP_ID @"198763226840194"


#if USEGAMEKIT
    #import "GameKitHelpers/GameKitHelper.h"
#endif

@implementation The_Race_AppAppDelegate

@synthesize window=_window;
@synthesize tabBarController;
@synthesize faceBookApi;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    faceBookApi = [[Facebook alloc] initWithAppId:RACE_APP_FACEBOOK_APP_ID];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* accessToken = [userDefaults objectForKey:@"FBAccessToken"];
    NSDate* expirationDate = [userDefaults objectForKey:@"FBExpirationDate"];

    faceBookApi.accessToken = accessToken;
    faceBookApi.expirationDate = expirationDate;
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:2];
    
    RaceTracksViewController* raceTrackViewController =
       [[[RaceTracksViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
	UINavigationController* raceTrackNavigationController = [[[UINavigationController alloc] initWithRootViewController:raceTrackViewController] autorelease];

    raceTrackNavigationController.tabBarItem = 
        raceTrackViewController.tabBarItem;

    [viewControllers addObject:raceTrackNavigationController];    
    
    ResultsViewController* resultsViewController =
        [[[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil] autorelease];
    
    UINavigationController* resultsNavigationController =
        [[[UINavigationController alloc] initWithRootViewController:resultsViewController] autorelease];
    
    [viewControllers addObject:resultsNavigationController];
    
    resultsNavigationController.tabBarItem =
        resultsViewController.tabBarItem;
        
    // -------------------------- Login
    LoginViewController* loginViewController =
        [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    
    UINavigationController* loginNavigationController =
        [[[UINavigationController alloc] initWithRootViewController:loginViewController] autorelease];
    
    loginNavigationController.tabBarItem = loginViewController.tabBarItem;
    
    [viewControllers addObject:loginNavigationController];

#if USEGAMEKIT
    
    if ([GameKitHelper isGameCenterAPIAvailable]) {
        [self authenticateLocalPlayer];
        UIViewController* gameCenterViewController = [[[UIViewController alloc] init] autorelease];
        UITabBarItem *gameCenterTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Game Center" image:nil tag:3];
        [gameCenterViewController setTabBarItem:gameCenterTabBarItem];
        [gameCenterTabBarItem release];
        [viewControllers addObject:gameCenterViewController];
    }
#endif
    
    tabBarController.viewControllers = [NSArray arrayWithArray:viewControllers];
    [viewControllers release];    
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

#pragma mark -
#pragma mark Optional GameKit Integration

#if USEGAMEKIT

@synthesize localPlayer;
@synthesize gameCenterFriends;

- (void)authenticateLocalPlayer{
    GKLocalPlayer* currentPlayer = [GameKitHelper authenticatedGKLocalPlayer];
    if (nil == currentPlayer) {
        [[self localPlayer] release], localPlayer = nil;
        //      [GameKitHelper removeGKNotificationObserver:self];
    }
    [self setLocalPlayer:currentPlayer];
    [GameKitHelper addGKNotificationObserver:self selector:@selector(handleGKPlayerAuthenticationDidCangeNofication:)];
}


- (void)handleGKPlayerAuthenticationDidCangeNofication:(NSNotification *)notifcation {
    NSLog(@"Received %@", GKPlayerDidChangeNotificationName);
    [self authenticateLocalPlayer];
}
#endif

@end
