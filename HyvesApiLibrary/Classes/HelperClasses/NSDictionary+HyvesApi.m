//
//  NSDictionary+HyvesApi.m
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

#import "NSDictionary+HyvesApi.h"
#import "MalformedResponseException.h"

@implementation NSDictionary (HyvesApi)

/**
 * Converts an API array response into a dictionary response.
 * In order to do that a (unique) key must be provided.
 *
 * Note that if a nil-array is passed-in an empty dictionary will
 * be returned. This is useful for handling both batched and non-batched API calls.
 */
+(NSDictionary*)dictionaryFromArray:(NSArray*) aArray key:(NSString*) aKey
{
    // Handling case when nil-array is passed-in (for simpler response handling)
    if(aArray == nil)
    {
        return [NSMutableDictionary dictionaryWithCapacity: 0];
    }
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: [aArray count]];
    for(id element in aArray)
    {
        if(element != nil && [element isKindOfClass: [NSDictionary class]])
        {
            id keyContent = [element objectForKey: aKey];
            if(keyContent != nil)
            {
                [dict setObject:element forKey:keyContent];
            }
        }
    }
    return dict;
}

-(id)objectForKey:(NSString*)aKey orThrowExceptionWithReason:(NSString*)aFailureReason moreInfo:(NSDictionary*) aMoreInfo
{
    id value = [self objectForKey:aKey];
    if ((value == nil) || (value == [NSNull null]))
    {
        @throw [MalformedResponseException exceptionWithName: NSInvalidArgumentException reason:aFailureReason userInfo: aMoreInfo];
    }

    return value;
}

-(id)objectForKey:(NSString*)aKey orThrowExceptionWithReason:(NSString*)aFailureReason
{
    id value = [self objectForKey:aKey];
    if ((value == nil) || (value == [NSNull null]))
    {
        @throw [MalformedResponseException exceptionWithName: NSInvalidArgumentException reason:aFailureReason userInfo:nil];
    }
    
    return value;
}


@end

@implementation NSArray (HyvesApi)

-(id)objectAtIndex:(NSInteger)aIndex orThrowExceptionWithReason:(NSString*)aFailureReason
{
    if (aIndex < [self count])
    {
        return [self objectAtIndex:aIndex];
    }
    
    @throw [MalformedResponseException exceptionWithName: NSInvalidArgumentException reason:aFailureReason userInfo:nil];
    return nil;
}


@end



