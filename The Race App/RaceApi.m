//
//  MyClass.m
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "RaceApi.h"
#import "NSObject+SBJson.h"
#import "Track.h"

@implementation RaceApi

@synthesize delegate;

-(void)getTracks
{
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:@"http://mipdev.neteasy.pl/race/raceapi.php?param=race"]];
    [req setDelegate:self];
    [req startSynchronous];
}

-(void)getTracksAsynchronous
{
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:@"http://mipdev.neteasy.pl/race/raceapi.php?param=race"]];
    [req setDelegate:self];
    [req startAsynchronous];
}



#pragma mark asiformdatarequestdelegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    //NSLog(@"%@", [[request responseString] JSONValue]);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in [[request responseString] JSONValue]) {
        Track *track = [[Track alloc] init];
        track.trackName = [dict objectForKey:@"name"];
        track.trackScore = [dict objectForKey:@"score"];
        track.trackWinner = [dict objectForKey:@"winner"];
        track.trackData = [[dict objectForKey:@"data"] JSONValue];
        
        [result addObject:track];
        [track release];
    }
    
    [delegate gotResponse:result];
}

@end
