//
//  AuthRequestTokenAPICallHandler.m
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

#import "AuthRequestTokenAPICallHandler.h"

@implementation AuthRequestTokenAPICallHandler
@synthesize expirationType;
@synthesize strictOauthSpecResponse;
@synthesize methods;

-(void)dealloc
{
    [methods release];
    [super dealloc];
}

-(id)initWithDelegate:(id<HyvesAPIResponse>)aDelegate 
              methods:(NSArray*)aMethods
       expirationType:(HyvesTokenExpirationType)aExpirationType
strictOauthSpecResponse:(BOOL)aStrictOauthSpecResponse
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [param setObject:[aMethods componentsJoinedByString:@","] forKey:@"methods"];
    
    if (aExpirationType == HYVES_TOKEN_EXPIRATION_INFINITE)
    {
        [param setObject:@"infinite" forKey:@"expirationtype"];
    }
    else if (aExpirationType == HYVES_TOKEN_EXPIRATION_USER)
    {
        [param setObject:@"user" forKey:@"expirationtype"];
    }
    
    if (aStrictOauthSpecResponse)
    {
        [param setObject:@"true" forKey:@"strict_oauth_spec_response"];
    }
    
    
    if ((self = [super initWithHyvesAPIMethod:@"auth.requesttoken" 
                                   parameters:param 
                             secureConnection:YES 
                                     delegate:aDelegate 
                                      timeout:DEFAULT_API_CALL_TIMEOUT]))
    {
        methods = [aMethods retain];
        expirationType = aExpirationType;
        strictOauthSpecResponse = aStrictOauthSpecResponse;
    }
    
    return self;
}

-(id)initWithDelegate:(id<HyvesAPIResponse>)aDelegate methods:(NSArray*)aMethods
{
    return [self initWithDelegate:aDelegate 
                          methods:aMethods
                   expirationType:HYVES_TOKEN_EXPIRATION_DEFAULT
          strictOauthSpecResponse:NO];
}


@end
