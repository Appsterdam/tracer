//
//  MyClass.h
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol RaceDelegate <NSObject>

@optional

-(void)gotResponse:(NSArray *)_arr;
-(void)gotError:(NSError *)_err;

@end


@interface RaceApi : NSObject <ASIHTTPRequestDelegate>  {
    id<RaceDelegate> delegate;
}
@property (nonatomic, assign) id<RaceDelegate> delegate;

-(void)getTracks;
-(void)getTracksAsynchronous;

@end
