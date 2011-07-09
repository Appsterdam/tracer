//
//  RaceTracksViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+RefreshView.h"
#import "RaceApi.h"

@class MBProgressHUD;

@interface RaceTracksViewController : UIViewController_RefreshView <UITableViewDelegate,
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
