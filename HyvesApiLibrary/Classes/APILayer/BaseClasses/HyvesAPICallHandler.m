//
//  HyvesAPICallHandler.m
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

#import "HyvesAPICallHandler.h"
#import "HyvesAPICall.h"
#import "HyvesAPILayer.h"
#import "NSDictionary_JSONExtensions.h"
#import "HyvesAPILayer.h"
#import "AuthenticateProtocol.h"
#import "LockedThread.h"
#import "NSDictionary+HyvesApi.h"

#import <UIKit/UIKit.h>

@interface HyvesAPILayer (Private)

-(void)logFailedApiCallForMethod:(NSString*)aMethodName andErrorCode:(NSInteger)aErrorCode;

@end



@implementation HyvesAPICallHandler

@synthesize delegate;
@synthesize apiMethod;
@synthesize timeout;
@synthesize apiThread;
@synthesize callerThread;
@synthesize secure;
@synthesize parameters;
@synthesize userData;
@synthesize canceled;

#pragma mark -
#pragma mark Object lifecycle

-(void)showNetworkActivityIndicator:(NSNumber*)aShow
{
    NSAssert([NSThread isMainThread], @"HyvesAPIHandler::showNetworkActivityIndicator can only be done on the main thread");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[aShow boolValue]];
}


-(void)startApiCall
{
    @synchronized(self)
    {
        NSAssert([[NSThread currentThread] isEqual:apiThread], @"HyvesAPIHandler::startApiCall can only be done on the API thread");
        apiCall = [[HyvesAPICall alloc] initWithHyvesApiMethod:apiMethod parameters:parameters secureConnection:secure];
        
        timer = [[NSTimer scheduledTimerWithTimeInterval:timeout 
                                                  target:self
                                                selector:@selector(apiCallTimedOut)
                                                userInfo:nil
                                                 repeats:NO] retain];
        
        if ([HyvesAPILayer sharedHyvesAPILayer].showNetworkActivityInStatusBar)
        {
            [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        }
        
        // Connection will start immediately!
        connection = [[NSURLConnection alloc] initWithRequest:apiCall delegate:self];
    }
}

-(BOOL)reAuthenticateNeeded:(NSError*)aError
{
    NSInteger errorCode = [aError code];
    
    return (   (errorCode == API_ERROR_OAUTH_SIGNATURE_INVALID)
            || (errorCode == API_ERROR_OAUTH_TOKEN_EXPIRED)
            || (errorCode == API_ERROR_OAUTH_TOKEN_INVALID)
            || (errorCode == API_ERROR_NO_ACCESS));
}

// Report API call results to the delegate.
-(void)reportResults:(NSDictionary*)aResponse
{
    @synchronized(self)
    {
        if (canceled)
        {
            canceled = NO;
            return;
        }
        
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        if (callerThread != nil)
        {
            NSAssert([[NSThread currentThread] isEqual:callerThread], 
                      @"HyvesAPICallHandler::reportResults must be called on the caller thread.");
        }
        
        NSError* error = [aResponse objectForKey:@"error"];
        if (error != nil)
        {
            [delegate handleFailedAPICall:self error:error];
            BOOL reAuthenticationNeeded = [self reAuthenticateNeeded:error];
            if (reAuthenticationNeeded)
            {
                NSLog(@"Re-authenticate triggered because of error: %@, code: %d", [error localizedDescription], [error code]);
                [(NSObject*)[HyvesAPILayer sharedHyvesAPILayer].authenticator performSelectorOnMainThread:@selector(reAuthenticate) withObject:nil waitUntilDone:NO];
            }
        }
        else
        {
            NSDictionary* response = [aResponse objectForKey:@"response"];
            
            @try 
            {
                if (response != nil)
                {
                    [delegate handleSuccessfulAPICall:self response:response];
                }
                else 
                {
                    @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                                  reason:@"Received an empty response" 
                                                                userInfo:nil];
                }
            }
            @catch (MalformedResponseException* e)
            {
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                [userInfo setObject:[e reason] forKey:@"reason"];
                [userInfo setObject:aResponse forKey:@"response"];
                
                if ([e userInfo] != nil)
                {
                    [userInfo setObject:[e userInfo] forKey:@"moreInfo"];
                }
                
                NSError* error = [[NSError alloc] initWithDomain:@"HyvesApi" code:API_ERROR_CODE_MALFORMED_RESPONSE userInfo: userInfo];

                [delegate handleFailedAPICall:self error:error];

                [[HyvesAPILayer sharedHyvesAPILayer] logFailedApiCallForMethod:apiMethod andErrorCode:[error code]];
                
                [error release];
            }
        }

        [(NSObject*)delegate release];
        delegate = nil;
        
        executing = NO;
        reportingResults = NO;
        
        [pool release];
    }
}

