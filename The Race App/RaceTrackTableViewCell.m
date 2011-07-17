//
//  RaceTrackTableViewCell.m
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import "RaceTrackTableViewCell.h"

@implementation RaceTrackTableViewCell

@synthesize trackNameLabel;
@synthesize winnerNameLabel;
@synthesize winnerTimeLabel;
@synthesize checkPointCountLabel;


-(void)loadFromNib
{
    [[NSBundle mainBundle] loadNibNamed:@"RaceTrackTableViewCell" owner:self options:nil];
    
    // Set the content view of the cell.
    [self.contentView addSubview:trackNameLabel];
    [self.contentView addSubview:winnerNameLabel];
    [self.contentView addSubview:winnerTimeLabel];
    [self.contentView addSubview:checkPointCountLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        [self loadFromNib];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [trackNameLabel release];
    [winnerTimeLabel release];
    [winnerNameLabel release];
    [checkPointCountLabel release];
    
    [super dealloc];
}

@end
