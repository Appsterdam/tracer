//
//  HyvesAPICall.m
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

#import "HyvesAPICall.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Base64Transcoder.h"
#import "HyvesAPILayer.h"

static NSInteger timeDifference = 0;

#ifdef DEBUG
@interface NSURLRequest (Undocumented)
    +(void)setAllowsAnyHTTPSCertificate:(BOOL)aFlag forHost:(NSString*)aHost;
@end
#endif


@implementation NSString (URLEncoding)

- (NSString*)URLEncodedString 
{
    return [(NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, CFSTR("-._~"), CFSTR("&+*?!;@:/=,()<>[]$#%{}|\\^'\""), kCFStringEncodingUTF8) autorelease];
}

@end


@interface HyvesAPICall (Private)

- (NSString*)oAuthSignatureForParameters:(NSDictionary*)parameters;
- (NSDictionary*)signedOAuthParametersWithAPIParameters:(NSDictionary*)parameters;
- (NSDictionary*)APIRequestParametersWithMethodName:(NSString*)methodName parameters:(NSDictionary*)parameters;

@end


@implementation HyvesAPICall

+ (void)setTimeDifference:(NSInteger)aTimeDifference
{
    timeDifference = aTimeDifference;
}

#pragma mark -
#pragma mark Object lifecycle

- (id)initWithHyvesApiMethod:(NSString*)method parameters:(NSDictionary*)parameters secureConnection:(BOOL)secure 
{
    BOOL enforceSecure = [HyvesAPILayer sharedHyvesAPILayer].enforceSecureConnections;
    
    NSString* urlString = (secure || enforceSecure) ? [HyvesAPILayer sharedHyvesAPILayer].hyvesApiSecureUrl : [HyvesAPILayer sharedHyvesAPILayer].hyvesApiUrl;
    
    if ((self = [super initWithURL:[NSURL URLWithString:urlString] 
                cachePolicy:NSURLRequestReloadIgnoringCacheData 
            timeoutInterval:10]))
    {
    
    #ifdef DEBUG
        NSString* host = [[self URL] host];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:host];
    #endif
        
        NSString* userAgentSuffix = [HyvesAPILayer sharedHyvesAPILayer].userAgentSuffix;
        if (userAgentSuffix != nil)
        {
            [self addValue:userAgentSuffix forHTTPHeaderField:@"User-Agent"];
        }
        
        secureConnection = secure;
        [self setHTTPMethod:@"POST"];
        NSDictionary *apiParameters = [self APIRequestParametersWithMethodName:method parameters:parameters];    
        NSDictionary *oAuthParameters = [self signedOAuthParametersWithAPIParameters:apiParameters];
        NSString *oAuthValue = @"OAuth realm=\"\"";
        
        for (NSString *parameter in [oAuthParameters allKeys])
        {
            oAuthValue = [oAuthValue stringByAppendingFormat:@", %@=\"%@\"", parameter, [[oAuthParameters objectForKey:parameter] URLEncodedString]];
        }
        
        [self addValue:oAuthValue forHTTPHeaderField:@"Authorization"];
        
        NSMutableArray *apiParameterPairs = [NSMutableArray array];
        
        for (NSString *parameter in apiParameters) 
        {
            [apiParameterPairs addObject:[NSString stringWithFormat:@"%@=%@", parameter, [[apiParameters objectForKey:parameter] URLEncodedString]]];
        }
        
        NSString *requestBody = [[apiParameterPairs sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"];
        
        [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self addValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
        [self setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return self;
}

#pragma mark -     
#pragma mark Private

-(NSString*)generateUuidString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidCFString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString*)uuidCFString autorelease];
}

- (NSDictionary*)signedOAuthParametersWithAPIParameters:(NSDictionary*)parameters 
{
    NSMutableDictionary *oAuthParameters = [NSMutableDictionary dictionary];
    
    [oAuthParameters setObject:[HyvesAPILayer sharedHyvesAPILayer].consumerKey forKey:@"oauth_consumer_key"];
    [oAuthParameters setObject:OAUTH_SIGNATURE_METHOD forKey:@"oauth_signature_method"];
    [oAuthParameters setObject:[self generateUuidString] forKey:@"oauth_nonce"];
    [oAuthParameters setObject:OAUTH_VERSION forKey:@"oauth_version"];
    
    NSString* oauthTokenKey = [HyvesAPILayer sharedHyvesAPILayer].accessToken;
    if (oauthTokenKey != nil)
    {
        [oAuthParameters setObject:oauthTokenKey forKey:@"oauth_token"];
    }
    
    NSInteger timeStamp = time(NULL) + timeDifference;
    [oAuthParameters setObject:[NSString stringWithFormat:@"%d", timeStamp] forKey:@"oauth_timestamp"];
    
    NSMutableDictionary *signatureParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [signatureParameters addEntriesFromDictionary:oAuthParameters];
    
    [oAuthParameters setObject:[self oAuthSignatureForParameters:signatureParameters] forKey:@"oauth_signature"];
    return [NSDictionary dictionaryWithDictionary:oAuthParameters];
}

- (NSDictionary*)APIRequestParametersWithMethodName:(NSString*)methodName parameters:(NSDictionary*)aParameters 
{
    NSMutableDictionary* resultParameters = [NSMutableDictionary dictionaryWithDictionary:aParameters];
    
    NSString* haMethod = [aParameters objectForKey:@"ha_method"];
    NSString* haVersion = [aParameters objectForKey:@"ha_version"];
    NSString* haFormat = [aParameters objectForKey:@"ha_format"];
    NSString* haFancyLayout = [aParameters objectForKey:@"ha_fancylayout"];
    
    if (haMethod == nil || haVersion == nil || haFormat == nil || haFancyLayout == nil)
    {
        if (haMethod == nil)
        {
            [resultParameters setObject:methodName forKey:@"ha_method"];
        }
        
        if (haVersion == nil)
        {
            [resultParameters setObject:[HyvesAPILayer sharedHyvesAPILayer].hyvesApiVersion forKey:@"ha_version"];
        }
        
        if (haFormat == nil)
        {
            [resultParameters setObject:HYVES_API_FORMAT forKey:@"ha_format"];
        }
        if (haFancyLayout == nil)
        {
            [resultParameters setObject:@"true" forKey:@"ha_fancylayout"];
        }
    }

    if (   [HyvesAPILayer sharedHyvesAPILayer].forceDeviceLanguage 
        && (   [[resultParameters objectForKey:@"ha_version"] floatValue] >= 2.0 
            || [[resultParameters objectForKey:@"ha_version"] rangeOfString:@"beta"].location != NSNotFound)) 
    {
        NSString* haLanguage = [aParameters objectForKey:@"ha_language"];
        if (haLanguage == nil)
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
            NSString* currentLanguage = [languages objectAtIndex:0];
            
            haLanguage = [currentLanguage isEqualToString:@"nl"] ? @"nl" : @"en";
            [resultParameters setObject:haLanguage forKey:@"ha_language"];
        }
    }
    
    return resultParameters;
}

