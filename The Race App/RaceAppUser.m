//
//  RaceAppUser.m
//  The Race App
//
//  Created by Appsterdam on 7/16/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
