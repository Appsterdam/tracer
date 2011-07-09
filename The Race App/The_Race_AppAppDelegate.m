//
//  The_Race_AppAppDelegate.m
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "The_Race_AppAppDelegate.h"
#import "RaceViewController.h"

@implementation The_Race_AppAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	MKPointAnnotation *startPointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	startPointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376763, 4.922088);
	MKPointAnnotation *checkpointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	checkpointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376411, 4.922023);
	MKPointAnnotation *endPointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
	endPointAnnotation.coordinate = CLLocationCoordinate2DMake(52.376953, 4.922465);
	NSArray *checkpoints = [NSArray arrayWithObjects:
							startPointAnnotation,
							checkpointAnnotation,
							endPointAnnotation, 
							nil];
	
	RaceViewController *raceController = [[[RaceViewController alloc] initWithCheckpoints:checkpoints] autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:raceController] autorelease];
	self.window.rootViewController = navigationController;
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
    [super dealloc];
}

@end
