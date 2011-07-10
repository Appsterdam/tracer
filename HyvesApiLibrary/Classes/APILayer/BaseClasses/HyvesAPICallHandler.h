//
//  HyvesAPICallHandler.h
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
#import "AuthenticateProtocol.h"
#import "MalformedResponseException.h"
#import "HyvesAPIResponse.h"

#define DEFAULT_API_CALL_TIMEOUT 60.0

#define HYVES_API_ERROR_DOMAIN @"HyvesApi"

// Some frequently used result/error codes (mostly API error codes)
typedef enum
{
    // Not coming from Hyves API. Used for reporting photo upload errors.
    API_ERROR_CODE_PHOTO_UPLOAD_FAILED = -3,
    
    // Not coming from Hyves API. Used for reporting parsing errors.
    API_ERROR_CODE_MALFORMED_RESPONSE = -2,
    
    // Not coming from Hyves API. Used for reporting API call time-outs.
    API_ERROR_CODE_TIMEOUT = -1,
    
    // Success (not really used as an error code, but added for completeness).
    API_ERROR_CODE_NO_ERROR = 0,
    
    // The cause for this error is unknown, it is most likely an internal failure in the Hyves architecture. 
    // Try again later, or, if the problem persists, contact us with a clear description 
    API_ERROR_SERVER_ERROR = 1,
    
    // Cause: You are trying to call a method that doesn't exist in this version of the API. 
    // Some oauth_consumer_keys have access to less methods than other.
    //
    // Solution: Check that your ha_version and ha_method parameters are correct. 
    // Also check that you are using the correct oauth_consumer_key. 
    API_ERROR_INVALID_API_METHOD = 2,
    API_ERROR_INVALID_API_VERSION = 3,
    API_ERROR_INVALID_OAUTH_VERSION = 4,
    API_ERROR_SERVICE_UNAVAILABLE = 5,
    API_ERROR_IP_RANGE_RESTRICTION = 6,
    API_ERROR_ILLEGAL_CHARACTER = 7,
    API_ERROR_REQUEST_LIMIT_EXCEEDED = 8,
    
    API_ERROR_INVALID_CONSUMER_KEY = 10,
    API_ERROR_OAUTH_SIGNATURE_NOT_SUPPORTED = 11,
    API_ERROR_OAUTH_SIGNATURE_INVALID = 12,
    API_ERROR_REQUIRED_PARAMETERS_MISSING = 13,
    API_ERROR_UNKNOWN_PARAMETERS = 14,
    API_ERROR_API_FORMAT_UNAVAILABLE = 15,
    API_ERROR_OAUTH_TIMESTAMP_INVALID = 16,
    API_ERROR_OAUTH_TOKEN_INVALID = 17,
    API_ERROR_OAUTH_REQUEST_LIMIT_EXCEEDED = 18,
    API_ERROR_OAUTH_TOKEN_NO_PERMISSION_FOR_METHOD = 19,
    API_ERROR_HYVES_API_UNAVAILABLE = 20,
    
    API_ERROR_REQUEST_REPLAY = 24,
    API_ERROR_OAUTH_TOKEN_EXPIRED = 25,
    API_ERROR_INVALID_HA_CALLBACK_FORMAT = 26,
    API_ERROR_REQUEST_TOKEN_UNEXPECTED = 27,
    API_ERROR_ACCESS_TOKEN_UNEXPECTED = 28,
    API_ERROR_OAUTH_HEADER_INVALID = 29,
    API_ERROR_DUPLICATE_PARAMETER = 30,
    API_ERROR_REQUEST_TOKEN_NOT_AUTHORIZED = 31,
    API_ERROR_REQUEST_TOKEN_DECLINED = 32,
    
    API_ERROR_PAGE_DOES_NOT_EXIST = 33,
    API_ERROR_RESULTS_PER_PAGE_TOO_LARGE = 34,
    API_ERROR_NO_PAGINATION = 35,
    
    API_ERROR_NO_ACCESS = 101,
    API_ERROR_NOT_VISIBLE = 103,
    API_ERROR_DUPLICATE_CREATION = 1011,
    API_ERROR_SUBSCRIBE_ON_WEBSITE = 1025,
    API_ERROR_ILLEGAL_SEARCHTERMS = 1031,
    
    API_ERROR_INVALID_PASSWORD = 1048
    
    
}
HyvesAPIErrorCode;

@class HyvesAPILayer;
@class HyvesAPICall;
@class HyvesAPICallHandler;

