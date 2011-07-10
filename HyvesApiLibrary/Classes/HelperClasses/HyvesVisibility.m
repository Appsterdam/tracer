//
//  HyvesVisibility.m
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

#import "HyvesVisibility.h"



/*
 VISIBILITY_NONE = 0,
 VISIBILITY_PRIVATE = 1,
 VISIBILITY_FRIEND = 2,
 VISIBILITY_HUB = 3, // same as VISIBILITY_GROUP
 VISIBILITY_PUBLIC = 4,                //hyvers
 VISIBILITY_SUPERPUBLIC = 5,            //everybody
 VISIBILITY_SPECIAL = 6,
 VISIBILITY_FRIENDS_OF_FRIENDS = 7,
 VISIBILITY_NETWORK = 8,
 VISIBILITY_FRIENDGROUP = 10,
 
*/ 
 
HyvesVisibility hyvesVisibilityFromString(const NSString* aVisibilityString)
{
    if ([aVisibilityString isEqualToString:@"none"])
    {
        return VISIBILITY_NONE;
    }
    else if ([aVisibilityString isEqualToString:@"private"])
    {
        return VISIBILITY_PRIVATE;
    }
    else if ([aVisibilityString isEqualToString:@"friend"])
    {
        return VISIBILITY_FRIEND;
    }
    else if ([aVisibilityString isEqualToString:@"hub"])
    {
        return VISIBILITY_HUB;
    }
    else if ([aVisibilityString isEqualToString:@"friendgroup"])
    {
        return VISIBILITY_FRIENDGROUP;
    }
    else if ([aVisibilityString isEqualToString:@"public"])
    {
        return VISIBILITY_PUBLIC;
    }
    else if ([aVisibilityString isEqualToString:@"superpublic"])
    {
        return VISIBILITY_SUPERPUBLIC;
    }
    else if ([aVisibilityString isEqualToString:@"special"])
    {
        return VISIBILITY_SPECIAL;
    }
    else if ([aVisibilityString isEqualToString:@"network"])
    {
        return VISIBILITY_NETWORK;
    }
    else if ([aVisibilityString isEqualToString:@"friends_of_friends"])
    {
        return VISIBILITY_FRIENDS_OF_FRIENDS;
    }
    
    return VISIBILITY_NONE;
}

NSString* hyvesVisibilityToString(const HyvesVisibility aVisibility)
{
    switch (aVisibility) 
    {
        case VISIBILITY_NONE:
            return @"none";
        case VISIBILITY_PRIVATE:
            return @"private";
        case VISIBILITY_FRIEND:
            return @"friend";
        case VISIBILITY_HUB:
            return @"hub";
        case VISIBILITY_FRIENDGROUP:
            return @"friendgroup";
        case VISIBILITY_PUBLIC:
            return @"public";
        case VISIBILITY_SUPERPUBLIC:
            return @"superpublic";
        case VISIBILITY_SPECIAL:
            return @"special";
        case VISIBILITY_NETWORK:
            return @"network";
        case VISIBILITY_FRIENDS_OF_FRIENDS:
            return @"friends_of_friends";
        default:
            return @"default";
    }
    return @"default";
}
