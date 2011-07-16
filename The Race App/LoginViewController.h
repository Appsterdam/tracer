//
//  LoginViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/16/11.
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
