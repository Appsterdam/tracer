//
//  AuthAccessTokenAPICallHandler.m
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

#import "AuthAccessTokenAPICallHandler.h"


@implementation AuthAccessTokenAPICallHandler

@synthesize oauthToken;
@synthesize strictOauthSpecResponse;
@synthesize oauthCallbackConfirmed;
@synthesize oauthVerifier;


-(id)initWithDelegate:(id<HyvesAPIResponse>)aDelegate
           oauthToken:(NSString*)aOauthToken
strictOauthSpecResponse:(BOOL)aStrictOauthSpecResponse
oauthCallbackConfirmed:(NSString*)aOauthCallbackConfirmed
        oauthVerifier:(NSString*)aOauthVerifier
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithCapacity:10];

    /*
    if (aOauthToken != nil)
    {
        [param setObject:aOauthToken forKey:@"oauth_token"];
    }*/
    
    if (aStrictOauthSpecResponse)
    {
        [param setObject:@"true" forKey:@"strict_oauth_spec_response"];
    }
    
    if (aOauthCallbackConfirmed != nil)
    {
        [param setObject:aOauthCallbackConfirmed forKey:@"oauth_callback_confirmed"];
    }
    
    if (aOauthVerifier != nil)
    {
        [param setObject:aOauthVerifier forKey:@"oauth_verifier"];
    }
    
    if ((self = [super initWithHyvesAPIMethod:@"auth.accesstoken" 
                                   parameters:param 
                             secureConnection:YES 
                                     delegate:aDelegate 
                                      timeout:DEFAULT_API_CALL_TIMEOUT]))
    {
        oauthToken = [aOauthToken retain];
        strictOauthSpecResponse = aStrictOauthSpecResponse;
        oauthCallbackConfirmed = [aOauthCallbackConfirmed retain];
        oauthVerifier = [aOauthVerifier retain];
    }
    
    return self;
}


-(id)initWithDelegate:(id<HyvesAPIResponse>)aDelegate oauthToken:(NSString*)aOauthToken
{
    return [self initWithDelegate:aDelegate 
                       oauthToken:aOauthToken 
          strictOauthSpecResponse:NO 
           oauthCallbackConfirmed:nil
                    oauthVerifier:nil];
}



@end
