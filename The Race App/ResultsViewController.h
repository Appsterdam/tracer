//
//  ResultViewController.h
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <UIKit/UIKit.h>
#import "UIViewController+RefreshView.h"

@interface ResultsViewController : UIViewController_RefreshView <UITableViewDataSource,
                                                                 UITableViewDelegate>
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
    // For now - an array of dictionaries with names and times.
    NSArray*        results;
}

@property(nonatomic, retain) IBOutlet UILabel*      resultTextLabel;
@property(nonatomic, retain) IBOutlet UILabel*      ownTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel*      bestTimeLabel;
@property(nonatomic, retain) IBOutlet UILabel*      bestResultNameLabel;
@property(nonatomic, retain) IBOutlet UITableView*  tableView;
@property(nonatomic, retain) IBOutlet NSArray*      results;

@end
