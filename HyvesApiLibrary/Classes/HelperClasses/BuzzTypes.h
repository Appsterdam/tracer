//
//  BuzzType.h
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

typedef enum
{
    TARGET_TYPE_NOFILTER,
    TARGET_TYPE_PING,
    TARGET_TYPE_USER,
    TARGET_TYPE_GADGET,
    TARGET_TYPE_BLOG,
    TARGET_TYPE_WWW,
    TARGET_TYPE_MEDIA,
    TARGET_TYPE_RESPECT,
    TARGET_TYPE_FRIENDSHIP,
    TARGET_TYPE_HANGOUT,
    TARGET_TYPE_HUB,
    TARGET_TYPE_COMMENT,
    TARGET_TYPE_EMOTION,
    TARGET_TYPE_WHERE,
    TARGET_TYPE_PRESENCE,
    TARGET_TYPE_ALBUM,
    TARGET_TYPE_WHEREURL,
    TARGET_TYPE_POLL,
    TARGET_TYPE_EVENT,
    TARGET_TYPE_GROUP,
    TARGET_TYPE_THREAD,
    TARGET_TYPE_CLASSIFIED,
    TARGET_TYPE_TIP,
    TARGET_TYPE_TV_PLAYLIST_ENTRY,
    
    // Must be somewhere at the end...
    TARGET_TYPE_FRIEND_INVITATION = 100
} HyvesTargetType;

typedef enum
{
    BUZZACTION_NOFILTER,
    CREATE,
    SUBSCRIBE
} HyvesBuzzAction;

NSString* buzzTypeToString(HyvesTargetType aBuzzType);

@interface HyvesBuzzTypeNumber : NSObject
{
    NSInteger intValue;
}

@property(assign) NSInteger intValue;

-(id)initWithInt:(NSInteger)aValue;
+(HyvesBuzzTypeNumber*)numberWithInt:(NSInteger)aValue;

-(NSString*)description;
HyvesTargetType parseBuzzType(NSString* aTypeString);

@end



