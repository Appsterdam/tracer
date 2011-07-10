//
//  HyvesAPILayer.h
//  HyvesApiLibrary
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

#import <Foundation/Foundation.h>
#import "HyvesAPICallHandler.h"
#import "AuthenticateProtocol.h"

#define OAUTH_SIGNATURE_METHOD          @"HMAC-SHA1"
#define OAUTH_VERSION                   @"1.0"
#define HYVES_API_FORMAT                @"json"


@class LockedThread;


// HyvesAPILayer is a singleton class representing the API library.
// It manages the API thread and contrains API specific parameters, like consumer key, API version, etc.
// Before any of the API handlers can be used, the API thread must be started by calling start.
//
// authenticator is a delegate which will be called if some of the API calls fails with "not authorized"
// This can happen for multiple reasons, e.g. because the access token has expired 
// (or has been explicitly revoked on the Web site).
// In this case, authentication must be done again.
//
@interface HyvesAPILayer : NSObject
{
    LockedThread*       apiThread;
    NSTimer*            keepAliveTimer;
    
    id<Authenticate>    authenticator;
    
    NSString*           accessToken;
    NSString*           accessTokenSecret;
    
    NSString*           consumerKey;
    NSString*           consumerSecret;
    
    NSString*           hyvesApiVersion;
    NSString*           hyvesApiUrl;
    NSString*           hyvesApiSecureUrl;
    
    // If YES, all connections will be forced to use HTTPS.
    // (Reserved for future use).
    BOOL                enforceSecureConnections;
    BOOL                showNetworkActivityInStatusBar;
    // If yes, ha_language will be set according to the current locale on the device.
    BOOL                forceDeviceLanguage;
    
    // String to be appended to the 'User-Agent' HTTP header.
    NSString*           userAgentSuffix;
    
    // Per API call name, a dictionary with:
    // - Number of failed calls per error code.
    NSMutableDictionary* apiCallFailStatistics;
    
    // Flag to enable logging of failed API call stats.
    BOOL                enableFailedApiCallStatistics;
}

@property(readonly) LockedThread*           apiThread;
@property(retain) NSString*                 accessToken;
@property(retain) NSString*                 accessTokenSecret;
@property(retain) NSString*                 consumerKey;
@property(retain) NSString*                 consumerSecret;
@property(retain) NSString*                 hyvesApiVersion;
@property(retain) NSString*                 hyvesApiUrl;
@property(retain) NSString*                 hyvesApiSecureUrl;
@property(assign) BOOL                      enforceSecureConnections;
@property(assign) BOOL                      showNetworkActivityInStatusBar;
@property(assign) BOOL                      forceDeviceLanguage;
@property(retain) NSString*                 userAgentSuffix;

// Per API call name, a dictionary with:
// - Number of failed calls per error code.
@property(readonly, copy) NSDictionary*     apiCallFailStatistics;
// Flag to enable logging of failed API call stats.
@property(assign) BOOL                      enableFailedApiCallStatistics;

@property(assign) id<Authenticate>          authenticator;

// Start the API thread.
-(void)start;

// Stop the API thread.
// This call will block until the tread finishes. Use with caution!!!
-(void)stop;

// Singleton access
+ (HyvesAPILayer*)sharedHyvesAPILayer;

-(void)logFailedApiCallForMethod:(NSString*)aMethodName andErrorCode:(NSInteger)aErrorCode;

@end