// May be called in the background.
-(void)execute
{
    @synchronized(self)
    {
        callerThread = [[NSThread currentThread] retain];
        
        NSAssert(delegate != nil, @"HyvesAPICallHandler: execute called without a delegate");
        NSAssert(!executing, @"HyvesAPICallHandler: execute is called twice on HyvesAPICallHandler");
        executing = YES;
        
        // Prevent the delegate from being deallocated unless canceled or until reportResults has finished.
        [(NSObject*)delegate retain];
        
        [self performSelector:@selector(startApiCall) onThread:apiThread withObject:nil waitUntilDone:NO];
    }
}

-(void)executeAndReportInBackground
{
    @synchronized(self)
    {
        NSAssert(delegate != nil, @"HyvesAPICallHandler: execute called without a delegate");
        NSAssert(!executing, @"HyvesAPICallHandler: execute is called twice on HyvesAPICallHandler");
        executing = YES;
        
        // Prevent the delegate from being deallocated unless canceled or until reportResults has finished.
        [(NSObject*)delegate retain];
        
        [self performSelector:@selector(startApiCall) onThread:apiThread withObject:nil waitUntilDone:NO];
    }    
}


- (id)initWithHyvesAPIMethod:(NSString*)theApiMethod 
                  parameters:(NSDictionary*)aParameters 
            secureConnection:(BOOL)aSecure 
                    delegate:(id<HyvesAPIResponse>)aDelegate
                     timeout:(NSTimeInterval)aTimeOut
{
    if (self = [super init])
    {
        delegate = aDelegate;
        apiMethod = [theApiMethod retain];
        timeout = aTimeOut;
        apiThread = [HyvesAPILayer sharedHyvesAPILayer].apiThread;
        secure = aSecure;
        parameters = [aParameters retain];
        userData = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

// Do an API call with the default timeout (in seconds). (See DEFAULT_API_CALL_TIMEOUT)
// If a call times out, the fail selector is called with API_ERROR_CODE_TIMEOUT
- (id)initWithHyvesAPIMethod:(NSString*)theApiMethod 
                  parameters:(NSDictionary*)aParameters 
                    delegate:(id<HyvesAPIResponse>)aListener
{
    return [self initWithHyvesAPIMethod:theApiMethod 
                             parameters:aParameters 
                       secureConnection:NO 
                               delegate:aListener 
                                timeout:DEFAULT_API_CALL_TIMEOUT];
}



// Called on the API thread.
-(void)apiCallTimedOut
{
    @synchronized(self)
    {
        [timer release];
        timer = nil;
        
        [apiCall release];
        apiCall = nil;
        
        [connection cancel];
        [connection release];
        connection = nil;

        if ([HyvesAPILayer sharedHyvesAPILayer].showNetworkActivityInStatusBar)
        {
            [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        }
        
        NSError* error = [[NSError alloc] initWithDomain:@"HyvesApi" code:API_ERROR_CODE_TIMEOUT userInfo:nil] ;
    
        reportingResults = YES;

        // Report results on the caller thread.
        if (callerThread != nil)
        {
            // IMPORTANT!!!
            // It may happen that the caller thread is no longer alive and running by now.
            // This occurs when the API call was scheduled on a temporary thread (e.g. the one created with performSelectorInBackground).
            // If the caller thread no longer lives, we report results on the main (UI) thread.
            // (We don't report in a new background thread unless explicitly indicated to do so - callerThread will be nil if that's the case).
            NSThread* reportResultsThread = ([callerThread isExecuting] ? callerThread : [NSThread mainThread]);
            
            [self performSelector:@selector(reportResults:) 
                         onThread:reportResultsThread
                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]
                    waitUntilDone:NO];
            
            [callerThread release];
            callerThread = nil;
        }
        else 
        {
            [self performSelectorInBackground:@selector(reportResults:) 
                                   withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];
        }
    
        [[HyvesAPILayer sharedHyvesAPILayer] logFailedApiCallForMethod:apiMethod andErrorCode:[error code]];
        
        [error release];
    }
}

// Cancel the API call.
-(void)cancel
{
    @synchronized(self)
    {
        if (!executing)
        {
            return;
        }
        
        // It's too late to cancel!
        if (reportingResults)
        {
            return;
        }
    
        [(NSObject*)delegate release];
        delegate = nil;
    }
    
    // Redirect to the API thread if needed.
    if (![[NSThread currentThread] isEqual:apiThread])
    {
        // Weird. The call will block even if the apiThread is nil.
        // That's why we need an extra check.
        if (apiThread != nil)
        {
            [self performSelector:@selector(cancel) onThread:apiThread withObject:nil waitUntilDone:YES];
        }
    }
    else 
    {
        // Executed on the API thread.
        @synchronized(self)
        {
            [timer invalidate];
            [timer release];
            timer = nil;
            
            [apiCall release];
            apiCall = nil;
            
            [connection cancel];
            [connection release];
            connection = nil;
            
            [receivedData release];
            receivedData = nil;
        
            executing = NO;
            canceled = NO;

        }
    }
}


- (void)dealloc 
{
    [self cancel];
    
    [apiCall release];
    [connection release];
    [timer release];
    [apiMethod release];
    [parameters release];
    [receivedData release];
    [userData release];
    [callerThread release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse 
{
    [receivedData release];
    receivedData = [[NSMutableData data] retain];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error 
{
    @synchronized(self)
    {
        NSAssert([[NSThread currentThread] isEqual:apiThread], @"HyvesAPIHandler::connection:didFailWithError can only be done on the API thread");
        
        [timer invalidate];
        [timer release];
        timer = nil;
        
        if ([HyvesAPILayer sharedHyvesAPILayer].showNetworkActivityInStatusBar)
        {
            [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        }
        
        [apiCall release];
        apiCall = nil;
        
        [connection release];
        connection = nil;
        
        [receivedData release];
        receivedData = nil;
        
        reportingResults = YES;

        // Report results on the caller thread.
        if (callerThread != nil)
        {
            // IMPORTANT!!!
            // It may happen that the caller thread is no longer alive and running by now.
            // This occurs when the API call was scheduled on a temporary thread (e.g. the one created with performSelectorInBackground).
            // If the caller thread no longer lives, we report results on the main (UI) thread.
            // (We don't report in a new background thread unless explicitly indicated to do so - callerThread will be nil if that's the case).
            NSThread* reportResultsThread = ([callerThread isExecuting] ? callerThread : [NSThread mainThread]);
            
            [self performSelector:@selector(reportResults:) 
                         onThread:reportResultsThread
                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]
                    waitUntilDone:NO];
            
            [callerThread release];
            callerThread = nil;
        }
        else 
        {
            [self performSelectorInBackground:@selector(reportResults:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]];

        }

        [[HyvesAPILayer sharedHyvesAPILayer] logFailedApiCallForMethod:apiMethod andErrorCode:[error code]];

    }
}

// Gets called on the apiThread runloop when connection finishes loading the data.
- (void)connectionDidFinishLoading:(NSURLConnection*)aConnection 
{
    @synchronized(self)
    {
        NSAssert([[NSThread currentThread] isEqual:apiThread], @"HyvesAPIHandler::connectionDidFinishLoading can only be done on the API thread");

        [timer invalidate];
        [timer release];
        timer = nil;
        
        // NSLog(@"Received data for: %@", apiMethod);
        
        NSError* error = nil;
        NSDictionary* response = [NSDictionary dictionaryWithJSONData:receivedData error:&error];
        
        if ([receivedData length] == 0)
        {
            // int stop = 1;
        }
        
        if (error == nil && [[response valueForKey:@"method"] isEqualToString:@"error"])
        {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
            NSString* errorMessage = [response objectForKey:@"error_message"];
            
            [userInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
            
            // No connection error, but an error returned by the API.
            NSInteger errorCode = [[response objectForKey:@"error_code"] intValue];

            id infoData = [response objectForKey:@"info"];
            if (infoData != nil && infoData != [NSNull null])
            {
                id timeDifferenceData = [infoData objectForKey:@"timestamp_difference"];
                if (timeDifferenceData != nil && timeDifferenceData != [NSNull null])
                {
                    NSInteger timeDifference = [timeDifferenceData intValue];
                    [HyvesAPICall setTimeDifference:timeDifference];
                }
            }
            
            error = [[[NSError alloc] initWithDomain:@"HyvesApi" code:errorCode userInfo:userInfo] autorelease];
        }
        
        if ([HyvesAPILayer sharedHyvesAPILayer].showNetworkActivityInStatusBar)
        {
            [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
        }
        
        reportingResults = YES;
        
        // Report results on the caller thread.
        if (callerThread != nil)
        {
            // IMPORTANT!!!
            // It may happen that the caller thread is no longer alive and running by now.
            // This occurs when the API call was scheduled on a temporary thread (e.g. the one created with performSelectorInBackground).
            // If the caller thread no longer lives, we report results on the main (UI) thread.
            // (We don't report in a new background thread unless explicitly indicated to do so - callerThread will be nil if that's the case).
            NSThread* reportResultsThread = ([callerThread isExecuting] ? callerThread : [NSThread mainThread]);
            
            [self performSelector:@selector(reportResults:) 
                         onThread:reportResultsThread
                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:response, @"response",
                                   error, @"error", nil]
                    waitUntilDone:NO];
            
            [callerThread release];
            callerThread = nil;
        }
        else
        {
            [self performSelectorInBackground:@selector(reportResults:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:response, @"response",
                                                                                    error, @"error", nil]];
        }
    
        if (error != nil)
        {
            [[HyvesAPILayer sharedHyvesAPILayer] logFailedApiCallForMethod:apiMethod andErrorCode:[error code]];
        }
        
        [apiCall release];
        apiCall = nil;
        
        [connection release];
        connection = nil;

        [receivedData release];
        receivedData = nil;
    }
}

// Get the page number from an API response (if available).
// The response must NOT be a batched response, but an individual API response.
// E.g. for users.get, it would be the content under users_get_result (excluding users_get_result itself).
// If the page number if not available, returns 1 (usually happens for non-paginated calls).
+(NSUInteger)pageNumberFromResponse:(NSDictionary*)aResponse
{
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid response in pageNumberFromResponse" userInfo:nil];
    }
    
    id infoBlock = [aResponse objectForKey:@"info" 
                orThrowExceptionWithReason:[NSString stringWithFormat:@"No info block found in response: %@", [aResponse description]]];
    
    id currentPageNumber = [infoBlock objectForKey:@"currentpage"];
    
    if (currentPageNumber != nil && currentPageNumber != [NSNull null])
    {
        return [currentPageNumber intValue];
    }
    else 
    {
        return 1;
    }

}

// Get the number of results per page (if available).
// For non-paginated calls will always return 1.
// The response must NOT be a batched response, but an individual API response.
// E.g. for users.get, it would be the content under users_get_result (excluding users_get_result itself).
// If the page number if not available, returns 1 (usually happens for non-paginated calls).
+(NSUInteger)resultsPerPageFromResponse:(NSDictionary*)aResponse
{
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid response in resultsPerPageFromResponse" userInfo:nil];
    }
    
    id infoBlock = [aResponse objectForKey:@"info" 
                orThrowExceptionWithReason:[NSString stringWithFormat:@"No info block found in response: %@", [aResponse description]]];
    
    id resultsPerPageNumber = [infoBlock objectForKey:@"resultsperpage"];
    
    if (resultsPerPageNumber != nil && resultsPerPageNumber != [NSNull null])
    {
        return [resultsPerPageNumber intValue];
    }
    else 
    {
        return 1;
    }
    
}

+(NSUInteger)totalPagesFromResponse:(NSDictionary*)aResponse
{
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid response in totalPagesFromResponse" userInfo:nil];
    }
    
    id infoBlock = [aResponse objectForKey:@"info" 
                orThrowExceptionWithReason:[NSString stringWithFormat:@"No info block found in response: %@", [aResponse description]]];
    
    id totalPagesNumber = [infoBlock objectForKey:@"totalpages"];
    
    if (totalPagesNumber != nil && totalPagesNumber != [NSNull null])
    {
        return [totalPagesNumber intValue];
    }
    else 
    {
        return 1;
    }
}

+(NSUInteger)totalResultsFromResponse:(NSDictionary*)aResponse
{
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid response in totalResultsFromResponse" userInfo:nil];
    }
    
    id infoBlock = [aResponse objectForKey:@"info" 
                orThrowExceptionWithReason:[NSString stringWithFormat:@"No info block found in response: %@", [aResponse description]]];
    
    id totalResultsNumber = [infoBlock objectForKey:@"totalresults"];
    
    if (totalResultsNumber != nil && totalResultsNumber != [NSNull null])
    {
        return [totalResultsNumber intValue];
    }
    else 
    {
        return 0;
    }
}

+(NSInteger)timeStampDifferenceFromResponse:(NSDictionary*)aResponse
{
    if (aResponse == nil || (id)aResponse == [NSNull null])
    {
        @throw [MalformedResponseException exceptionWithName:NSInvalidArgumentException 
                                                      reason:@"Invalid response in timeStampDifferenceFromResponse" userInfo:nil];
    }
    
    id infoBlock = [aResponse objectForKey:@"info" 
                orThrowExceptionWithReason:[NSString stringWithFormat:@"No info block found in response: %@", [aResponse description]]];
    
    id timeStampDifferenceNumber = [infoBlock objectForKey:@"timestamp_difference"];
    
    if (timeStampDifferenceNumber != nil && timeStampDifferenceNumber != [NSNull null])
    {
        return [timeStampDifferenceNumber intValue];
    }
    else 
    {
        return 0;
    }
}




@end
