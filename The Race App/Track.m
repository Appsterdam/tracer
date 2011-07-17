//
//  Track.m
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "Track.h"


@implementation Track
@synthesize trackName, trackScore, trackWinner, trackStartURI, trackURI;
@synthesize trackData;


-(id)initWithTrackName:(NSString*)aTrackName 
            trackScore:(NSString*)aTrackScore
           trackWinner:(NSString*)aTrackWinner
             trackData:(NSArray*)aTrackData
              trackStartURI:(NSString *)aStartTrackURI
              trackURI:(NSString *)aTrackURI
{
    self = [super init];
    
    if (self != nil)
    {
        self.trackWinner = aTrackWinner;
        self.trackName = aTrackName;
        self.trackScore = aTrackScore;
        self.trackData = aTrackData;
        self.trackStartURI = aStartTrackURI;
        self.trackURI = aTrackURI;
    }
    
    return self;
}

-(id)initWithTrackName:(NSString*)aTrackName 
            trackScore:(NSString*)aTrackScore
           trackWinner:(NSString*)aTrackWinner
             trackData:(NSArray*)aTrackData
{
    self = [super init];
    
    if (self != nil)
    {
        self.trackWinner = aTrackWinner;
        self.trackName = aTrackName;
        self.trackScore = aTrackScore;
        self.trackData = aTrackData;
    }
    
    return self;
}


-(void)dealloc
{
    [trackWinner release];
    [trackScore release];
    [trackName release];
    [trackData release];
    [trackStartURI release];
    [trackURI release];
    
    [super dealloc];
}

@end
