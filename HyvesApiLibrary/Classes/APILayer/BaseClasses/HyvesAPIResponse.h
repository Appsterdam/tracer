//
//  HyvesAPIResponse.h
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

@class HyvesAPICallHandler;

// Simple protocol for API callbacks.
//
// In case of success, provides a dictionary with data from the API response.
// The dictionary is the result of parsing the JSON or XML data (currently only JSON is supported).
// For readability, XML will be used as an example.
// For example, cities.get produced the following response.
// 
//    <cities_get_result>
//        <city>
//            <cityid>00901b0c9381ec501a148e26395f135437</cityid>
//            <regionid>008bc91ca9c20455f9820f1f3c935f5a07</regionid>
//            <countryid>00da0d7e3a352207e824bf85791df6cbcb</countryid>
//            <name>Voorburg</name>
//            <citytabid>00b2b003e973785d6a5dfb703d485c4c63</citytabid>
//            <url/>
//        </city>
//        <info>
//            <timestamp_difference>0</timestamp_difference>
//            <secure_connection>false</secure_connection>
//            <running_milliseconds>36</running_milliseconds>
//            <serverinfo>web1042_stable_82594_PHP</serverinfo>
//        </info>
//    </cities_get_result>
//
// Then the dictionary will contain the following values:
// =====================================================================
// Key:         Value:
// @"method"    @"cities.get"
// @"city"      NSArray*
//              [0] - NSDictionary
//                    Key:       Value:
//                    -------------------------------------------------
//                    @"cityid"     @"00901b0c9381ec501a148e26395f135437"
//                    @"regionid"   @"008bc91ca9c20455f9820f1f3c935f5a07"
//                    @"countryid"  @"00da0d7e3a352207e824bf85791df6cbcb"
//                    @"name"       @"Voorburg"
//                    @"citybaid"   @"00b2b003e973785d6a5dfb703d485c4c63"
//                    @"url"        NSNull
// @"info"      NSDictionary*
//                    Key:                          Value:
//                    --------------------------------------------------
//                    @"timestamp_difference"       NSNumber (0)
//                    @"secure_connection"          @"false"
//                    @"running_milliseconds"       NSNumber (36)
//                    @"serverinfo"                 @"web1042_stable_82594_PHP"
//
// In case of error, the NSError object contains the API error code or -1 (for timeout).
// There are some predefined error codes in HyvesAPIErrorCode enum (see HyvesAPIHandler.h)

@protocol HyvesAPIResponse

-(void)handleSuccessfulAPICall:(HyvesAPICallHandler*)aAPICallHandler response:(NSDictionary*)aResponse;
-(void)handleFailedAPICall:(HyvesAPICallHandler*)aAPICallHandler error:(NSError*)aError;

@end
