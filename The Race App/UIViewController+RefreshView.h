//
//  UIViewController+RefreshView.h
//
//  Created by Sergey.
//

#import "RefreshTableHeaderView.h"

#define REFRESH_VIEW_CONTENT_INSET_BOTTOM 45.0
#define REFRESH_VIEW_HEIGHT 480.0

@interface UIViewController_RefreshView : UIViewController 
{
    RefreshTableHeaderView*             refreshHeaderView;
    BOOL                                checkForRefresh;
    BOOL                                reloading;
}

// Override this function in the child class to trigger data reload.
- (void)reloadTableViewDataSource;

// The child class must either derive from UITableViewController or have a tableView property.
- (UITableView*)tableView;

// Call this function when data loading has been finished.
- (void)dataSourceDidFinishLoadingNewData:(NSDate*)aTimeStamp;

// Show progress bar with the given progress in the refresh view.
-(void)setRefreshViewProgress:(CGFloat)aProgress;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

// Emultate reload programmatically.
-(void)emulateReload;

@end
