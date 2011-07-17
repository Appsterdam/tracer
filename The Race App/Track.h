//
//  Track.h
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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

-(id)initWithTrackName:(NSString*)aTrackName 
            trackScore:(NSString*)aTrackScore
           trackWinner:(NSString*)aTrackWinner
             trackData:(NSArray*)aTrackData;



@end
