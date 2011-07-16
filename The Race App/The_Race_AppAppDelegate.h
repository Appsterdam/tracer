//
//  The_Race_AppAppDelegate.h
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#define USEGAMEKIT 0

#import <UIKit/UIKit.h>

@class Facebook;

#if USEGAMEKIT
@class GKPlayer;
#endif


@interface The_Race_AppAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow*               window;
    UITabBarController*     tabBarController;
    Facebook*               faceBookApi;
}

@property (nonatomic, retain) IBOutlet UIWindow*  window;
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) Facebook*           faceBookApi;

#pragma mark Optional GameKit Integration
#if USEGAMEKIT
@property (nonatomic, retain) GKPlayer* localPlayer;
@property (nonatomic, retain) NSArray* gameCenterFriends;

- (void)authenticateLocalPlayer;
- (void)handleGKPlayerAuthenticationDidCangeNofication:(NSNotification *)notifcation;
#endif
@end
