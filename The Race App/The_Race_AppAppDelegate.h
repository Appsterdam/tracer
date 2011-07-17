//
//  The_Race_AppAppDelegate.h
//  The Race App
//
//  Created by Appsterdam on 09/07/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
