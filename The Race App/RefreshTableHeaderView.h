//
//  RefreshTableHeaderView.h
//  Created by Appsterdam.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//  Based on: http://www.drobnik.com/touch/2009/12/how-to-make-a-pull-to-reload-tableview-just-like-tweetie-2/
//

#import <UIKit/UIKit.h>

#define kReleaseToReloadStatus    0
#define kPullToReloadStatus        1
#define kLoadingStatus            2

@interface RefreshTableHeaderView : UIView 
{
    UILabel*                    statusLabel;
    UILabel*                    lastUpdatedLabel;
    UIImageView*                arrowImage;
    UIActivityIndicatorView*    activityView;
    UILabel*                    networkStatusLabel;
    
    BOOL                        isFlipped;
    
    NSDate*                     lastUpdatedDate;
    UIView*                     progressOverlayView;
    CGFloat                     progressValue;
}

@property(nonatomic, assign) BOOL       isFlipped;
@property(nonatomic, retain) UIView*    progressOverlayView;
@property(nonatomic, assign) CGFloat    progressValue;

@property(nonatomic, retain) NSDate*    lastUpdatedDate;

- (void)flipImageAnimated:(BOOL)animated;
- (void)toggleActivityView:(BOOL)isON;
- (void)setStatus:(int)status;

@end