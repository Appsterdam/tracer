//
//  AuthorizationViewController.h
//  HyvesApiLibrary
//
//  Copyright (c) 2011 Hyves
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
//  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "HyvesAPIResponse.h"

// Protocol to notify authorization results.
@protocol WebAuthorizationDelegate <NSObject>

-(void)accessTokenReceived:(NSString*)aAcessToken secret:(NSString*)aSecret userId:(NSString*)aUserId expireDate:(NSDate*)aExpireDate;
-(void)accessTokenFailedWithError:(NSError*)aError;

@optional

-(void)oauthTokenReceived:(NSString*)aOauthToken secret:(NSString*)aSecret;
-(void)oauthTokenFailedWithError:(NSError*)aError;

-(void)oauthTokenAuthorized;
-(void)oauthTokenDeclined;

@end

@class AuthRequestTokenAPICallHandler;
@class AuthAccessTokenAPICallHandler;

@interface AuthorizationViewController : UIViewController <UIWebViewDelegate, HyvesAPIResponse>
{
    UIWebView*                      webView;
    
    // Delegate to be called to notify of a successful or failed login.
    id<WebAuthorizationDelegate>    authorizationDelegate;
    
    // Allowed method names.
    NSArray*                        methods;
    
    AuthRequestTokenAPICallHandler* requestTokenApiCallHandler;
    AuthAccessTokenAPICallHandler*  authAccessTokenApiCallHandler;
    
    NSString*                       oauthToken;
    NSString*                       oauthTokenSecret;
    
    BOOL                            loginStarted;
    BOOL                            loginCompleted;
}

@property(readonly)   UIWebView*                    webView;
@property(assign)     id<WebAuthorizationDelegate>  authorizationDelegate;
@property(retain)     NSArray*                      methods;

-(id)initWithDelegate:(id<WebAuthorizationDelegate>)aDelegate methods:(NSArray*)aAllowedMethods;

// Use before re-doing the login.
-(void)reset;


@end
