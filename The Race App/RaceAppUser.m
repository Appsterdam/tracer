//
//  RaceAppUser.m
//  The Race App
//
//  Created by Sergey Novitsky on 7/16/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceAppUser.h"

@implementation RaceAppUser

@synthesize faceBookUID;
@synthesize firstName;
@synthesize lastName;
@synthesize gender;
@synthesize middleName;
@synthesize homeTown;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc
{
    [faceBookUID release];
    [firstName release];
    [lastName release];
    [gender release];
    [middleName release];
    [homeTown release];
    
    [super dealloc];
}


@end
