//
//  RaceTrackTableViewCell.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

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


@end
