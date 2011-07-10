//
//  HyvesAPILayer.m
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

#import "HyvesAPILayer.h"
#import "SynthesizeSingleton.h"
#import "AuthenticateResponse.h"
#import "LockedThread.h"

@implementation HyvesAPILayer
@synthesize apiThread;
@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize authenticator;
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize hyvesApiVersion;
@synthesize hyvesApiUrl;
@synthesize hyvesApiSecureUrl;
@synthesize enforceSecureConnections;
@synthesize showNetworkActivityInStatusBar;
@synthesize forceDeviceLanguage;
@synthesize userAgentSuffix;
@synthesize enableFailedApiCallStatistics;
@synthesize apiCallFailStatistics;

#define DEFAULT_HYVES_API_VERSION       @"2.0"
#define DEFAULT_HYVES_API_URL           @"http://data.hyves-api.nl/"
#define DEFAULT_HYVES_API_SECURE_URL    @"https://data.hyves-api.nl/"

#define DUMMY_CONSUMER_KEY              @"PLEASE_SPECIFY_CONSUMER_KEY!!!"
#define DUMMY_CONSUMER_SECRET           @"PLEASE_SPECIFY_CONSUMER_SECRET!!!"


SYNTHESIZE_SINGLETON_FOR_CLASS(HyvesAPILayer);

-(id)init
{
    if (self = [super init])
    {
        consumerKey = DUMMY_CONSUMER_KEY;
        consumerSecret = DUMMY_CONSUMER_SECRET;
        hyvesApiVersion = DEFAULT_HYVES_API_VERSION;
        hyvesApiUrl = DEFAULT_HYVES_API_URL;
        hyvesApiSecureUrl = DEFAULT_HYVES_API_SECURE_URL;
        
        apiCallFailStatistics = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    
    return self;
}

-(void)dealloc
{
    NSAssert(![[NSThread currentThread] isEqual:apiThread], @"Cannot deallocate HyvesAPILayer on the API thread!");
    
    if (apiThread != nil)
    {
        [self stop];
    }
    
    [keepAliveTimer invalidate];
    [keepAliveTimer release];
    
    [accessToken release];
    [accessTokenSecret release];
    [consumerKey release];
    [consumerSecret release];
    
    [hyvesApiUrl release];
    [hyvesApiSecureUrl release];
    
    [hyvesApiVersion release];
    [userAgentSuffix release];
    [apiCallFailStatistics release];
    
    [super dealloc];
}

-(void)runLoopKeepAlive
{
}

-(void)apiThreadMain
{
    NSAssert([[NSThread currentThread] isEqual:apiThread], @"apiThreadMain can only run on the API thread.");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    keepAliveTimer = [[NSTimer scheduledTimerWithTimeInterval:FLT_MAX 
                                                       target:self 
                                                     selector:@selector(runLoopKeepAlive) 
                                                     userInfo:nil 
                                                      repeats:YES] retain];
    
    BOOL prioritySetResult = [NSThread setThreadPriority:0.3];
    NSLog(@"Starting API thread runloop.... Priority setting: %@", prioritySetResult ? @"success" : @"fail");
    
    // Don't use NSRunLoop here because CFRunLoopStop won't work with it.
    CFRunLoopRun();
    
    // We get here only after stop has been called.
    NSLog(@"API thread runloop finished.");
    
    [keepAliveTimer invalidate];
    [keepAliveTimer release];
    keepAliveTimer = nil;
    
    [pool release];
}


-(void)start
{
    if (apiThread == nil)
    {
        if (consumerKey == nil || [consumerKey isEqualToString:DUMMY_CONSUMER_KEY])
        {
            NSLog(@"===== WARNING! HyvesApiLayer started with consumer key not specified!");
            consumerKey = DUMMY_CONSUMER_KEY;
        }
        if (consumerSecret == nil || [consumerSecret isEqualToString:DUMMY_CONSUMER_SECRET])
        {
            NSLog(@"===== WARNING! HyvesApiLayer started with consumer secret not specified!");
            consumerSecret = DUMMY_CONSUMER_SECRET;
        }
        
        apiThread = [[LockedThread alloc] initWithTarget:self 
                                                selector:@selector(apiThreadMain) 
                                                  object:nil];
        [apiThread setName:@"Hyves API Thread"];

        [apiThread start];
    }
}

-(void)stopRunLoop
{
    NSAssert([[NSThread currentThread] isEqual:apiThread], @"HyvesApiLayer: Can only stop the runloop on the api thread.");
    
    [apiThread.lock lock];
    CFRunLoopStop(CFRunLoopGetCurrent());
}



// Stop the loader thread.
// This method will block until the thread signals that it has finished.
-(void)stop
{
    if (apiThread != nil)
    {
        // Unblock the loader thread if it's blocked.
        NSLog(@"Stopping HyvesApiLayer thread...");
        
        [self performSelector:@selector(stopRunLoop) onThread:apiThread withObject:nil waitUntilDone:YES];
        
        NSLock* threadDoneLock = [apiThread.lock retain];
        
        [apiThread release];
        
        // This will block until the thread is deallocated.
        [threadDoneLock lock];
        
        [threadDoneLock unlock];
        [threadDoneLock release];
        threadDoneLock = nil;
        
        apiThread = nil;
    }
    
    NSLog(@"HyvesApiLayer thread stopped.");
}

-(void)logFailedApiCallForMethod:(NSString*)aMethodName andErrorCode:(NSInteger)aErrorCode
{
    if (enableFailedApiCallStatistics && aMethodName != nil)
    {
        @synchronized(apiCallFailStatistics)
        {
                NSMutableDictionary* failStatsForMethod = [apiCallFailStatistics objectForKey:aMethodName];
                if (failStatsForMethod == nil)
                {
                    failStatsForMethod = [NSMutableDictionary dictionaryWithCapacity:2];
                    [apiCallFailStatistics setObject:failStatsForMethod forKey:aMethodName];
                }
                
                NSNumber* errorCodeNumber = [NSNumber numberWithInt:aErrorCode];
                NSNumber* failCountNumber = [failStatsForMethod objectForKey:errorCodeNumber];
                if (failCountNumber == nil)
                {
                    [failStatsForMethod setObject:[NSNumber numberWithInt:1] forKey:errorCodeNumber];
                }
                else 
                {
                    [failStatsForMethod setObject:[NSNumber numberWithInt:[failCountNumber intValue] + 1] forKey:errorCodeNumber];
                }
        }
    }
}

@end
