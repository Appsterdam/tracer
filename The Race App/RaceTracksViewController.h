//
//  RaceTracksViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RaceTracksViewController : UIViewController <UITableViewDelegate,
                                                        UITableViewDataSource>
{
    UITableView*    tableView;
    // Array of dictionaries for each of the race tracks.
    NSMutableArray* raceTrackEntries;
}

@property(nonatomic, retain) UITableView*       tableView;
@property(nonatomic, retain) NSMutableArray*    raceTrackEntries;

@end
