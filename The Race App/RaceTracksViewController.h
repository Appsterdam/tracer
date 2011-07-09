//
//  RaceTracksViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceApi.h"
#import "MBProgressHUD.h"

@interface RaceTracksViewController : UIViewController <UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        RaceDelegate>
{
    UITableView*    tableView;
    MBProgressHUD*  hud;
    
    //API
    RaceApi*        api;
    NSArray*        tracks;
}
-(void)getTracksFromAPI;

@property(nonatomic, retain) UITableView*       tableView;
@property(nonatomic, retain) NSArray*           tracks;

@end
