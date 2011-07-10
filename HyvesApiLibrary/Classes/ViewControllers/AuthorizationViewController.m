//
//  AuthorizationViewController.m
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

#import "AuthorizationViewController.h"
#import "AuthRequestTokenAPICallHandler.h"
#import "AuthAccessTokenAPICallHandler.h"

#import "NSDictionary+HyvesApi.h"
#import "HyvesAPICall.h"
#import "HyvesAPILayer.h"

#import <QuartzCore/QuartzCore.h>

@implementation AuthorizationViewController
@synthesize webView;
@synthesize authorizationDelegate;
@synthesize methods;

-(id)initWithDelegate:(id<WebAuthorizationDelegate>)aDelegate methods:(NSArray*)aAllowedMethods
{
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        self.authorizationDelegate = aDelegate;
        self.methods = aAllowedMethods;
    }
    
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL accepted = ([[[request URL] absoluteString] rangeOfString:@"http://www.hyves.nl/mini/api/accepted"].location != NSNotFound);
    BOOL declined = ([[[request URL] absoluteString] rangeOfString:@"http://www.hyves.nl/mini/api/declined"].location != NSNotFound);
    
    if ((accepted || declined) && (authorizationDelegate != nil))
    {
        if (accepted)
        {
            if ([authorizationDelegate respondsToSelector:@selector(oauthTokenAuthorized)])
            {
                [authorizationDelegate oauthTokenAuthorized];
            }

            [HyvesAPILayer sharedHyvesAPILayer].accessToken = oauthToken;
            [HyvesAPILayer sharedHyvesAPILayer].accessTokenSecret = oauthTokenSecret;
            
            authAccessTokenApiCallHandler = [[AuthAccessTokenAPICallHandler alloc] initWithDelegate:self oauthToken:[oauthToken URLEncodedString]];
            [authAccessTokenApiCallHandler execute];
            
        }
        else 
        {
            if ([authorizationDelegate respondsToSelector:@selector(oauthTokenDeclined)])
            {
                [authorizationDelegate oauthTokenDeclined];
            }
        }

        return NO;
    }

    
    return YES;

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //self.view.layer.masksToBounds = YES;
    //self.view.layer.borderColor = [UIColor redColor].CGColor;
    //self.view.layer.borderWidth = 3.0;
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [webView setBackgroundColor:[UIColor whiteColor]];
    // webView.layer.masksToBounds = YES;
    // webView.layer.borderColor = [UIColor blueColor].CGColor;
    // webView.layer.borderWidth = 3.0;
    
    [self.view addSubview:webView];
    webView.delegate = self;
    
    // [webView loadHTMLString:@"<html><body><p><center>Logging into Hyves...</center></p></body></html>" baseURL:nil];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [requestTokenApiCallHandler cancel];
    [requestTokenApiCallHandler release];
    requestTokenApiCallHandler = nil;

    [authAccessTokenApiCallHandler cancel];
    [authAccessTokenApiCallHandler release];
    requestTokenApiCallHandler = nil;
    
    
    [webView release];
    webView = nil;
}


- (void)dealloc 
{
    if (self.isViewLoaded)
    {
        [self viewDidUnload];
    }
    
    [super dealloc];
}


-(void)login
{
    if (!loginStarted)
    {
        loginStarted = YES;
        
        [requestTokenApiCallHandler cancel];
        [requestTokenApiCallHandler release];
        
        requestTokenApiCallHandler = [(AuthRequestTokenAPICallHandler*)[AuthRequestTokenAPICallHandler alloc] initWithDelegate:self methods:methods];
        [requestTokenApiCallHandler execute];
    }
    else 
    {
        NSLog(@"Another login is in progress. Please use reset to restart the login without finishing current login.");
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!loginStarted)
    {
        [self login];
    }
}

