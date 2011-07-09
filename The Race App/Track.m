//
//  Track.m
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "Track.h"


@implementation Track
@synthesize trackName, trackScore, trackWinner;
@synthesize trackData;

-(void)dealloc{
    [trackWinner release];
    [trackScore release];
    [trackName release];
    [trackData release];
    
    [super dealloc];
}

@end
