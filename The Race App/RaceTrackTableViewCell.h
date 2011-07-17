//
//  RaceTrackTableViewCell.h
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <UIKit/UIKit.h>
#import "TrackThumbView.h"

@interface RaceTrackTableViewCell : UITableViewCell
{
    UILabel*    trackNameLabel;
    UILabel*    winnerTimeLabel;
    UILabel*    checkPointCountLabel;
    UILabel*    winnerNameLabel;
}

@property(nonatomic, retain) IBOutlet UILabel*    trackNameLabel;
@property(nonatomic, retain) IBOutlet UILabel*    winnerTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel*    checkPointCountLabel;
@property(nonatomic, retain) IBOutlet UILabel*    winnerNameLabel;
@property(nonatomic, retain) IBOutlet TrackThumbView *trackThumbnail;

@end
