//
//  UIViewController+RefreshView.m
//
//  Created by Sergey.
//

#import "UIViewController+RefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController_RefreshView

- (void) reloadTableViewDataSource
{
    // Override in the child class to trigger data reload.
}

- (UITableView*)tableView
{
    // Override in the child class!
    return nil;
}


- (void) showReloadAnimationAnimated:(BOOL)animated
{
    reloading = YES;
    [refreshHeaderView toggleActivityView:YES];
    
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        [[self tableView] setContentInset:UIEdgeInsetsMake(REFRESH_VIEW_CONTENT_INSET_BOTTOM, 0.0f, 0.0f, 0.0f)];
        
        [UIView commitAnimations];
    }
    else
    {
        [[self tableView] setContentInset:UIEdgeInsetsMake(REFRESH_VIEW_CONTENT_INSET_BOTTOM, 0.0f, 0.0f, 0.0f)];
    }
}

-(void)setRefreshViewProgress:(CGFloat)aProgress
{
    refreshHeaderView.progressValue = aProgress;
}

- (void)dataSourceDidFinishLoadingNewData:(NSDate*)aTimeStamp
{
    reloading = NO;
    [refreshHeaderView setLastUpdatedDate:aTimeStamp];
    [refreshHeaderView flipImageAnimated:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
    [refreshHeaderView setStatus:kPullToReloadStatus];
    [refreshHeaderView toggleActivityView:NO];
    
    [UIView commitAnimations];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!reloading)
    {
        checkForRefresh = YES;  //  only check offset when dragging 
    }
} 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if (reloading) 
    {
        return;
    }
    
    if (checkForRefresh) 
    {
        if (refreshHeaderView.isFlipped 
            && scrollView.contentOffset.y > -(REFRESH_VIEW_CONTENT_INSET_BOTTOM + 5.0)
            && scrollView.contentOffset.y < 0.0f 
            && !reloading) 
        {
            [refreshHeaderView flipImageAnimated:YES];
            [refreshHeaderView setStatus:kPullToReloadStatus];
        } 
        else if (!refreshHeaderView.isFlipped 
                 && scrollView.contentOffset.y < -(REFRESH_VIEW_CONTENT_INSET_BOTTOM + 5.0)) 
        {
            [refreshHeaderView flipImageAnimated:YES];
            [refreshHeaderView setStatus:kReleaseToReloadStatus];
            [refreshHeaderView setProgressValue:0.0];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (reloading) return;
    
    if (scrollView.contentOffset.y <= -(REFRESH_VIEW_CONTENT_INSET_BOTTOM + 5.0)) 
    {
        if([ [[self tableView] dataSource] respondsToSelector:@selector(reloadTableViewDataSource)])
        {
            [self showReloadAnimationAnimated:YES];
            [self reloadTableViewDataSource];
        }
    } 
    checkForRefresh = NO;
}

-(void)emulateReload
{
    if (!reloading)
    {
        [self scrollViewWillBeginDragging:[self tableView]];
        [[self tableView] setContentInset:UIEdgeInsetsMake(REFRESH_VIEW_CONTENT_INSET_BOTTOM + 5.0, 0.0f, 0.0f, 0.0f)];
        [[self tableView] setContentOffset:CGPointMake(0.0, -REFRESH_VIEW_CONTENT_INSET_BOTTOM - 5.0) animated:NO];
        [self scrollViewDidScroll:[self tableView]];
        [self scrollViewDidEndDragging:[self tableView] willDecelerate:YES];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    reloading = NO;
    checkForRefresh = NO;
    refreshHeaderView = [[RefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -REFRESH_VIEW_HEIGHT + 0.0, 
                                    [self tableView].bounds.size.width, REFRESH_VIEW_HEIGHT)];

    [[self tableView] addSubview:refreshHeaderView];
    
}

-(void)viewDidUnload
{
    [super viewDidUnload];

    
    [refreshHeaderView release];
    refreshHeaderView = nil;
}

- (void)dealloc
{
    if (self.isViewLoaded)
    {
        [self viewDidUnload];
    }
    
    [super dealloc];
}


@end
