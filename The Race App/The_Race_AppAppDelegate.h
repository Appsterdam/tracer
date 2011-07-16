//
//  The_Race_AppAppDelegate.h
//  The Race App
//
//  Created by Matteo Manferdini on 09/07/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Facebook;

@interface The_Race_AppAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow*               window;
    UITabBarController*     tabBarController;
    Facebook*               faceBookApi;
}

@property (nonatomic, retain) IBOutlet UIWindow*  window;
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) Facebook*           faceBookApi;

@end
