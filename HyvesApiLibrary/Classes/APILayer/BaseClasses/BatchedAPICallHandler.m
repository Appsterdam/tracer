//
//  BatchedAPICallHandler.m
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

#import "BatchedAPICallHandler.h"
#import "HyvesAPILayer.h"
#import "NSDictionary+HyvesApi.h"

@implementation BatchedAPICallHandler

@synthesize batchedApiMethods;
@synthesize batchedParameters;

-(void)dealloc
{
    [batchedApiMethods release];
    [batchedParameters release];
    
    [super dealloc];
}

- (id)initWithListener:(id<HyvesAPIResponse>)aListener
      secureConnection:(BOOL)aSecure 
               timeout:(NSTimeInterval)aTimeOut
{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (self = [super initWithHyvesAPIMethod:@"batch.process" 
                                  parameters:param 
                            secureConnection:NO 
                                    delegate:aListener
                                     timeout:DEFAULT_API_CALL_TIMEOUT])
    {
        batchedApiMethods = [[NSMutableArray alloc] initWithCapacity:10];
        batchedParameters = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    [param release];
    
    return self;
}

-(void)addHyvesAPIMethod:(NSString*)aMethod parameters:(NSDictionary*)aParameters
{
    [batchedApiMethods addObject:aMethod];
    
    NSString* haVersion = [aParameters objectForKey:@"ha_version"];
    if (haVersion == nil)
    {
        NSMutableDictionary* extendedParameters = [NSMutableDictionary dictionaryWithDictionary:aParameters];
        haVersion = [HyvesAPILayer sharedHyvesAPILayer].hyvesApiVersion;
        [extendedParameters setObject:haVersion forKey:@"ha_version"];
        [batchedParameters addObject:extendedParameters];
    }
    else 
    {
        [batchedParameters addObject:aParameters];
    }

    
    NSMutableString* combinedRequest = [[NSMutableString alloc] initWithCapacity:512];
    
    // Compose the combined request.
    for (int i = 0; i< [batchedApiMethods count]; ++i) 
    {
        if (i > 0)
        {
            [combinedRequest appendString:@","];
        }
        
        [combinedRequest appendFormat:@"ha_method=%@", [batchedApiMethods objectAtIndex:i]];
        NSDictionary* currentParams = [batchedParameters objectAtIndex:i];
        NSArray* paramNames = [currentParams allKeys];
        
        for (NSString* paramName in paramNames) 
        {
            NSString* paramValue = [currentParams objectForKey:paramName];
            [combinedRequest appendFormat:@"&%@=%@", paramName, paramValue];
        }
    }
    
    [parameters setObject:combinedRequest forKey:@"request"];
    
    [combinedRequest release];
}


// Extract a response for an individual API call.
// If the call resulted in an error, aErrorPtr is assigned the error (unless NULL) and nil is returned.
-(id)getApiCallResponseAtIndex:(NSUInteger)aIndex fromResponse:(NSDictionary*)aResponse error:(NSError**)aErrorPtr
{
    if (aIndex >= [batchedApiMethods count])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"API call index too large" userInfo:nil];
    }
    
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Empty response given" userInfo:nil];
    }
    
    // First check if the batch API call itself succeeded. If not, there is no point of going any further.
    id requestNode = [aResponse objectForKey:@"request"];
    
    if (requestNode == nil || requestNode == [NSNull null])
    {
        if (aErrorPtr != NULL)
        {
            // Either an error or a malformed response.
            // Check for error code/message.
            id errorCode = [aResponse objectForKey:@"error_code" 
                        orThrowExceptionWithReason:[NSString stringWithFormat:@"Missing error code in response: %@", [aResponse description]]];
            
            id errorMessage = [aResponse objectForKey:@"error_message"
                        orThrowExceptionWithReason:[NSString stringWithFormat:@"Missing error message in response: %@", [aResponse description]]];
            
            NSError* error = [[[NSError alloc] initWithDomain:HYVES_API_ERROR_DOMAIN 
                                                         code:[errorCode intValue] 
                                                     userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]] autorelease];
            *aErrorPtr = error;
        }
        
        return nil;
    }
    
    // There is a valid request
    
    id responseDictionary = [requestNode objectAtIndex:aIndex orThrowExceptionWithReason:[NSString stringWithFormat:@"No valid sub-response at index: %d in response: %@", aIndex, [aResponse description]]];
    id errorResponse = [responseDictionary objectForKey:@"error_result"];
    
    if (errorResponse != nil)
    {
        if (aErrorPtr != NULL)
        {
            // Either an error or a malformed response.
            // Check for error code/message.
            id errorCode = [errorResponse objectForKey:@"error_code" 
                        orThrowExceptionWithReason:[NSString stringWithFormat:@"Missing error code in response: %@", [aResponse description]]];
            
            id errorMessage = [errorResponse objectForKey:@"error_message"
                           orThrowExceptionWithReason:[NSString stringWithFormat:@"Missing error message in response: %@", [aResponse description]]];
            
            NSError* error = [[[NSError alloc] initWithDomain:HYVES_API_ERROR_DOMAIN 
                                                         code:[errorCode intValue] 
                                                     userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]] autorelease];
            *aErrorPtr = error;
        }
        
        return nil;
    }
        
    // Double check that it's the correct response (may not be really needed).
    // E.g. for buzz.getForFriends the response tag must be buzz_getForFriends_result
    NSString* requestedApiMethod = [batchedApiMethods objectAtIndex:aIndex];
    NSString* expectedResultTag = [NSString stringWithFormat:@"%@_result", [requestedApiMethod stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
    id expectedResponse = [responseDictionary objectForKey:expectedResultTag orThrowExceptionWithReason:[NSString stringWithFormat:@"Expected result tag: %@ not found in batched response: %@", 
                           expectedResultTag, [aResponse description]]];
    
    
    return expectedResponse;
}

// Extract a response for an individual API call specified by method name.
// If the call resulted in an error, aErrorPtr is assigned the error (unless NULL) and nil is returned.
// If there is no response data available, MalformedResponseException is thrown.
-(id)getApiCallResponseForMethod:(NSString*)aApiMethod fromResponse:(NSDictionary*)aResponse error:(NSError**)aErrorPtr
{
    if (aApiMethod == nil)
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"API method is nil" userInfo:nil];
        
    }
    
    // Determine the index in response. It must be the same as the index of the API method in batchedApiMethods
    NSUInteger responseIndex = [batchedApiMethods indexOfObject:aApiMethod];
    if (responseIndex == NSNotFound)
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid API method" userInfo:nil];
    }
    
    id result = [self getApiCallResponseAtIndex:responseIndex fromResponse:aResponse error:aErrorPtr];
    
    return result;
}


@end
