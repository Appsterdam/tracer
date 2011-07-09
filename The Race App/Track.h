//
//  Track.h
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Track : NSObject {
    NSString *trackName;
    NSString *trackScore;
    NSString *trackWinner;
    NSArray *trackData;
}
@property (nonatomic, retain) NSString *trackName;
@property (nonatomic, retain) NSString *trackScore;
@property (nonatomic, retain) NSString *trackWinner;
@property (nonatomic, retain) NSArray *trackData;

@end
