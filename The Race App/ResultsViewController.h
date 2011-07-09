//
//  ResultViewController.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+RefreshView.h"

@interface ResultsViewController : UIViewController_RefreshView <UITableViewDataSource,
                                                                UITabBarDelegate>
{
    // Shows the result text message.
    UILabel*        resultTextLabel;
    // Shows the time of the complete race.
    UILabel*        ownTimeLabel;
    // Shows the time of the best result.
    UILabel*        bestTimeLabel;
    // Shows the person's name who achieved the best result
    UILabel*        bestResultNameLabel;
    // Hall of fame table view.
    // Needs to be called tableView for the refresh functionality to work.
    UITableView*    tableView;
    
    NSArray*        results;
}

@property(nonatomic, retain) IBOutlet UILabel*      resultTextLabel;
@property(nonatomic, retain) IBOutlet UILabel*      ownTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel*      bestTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel*      bestResultNameLabel;
@property(nonatomic, retain) IBOutlet UITableView*  tableView;
@property(nonatomic, retain) IBOutlet NSArray*      results;

@end