-(void)reset
{
    if (loginStarted)
    {
        [requestTokenApiCallHandler cancel];
        [requestTokenApiCallHandler release];
        requestTokenApiCallHandler = nil;
        
        [authAccessTokenApiCallHandler cancel];
        [authAccessTokenApiCallHandler release];
        requestTokenApiCallHandler = nil;

        [oauthToken release];
        oauthToken = nil;
        
        [oauthTokenSecret release];
        oauthTokenSecret = nil;

        if (!loginCompleted)
        {
            [HyvesAPILayer sharedHyvesAPILayer].accessToken = nil;
            [HyvesAPILayer sharedHyvesAPILayer].accessTokenSecret = nil;
        }
        
        loginStarted = NO;
        loginCompleted = NO;
    }
}

-(void)handleSuccessfulAPICall:(HyvesAPICallHandler *)aAPICallHandler response:(NSDictionary *)aResponse
{
    if (aAPICallHandler == requestTokenApiCallHandler)
    {
        // Received OAuth token from the server.
        // Now it has to be authorized by the user.
        
        oauthToken = (NSString*)[[aResponse objectForKey:@"oauth_token"              orThrowExceptionWithReason:@"No oauth token in request token response"] retain];
        oauthTokenSecret = (NSString*)[[aResponse objectForKey:@"oauth_token_secret" orThrowExceptionWithReason:@"No oauth token secret in request token response"] retain];
        
        if ([authorizationDelegate respondsToSelector:@selector(oauthTokenReceived:secret:)])
        {
            [authorizationDelegate oauthTokenReceived:oauthToken secret:oauthTokenSecret];
        }
        
        NSString* authorizationUrlString = [NSString stringWithFormat:@"http://www.hyves.nl/mini/api/authorize/?oauth_token=%@", [oauthToken URLEncodedString]];
        
        NSURL* authorizationUrl = [NSURL URLWithString:authorizationUrlString];
        
        NSURLRequest* authorizationRequest = [NSURLRequest requestWithURL:authorizationUrl];
        
        // Load the full authorization URL in the Web view:
        [webView loadRequest:authorizationRequest];
        
        [requestTokenApiCallHandler release];
        requestTokenApiCallHandler = nil;
    }
    else if (aAPICallHandler == authAccessTokenApiCallHandler)
    {
        NSString* accessToken = [aResponse objectForKey:@"oauth_token" orThrowExceptionWithReason:@"No access token in auth.accesstoken response"];
        NSString* accessTokenSecret = [aResponse objectForKey:@"oauth_token_secret" orThrowExceptionWithReason:@"No access token secret in auth.accesstoken response"];
        
        [HyvesAPILayer sharedHyvesAPILayer].accessToken = accessToken;
        [HyvesAPILayer sharedHyvesAPILayer].accessTokenSecret = accessTokenSecret;
        
        NSString* userId = [aResponse objectForKey:@"userid" orThrowExceptionWithReason:@"No user ID in auth.accesstoken response"];
        NSNumber* expirationDateNumber = [aResponse objectForKey:@"expiredate" orThrowExceptionWithReason:@"No expiredate in auth.accesstoken response"];
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[expirationDateNumber floatValue]];

        [authAccessTokenApiCallHandler release];
        authAccessTokenApiCallHandler = nil;
        
        loginCompleted = YES;
        
        [authorizationDelegate accessTokenReceived:accessToken 
                                            secret:accessTokenSecret 
                                            userId:userId 
                                        expireDate:expirationDate];
    }
    
}    

-(void)handleFailedAPICall:(HyvesAPICallHandler *)aAPICallHandler error:(NSError *)aError
{
    if (aAPICallHandler == requestTokenApiCallHandler)
    {
        [requestTokenApiCallHandler release];
        requestTokenApiCallHandler = nil;
        
        if ([authorizationDelegate respondsToSelector:@selector(oauthTokenFailedWithError:)])
        {
            [authorizationDelegate oauthTokenFailedWithError:aError];
        }
    }
    else if (aAPICallHandler == authAccessTokenApiCallHandler)
    {
        [authAccessTokenApiCallHandler release];
        authAccessTokenApiCallHandler = nil;

        [authorizationDelegate accessTokenFailedWithError:aError];
    }
    
}    


@end
