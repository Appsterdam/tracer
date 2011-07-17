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
#import <CoreLocation/CoreLocation.h>

@implementation RaceApi

@synthesize delegate;
//
//Method gets all the tracks in synchronous manner
//
-(void)getTracks
{
    NSString *url = [NSString stringWithFormat:@"%@/%@", API_URL, @"tracks.json"];
    requestType = RaceGetTracks;
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:url]];
    
    [req setDelegate:self];
    [req startSynchronous];
}
//
//Method gets all the tracks in asynchronous manner
//
-(void)getTracksAsynchronousAround:(NSString *)_query{
    NSString *url = [NSString stringWithFormat:@"%@/search.json", API_URL];
    requestType = RaceGetTracks;
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:url]];
    [req setPostValue:_query forKey:@"q"];
    [req setDelegate:self];
    [req startAsynchronous];
}
-(void)startRaceWithTrackURI:(NSString *)_ident andUsername:(NSString *)_username{
    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL, _ident];
    requestType = RaceStartRace;
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:url]];
    [req setRequestMethod:@"POST"];
    [req setPostValue:_username forKey:@"username"];
    [req setDelegate:self]; 
    [req startAsynchronous];
}

-(void)finishRaceWithTime:(NSNumber *)_seconds andTrackURI:(NSString *)_ident{
    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL, _ident];
    requestType = RaceStopRace;
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:url]];
    [req setRequestMethod:@"POST"];
    [req setPostValue:_seconds forKey:@"time"];
    [req setDelegate:self];
    [req startAsynchronous];
}
-(void)uploadTrackWithName:(NSString *)_name andData:(NSString *)_data{
    NSString *url = [NSString stringWithFormat:@"%@/tracks/create.json", API_URL];
    requestType = RaceCreateTrack;
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:
                               [NSURL URLWithString:url]];
    [req setRequestMethod:@"POST"];
    [req setPostValue:_name forKey:@"name"];
    [req setPostValue:_data forKey:@"data"];
    [req setDelegate:self];
    [req startAsynchronous];
}

#pragma mark asiformdatarequestdelegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    
    switch (requestType) {
        case RaceGetTracks:
        {
            NSLog(@"%@", [request responseString]);
            NSMutableArray *result = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [[[request responseString] JSONValue] objectForKey:@"data"]) {
                NSMutableArray *checkpoints = [[NSMutableArray alloc] init];
                
                for (NSDictionary *loc in [dict objectForKey:@"data"]) {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[loc objectForKey:@"lat"] doubleValue] 
                                                                       longitude:[[loc objectForKey:@"lon"] doubleValue]];
                    [checkpoints addObject:location];
                    [location release];
                    location = nil;         
                }
                
                Track *track = [[Track alloc] initWithTrackName:[dict objectForKey:@"name"] 
                                                     trackScore:[[dict objectForKey:@"best_time"] stringValue]
                                                    trackWinner:[dict objectForKey:@"winner"] 
                                                      trackData:checkpoints 
                                                  trackStartURI:[dict objectForKey:@"start_uri"] 
                                                       trackURI:[dict objectForKey:@"uri"]];

                
                [result addObject:track];
                [track release];
                track = nil;
            }
            [delegate gotTracks:result];
            [request release];
            request = nil;
            
        } break;
        case RaceCreateTrack:
        {
            //has been implemented elsewhere...
            [request release];
            request = nil;
            
        } break;
        case RaceStartRace:
        {
            [delegate startedRace:[[request responseString] JSONValue]];
            [request release];
            request = nil;
            
        } break;
        case RaceStopRace:
        {
            [delegate finishedRace:[[request responseString] JSONValue]];
            [request release];
            request = nil;
            
        } break;
            
        default:
            break;
    }
}

@end
