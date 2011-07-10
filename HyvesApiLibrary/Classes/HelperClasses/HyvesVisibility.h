//
//  HyvesVisibility.h
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

typedef enum 
{
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
} 
HyvesVisibility;

HyvesVisibility hyvesVisibilityFromString(const NSString* aVisibilityString);
NSString* hyvesVisibilityToString(const HyvesVisibility aVisibility);