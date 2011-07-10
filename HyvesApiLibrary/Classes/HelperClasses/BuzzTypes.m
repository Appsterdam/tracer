//
//  BuzzTypes.m
//  HyvesApiLibrary
//
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


#import <Foundation/Foundation.h>
#import "BuzzTypes.h"

HyvesTargetType parseBuzzType(NSString* aTypeString)
{
    static NSDictionary* knownBuzzTypes = nil;
    if (knownBuzzTypes == nil)
    {
        knownBuzzTypes = [[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:TARGET_TYPE_PING], @"ping",
                           [NSNumber numberWithInt:TARGET_TYPE_USER], @"user",
                           [NSNumber numberWithInt:TARGET_TYPE_GADGET], @"gadget",
                           [NSNumber numberWithInt:TARGET_TYPE_BLOG], @"blog",
                           [NSNumber numberWithInt:TARGET_TYPE_WWW], @"www",
                           [NSNumber numberWithInt:TARGET_TYPE_MEDIA], @"media",
                           [NSNumber numberWithInt:TARGET_TYPE_RESPECT], @"respect",
                           [NSNumber numberWithInt:TARGET_TYPE_FRIENDSHIP], @"friendship",
                           [NSNumber numberWithInt:TARGET_TYPE_HANGOUT], @"hangout",
                           [NSNumber numberWithInt:TARGET_TYPE_HUB], @"hub",
                           [NSNumber numberWithInt:TARGET_TYPE_COMMENT], @"comment",
                           [NSNumber numberWithInt:TARGET_TYPE_EMOTION], @"emotion",
                           [NSNumber numberWithInt:TARGET_TYPE_WHERE], @"where",
                           [NSNumber numberWithInt:TARGET_TYPE_PRESENCE], @"presence",
                           [NSNumber numberWithInt:TARGET_TYPE_ALBUM], @"album",
                           [NSNumber numberWithInt:TARGET_TYPE_WHEREURL], @"whereurl",
                           [NSNumber numberWithInt:TARGET_TYPE_POLL], @"poll",
                           [NSNumber numberWithInt:TARGET_TYPE_EVENT], @"event",
                           [NSNumber numberWithInt:TARGET_TYPE_GROUP], @"group",
                           [NSNumber numberWithInt:TARGET_TYPE_THREAD], @"thread",
                           [NSNumber numberWithInt:TARGET_TYPE_CLASSIFIED], @"classified",
                           [NSNumber numberWithInt:TARGET_TYPE_TIP], @"tip",
                           [NSNumber numberWithInt:TARGET_TYPE_TV_PLAYLIST_ENTRY], @"tvplaylistentry",
                           [NSNumber numberWithInt:TARGET_TYPE_FRIEND_INVITATION], @"friendinvitation",
                           nil] retain];
    }
    
    NSNumber* typeNumber = [knownBuzzTypes objectForKey:aTypeString];
    if (typeNumber == nil)
    {
        typeNumber = [NSNumber numberWithInt:TARGET_TYPE_NOFILTER];
    }
    
    return (HyvesTargetType)[typeNumber intValue];
}


NSString* buzzTypeToString(HyvesTargetType aBuzzType)
{
    static NSDictionary* mappingDict;
    
    if (mappingDict == nil)
    {
        mappingDict = [[NSDictionary alloc] initWithObjectsAndKeys:
           @"ping", [NSNumber numberWithInt:TARGET_TYPE_PING],
           @"user", [NSNumber numberWithInt:TARGET_TYPE_USER],
           @"gadget", [NSNumber numberWithInt:TARGET_TYPE_GADGET],
           @"blog", [NSNumber numberWithInt:TARGET_TYPE_BLOG],
           @"www", [NSNumber numberWithInt:TARGET_TYPE_WWW],
           @"media", [NSNumber numberWithInt:TARGET_TYPE_MEDIA],
           @"respect", [NSNumber numberWithInt:TARGET_TYPE_RESPECT],
           @"friendship", [NSNumber numberWithInt:TARGET_TYPE_FRIENDSHIP],
           @"hangout", [NSNumber numberWithInt:TARGET_TYPE_HANGOUT],
           @"hub", [NSNumber numberWithInt:TARGET_TYPE_HUB],
           @"comment", [NSNumber numberWithInt:TARGET_TYPE_COMMENT],
           @"emotion", [NSNumber numberWithInt:TARGET_TYPE_EMOTION],
           @"where", [NSNumber numberWithInt:TARGET_TYPE_WHERE],
           @"presence", [NSNumber numberWithInt:TARGET_TYPE_PRESENCE],
           @"album", [NSNumber numberWithInt:TARGET_TYPE_ALBUM],
           @"whereurl", [NSNumber numberWithInt:TARGET_TYPE_WHEREURL],
           @"poll", [NSNumber numberWithInt:TARGET_TYPE_POLL],
           @"event", [NSNumber numberWithInt:TARGET_TYPE_EVENT],
           @"group", [NSNumber numberWithInt:TARGET_TYPE_GROUP],
           @"thread", [NSNumber numberWithInt:TARGET_TYPE_THREAD],
           @"classified", [NSNumber numberWithInt:TARGET_TYPE_CLASSIFIED],
           @"tip", [NSNumber numberWithInt:TARGET_TYPE_TIP],
           @"tvplaylistentry", [NSNumber numberWithInt:TARGET_TYPE_TV_PLAYLIST_ENTRY],
           @"friendinvitation", [NSNumber numberWithInt:TARGET_TYPE_FRIEND_INVITATION],
           nil];
        
    }
    
    NSString* result = [mappingDict objectForKey:[NSNumber numberWithInt:aBuzzType]];
    
    return result;
}

@implementation HyvesBuzzTypeNumber
@synthesize intValue;

-(id)initWithInt:(NSInteger)aValue
{
    if (self = [super init])
    {
        intValue = aValue;
    }
    
    return self;
}

+(HyvesBuzzTypeNumber*)numberWithInt:(NSInteger)aValue
{
    return [[[HyvesBuzzTypeNumber alloc] initWithInt:aValue] autorelease];
}

-(NSString*)description
{
    return buzzTypeToString(intValue);
}

@end


