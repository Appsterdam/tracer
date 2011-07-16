//
//  The_Race_AppAppDelegate.h
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface The_Race_AppAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow*               window;
    UITabBarController*     tabBarController;
    GKPlayer*               localPlayer;
    NSArray*                gameCenterFriends;
}

@property (nonatomic, retain) IBOutlet UIWindow*  window;
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) GKPlayer* localPlayer;
@property (nonatomic, retain) NSArray* gameCenterFriends;

- (void)authenticateLocalPlayer;
- (void)handleGKPlayerAuthenticationDidCangeNofication:(NSNotification *)notifcation;

@end
