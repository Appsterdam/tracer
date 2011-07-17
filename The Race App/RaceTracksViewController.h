//
//  RaceTracksViewController.h
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
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
