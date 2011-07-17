//
//  LoginViewController.h
//  The Race App
//
//  Created by Appsterdam on 7/16/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class FBRequest;
@class Facebook;
@class RaceAppUser;

@interface LoginViewController : UIViewController <FBSessionDelegate, FBRequestDelegate>
{
    RaceAppUser*        loggedInUser;
    
    UIBarButtonItem*    loginBarButtonItem;
    UIBarButtonItem*    logoutBarButtonItem;
    Facebook*           faceBookApi;
    FBRequest*          fbGetUserInfoRequest;
    
    IBOutlet UILabel*   loginStatusLabel;
    IBOutlet UILabel*   loggedInUserInfoLabel;
}

@property(nonatomic, retain) RaceAppUser* loggedInUser;
@property(nonatomic, retain) UILabel*     loggedInUserInfoLabel;
@property(nonatomic, retain) UILabel*     loginStatusLabel;

@end
