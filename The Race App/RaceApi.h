//
//  MyClass.h
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#define API_URL @"http://appsterdam-iosdevcamp.herokuapp.com"

typedef enum {
    RaceGetTracks,
    RaceGetSingleTrack,
    RaceCreateTrack,
    RaceStartRace,
    RaceStopRace,
} RaceRequestType;

@protocol RaceDelegate <NSObject>

@optional

-(void)gotTracks:(NSArray *)_arr;
-(void)finishedRace:(NSDictionary *)_dict;
-(void)startedRace:(NSDictionary *)_dict;
//
//Called when the request didn't go through and resulted with an error
//
-(void)gotError:(NSError *)_err forRequest:(RaceRequestType)_type;



@end


@interface RaceApi : NSObject <ASIHTTPRequestDelegate>  {
    id<RaceDelegate> delegate;
    RaceRequestType requestType;
}
@property (nonatomic, assign) id<RaceDelegate> delegate;

-(void)getTracksAsynchronousAround:(NSString *)_query;
-(void)startRaceWithTrackURI:(NSString *)_ident andUsername:(NSString *)_username;
-(void)finishRaceWithTime:(NSNumber *)_seconds andTrackURI:(NSString *)_ident;

@end
