//
//  BatchedAPICallHandler.h
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

// Simple way to batch API calls.
// Just call addHyvesAPIMethod for all the calls in the batch.
// The results are reported as a single dictionary.
@interface BatchedAPICallHandler : HyvesAPICallHandler 
{
    NSMutableArray* batchedApiMethods;
    NSMutableArray* batchedParameters;
}

@property(readonly) NSArray* batchedApiMethods;
@property(readonly) NSArray* batchedParameters;

- (id)initWithListener:(id<HyvesAPIResponse>)aListener
      secureConnection:(BOOL)aSecure 
               timeout:(NSTimeInterval)aTimeOut;

-(void)addHyvesAPIMethod:(NSString*)aMethod parameters:(NSDictionary*)aParameters;

// Extract a response for an individual API call specified by index.
// If the call resulted in an error, aErrorPtr is assigned the error (unless NULL) and nil is returned.
// If there is no response data available, MalformedResponseException is thrown.
-(id)getApiCallResponseAtIndex:(NSUInteger)aIndex fromResponse:(NSDictionary*)aResponse error:(NSError**)aErrorPtr;

// Extract a response for an individual API call specified by method name.
// If the call resulted in an error, aErrorPtr is assigned the error (unless NULL) and nil is returned.
// If there is no response data available, MalformedResponseException is thrown.
-(id)getApiCallResponseForMethod:(NSString*)aApiMethod fromResponse:(NSDictionary*)aResponse error:(NSError**)aErrorPtr;

@end
