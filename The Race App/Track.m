//
//  Track.m
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