// Class representing an API call (non-batched).
// To use, instantiate the handler and call its execute method.
// By default, results are reported on the same thread which called execute.
// This can be changed by calling reportResultsOnApiThread or reportResultsInBackground BEFORE calling execute.
// API thread is the network thread where all API calls are done.
// When reporting results in the background, a new thread is spawned (with performSelectorInBackground).
//
// Current implementation is NOT really suitable for reusing the same handler object for multiple calls
// That means that it is better to instantiate a new HyvesAPICallHandler object each time.
// This will be improved in the future.
@interface HyvesAPICallHandler : NSObject 
{
    // Delegate to be called back to report results.
    id<HyvesAPIResponse>    delegate;
    
    // API method name (e.g. @"users.get")
    NSString*               apiMethod;
    
    // Accumulated response (raw data).
    NSMutableData*          receivedData;

    // URL connection.
    NSURLConnection*        connection;
    
    // API call timeout (in seconds)
    NSTimeInterval          timeout;
    
    // Timer to keep the API thread alive
    NSTimer*                timer;
    
    // Caller thread on which results must be reported. 
    // If nil, a new background thread will be spawned to report the results.
    NSThread*               callerThread;
    
    // API (network) thread.
    NSThread*               apiThread;
    
    // API call parameters.
    NSMutableDictionary*    parameters;
    
    // If YES, HTTPS connection will be used.
    // Currently, secure connection should only be used for authentication.
    BOOL                    secure;
    
    // Request object.
    HyvesAPICall*           apiCall;
    
    // Additional user data (can be used to store any object)
    NSMutableDictionary*    userData;
    
    // If YES, the API call is in progress.
    BOOL                    executing;
    
    // If YES, reporting results is in progress, and the call can no longer be canceled!
    BOOL                    reportingResults;
    
    BOOL                    canceled;
}

@property(readonly) id<HyvesAPIResponse>    delegate;
@property(readonly) NSString*               apiMethod;
@property(assign) NSTimeInterval            timeout;
@property(readonly) NSThread*               callerThread;
@property(readonly) NSThread*               apiThread;
@property(readonly) BOOL                    secure;
@property(retain) NSMutableDictionary*      parameters;
@property(assign)   BOOL                    canceled;


// Additional data to save in the api handler.
@property(retain) NSMutableDictionary*      userData;

// Do an API call with the default timeout (in seconds). (See DEFAULT_API_CALL_TIMEOUT)
// If a call times out, the fail selector is called with API_ERROR_CODE_TIMEOUT
- (id)initWithHyvesAPIMethod:(NSString*)theApiMethod 
                  parameters:(NSDictionary*)aParameters 
                    delegate:(id<HyvesAPIResponse>)aListener;


// Do an API call with the specified timeout (in seconds).
// If a call times out, the fail selector is called with API_ERROR_CODE_TIMEOUT
// Set aSecure to YES, if the connection must be done via HTTPS (only done for authorization now).
- (id)initWithHyvesAPIMethod:(NSString*)theApiMethod 
                  parameters:(NSDictionary*)aParameters 
            secureConnection:(BOOL)aSecure 
                    delegate:(id<HyvesAPIResponse>)aListener
                     timeout:(NSTimeInterval)aTimeOut;

// Execute the API call on the API thread.
-(void)execute;

// Execute the API call on the API thread and report results in background instead of the caller thread.
-(void)executeAndReportInBackground;

// Cancel the API call (this blocks the caller thread until the API thread really cancels the call).
// Use with caution!
-(void)cancel;

// Get the page number from an API response (if available).
// The response must NOT be a batched response, but an individual API response.
// E.g. for users.get, it would be the content under users_get_result (excluding users_get_result itself).
// If the page number if not available, returns 1 (usually happens for non-paginated calls).
+(NSUInteger)pageNumberFromResponse:(NSDictionary*)aResponse;

// Get the number of results per page (if available).
// For non-paginated calls will always return 1.
// The response must NOT be a batched response, but an individual API response.
// E.g. for users.get, it would be the content under users_get_result (excluding users_get_result itself).
// If the page number if not available, returns 1 (usually happens for non-paginated calls).
+(NSUInteger)resultsPerPageFromResponse:(NSDictionary*)aResponse;

+(NSUInteger)totalPagesFromResponse:(NSDictionary*)aResponse;
+(NSUInteger)totalResultsFromResponse:(NSDictionary*)aResponse;
+(NSInteger)timeStampDifferenceFromResponse:(NSDictionary*)aResponse;


@end