- (NSString*)oAuthSignatureForParameters:(NSDictionary*)parameters 
{
    NSMutableArray *headers = [NSMutableArray array];
    for (NSString *parameter in [parameters allKeys])
            [headers addObject:[NSString stringWithFormat:@"%@=%@", parameter, [[parameters objectForKey:parameter] URLEncodedString]]];
    
    NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", [[self HTTPMethod] URLEncodedString], 
                                     [secureConnection ? [HyvesAPILayer sharedHyvesAPILayer].hyvesApiSecureUrl : [HyvesAPILayer sharedHyvesAPILayer].hyvesApiUrl URLEncodedString], 
                                     [[[headers sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"] URLEncodedString]];
    
    NSString* consumerSecret = [HyvesAPILayer sharedHyvesAPILayer].consumerSecret;
    
    NSString* oauthTokenSecret = [HyvesAPILayer sharedHyvesAPILayer].accessTokenSecret;
    
    NSData *secretData = [[NSString stringWithFormat:@"%@&%@", [consumerSecret URLEncodedString], 
                           (oauthTokenSecret != nil) ? [oauthTokenSecret URLEncodedString] : @""] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encodedBaseStringData = [signatureBaseString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char signatureMac[20];
    
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [encodedBaseStringData bytes], [encodedBaseStringData length], signatureMac);
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(signatureMac, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    return [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
}

@end
