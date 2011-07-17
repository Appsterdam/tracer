//
//  The_Race_AppAppDelegate.h
//  The Race App
//
//  Created by Appsterdam on 09/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "AppSpecificValues.h"
#import "GameCenterManager.h"

@class Facebook;
@class GameCenterManager;

@interface The_Race_AppAppDelegate : NSObject <UIApplicationDelegate, GameCenterManagerDelegate> 
{
    UIWindow*               window;
    Facebook*               faceBookApi;
}

@property (nonatomic, retain) IBOutlet UIWindow*  window;
@property (nonatomic, retain) Facebook*           faceBookApi;
@property (nonatomic, retain) GameCenterManager* gameCenterManager;

@end
