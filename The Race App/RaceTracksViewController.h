//
//  RaceTracksViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceApi.h"

@interface RaceTracksViewController : UIViewController <UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        RaceDelegate>
{
    UITableView*    tableView;
    // Array of dictionaries for each of the race tracks.
    NSMutableArray* raceTrackEntries;
    
    //API
    RaceApi *api;
    NSArray *tracks;
}
-(void)getTracksFromAPI;

@property(nonatomic, retain) UITableView*       tableView;
@property(nonatomic, retain) NSMutableArray*    raceTrackEntries;

@end
