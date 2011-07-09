//
//  RefreshTableHeaderView.m
//
//  Created by Sergey.
//  Based on: http://www.drobnik.com/touch/2009/12/how-to-make-a-pull-to-reload-tableview-just-like-tweetie-2/
//

#import "RefreshTableHeaderView.h"

#import "RefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_COLOR [UIColor grayColor]
#define BORDER_COLOR [UIColor grayColor]

#define STATUS_LABEL_INSET_LEFT 0.0
#define STATUS_LABEL_INSET_BOTTOM 45.0
#define STATUS_LABEL_HEIGHT 20.0

#define LAST_UPDATE_LABEL_INSET_LEFT 0.0
#define LAST_UPDATE_LABEL_INSET_BOTTOM 25.0
#define LAST_UPDATE_LABEL_HEIGHT 20.0

#define NETWORK_STATUS_LABEL_INSET_LEFT 0.0
#define NETWORK_STATUS_LABEL_INSET_BOTTOM 25.0
#define NETWORK_STATUS_LABEL_HEIGHT 20.0

#define ARROW_VIEW_INSET_BOTTOM 35.0
#define ARROW_VIEW_INSET_LEFT   25.0
#define ARROW_VIEW_WIDTH 18.0
#define ARROW_VIEW_HEIGHT 17.0

#define ACTIVITY_VIEW_INSET_BOTTOM 35.0
#define ACTIVITY_VIEW_INSET_LEFT 25.0
#define ACTIVITY_VIEW_WIDTH 20.0
#define ACTIVITY_VIEW_HEIGHT 20.0

@implementation RefreshTableHeaderView

@synthesize isFlipped;
@synthesize lastUpdatedDate;
@synthesize progressOverlayView;
@synthesize progressValue;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 
                                               green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        {
            statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - STATUS_LABEL_INSET_BOTTOM, 
                                                                    frame.size.width, STATUS_LABEL_HEIGHT)];
            
            statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            statusLabel.textColor = TEXT_COLOR;
            statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            statusLabel.backgroundColor = self.backgroundColor;
            statusLabel.opaque = YES;
            statusLabel.textAlignment = UITextAlignmentCenter;
            statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [self addSubview:statusLabel];
            
        }
        
        {
            lastUpdatedLabel = [[UILabel alloc] initWithFrame:
                CGRectMake(LAST_UPDATE_LABEL_INSET_LEFT, frame.size.height - LAST_UPDATE_LABEL_INSET_BOTTOM, 
                           frame.size.width, LAST_UPDATE_LABEL_HEIGHT)];
            
            lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
            lastUpdatedLabel.textColor = TEXT_COLOR;
            lastUpdatedLabel.shadowColor =
            [UIColor colorWithWhite:0.9f alpha:1.0f];
            lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            lastUpdatedLabel.backgroundColor = self.backgroundColor;
            lastUpdatedLabel.opaque = YES;
            lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
            lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:lastUpdatedLabel];
            
        }
        
        {
            networkStatusLabel = 
                [[UILabel alloc] initWithFrame:CGRectMake(NETWORK_STATUS_LABEL_INSET_LEFT, frame.size.height - NETWORK_STATUS_LABEL_INSET_BOTTOM, 
                                                          frame.size.width, NETWORK_STATUS_LABEL_HEIGHT)];
            
            networkStatusLabel.font = [UIFont systemFontOfSize:12.0f];
            networkStatusLabel.textColor = TEXT_COLOR;
            networkStatusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            networkStatusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            networkStatusLabel.backgroundColor = self.backgroundColor;
            networkStatusLabel.opaque = YES;
            networkStatusLabel.textAlignment = UITextAlignmentCenter;
            networkStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:networkStatusLabel];
            
            // Temporary:
            networkStatusLabel.hidden = YES;
            
        }
        
        [self setStatus:kPullToReloadStatus];
        
        {
            arrowImage = 
                [[UIImageView alloc] initWithFrame:CGRectMake(ARROW_VIEW_INSET_LEFT, frame.size.height - ARROW_VIEW_INSET_BOTTOM, 
                                                              ARROW_VIEW_WIDTH, ARROW_VIEW_HEIGHT)];
            
            arrowImage.contentMode = UIViewContentModeScaleAspectFit;
            arrowImage.image = [UIImage imageNamed:@"arrow_up_small.png"];
            [arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
            [self addSubview:arrowImage];
        }
        
        {
            activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.frame = 
                CGRectMake(ACTIVITY_VIEW_INSET_LEFT, frame.size.height - ACTIVITY_VIEW_INSET_BOTTOM, ACTIVITY_VIEW_WIDTH, ACTIVITY_VIEW_HEIGHT);
            activityView.hidesWhenStopped = YES;
            [self addSubview:activityView];
        }
        
        {
            progressOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height, 0.0, 0.0)];
            progressOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            progressOverlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
            
            [self addSubview:progressOverlayView];
            [self bringSubviewToFront:progressOverlayView];
            
            progressValue = 0.0;
            
        }
        
        isFlipped = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context,  kCGPathFillStroke);
    /*
    [BORDER_COLOR setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - 1);
    CGContextAddLineToPoint(context, self.bounds.size.width,
                            self.bounds.size.height - 1);
    CGContextStrokePath(context);
     */
}

- (void)flipImageAnimated:(BOOL)animated
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animated ? .18 : 0.0];
    [arrowImage layer].transform = isFlipped ? 
    CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : 
    CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
    [UIView commitAnimations];
    
    isFlipped = !isFlipped;
}

- (void)setLastUpdatedDate:(NSDate *)newDate 
{
    if (newDate != nil)
    {
        [lastUpdatedDate release];
        lastUpdatedDate = [newDate retain];
        lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@",
                                 NSLocalizedString(@"Last update",@"Refresh header update string"),
                                 [lastUpdatedDate description]];        
    }
    else
    {
        [lastUpdatedDate release];
        lastUpdatedDate = nil;
        // Do not display "Never", but leave it empty. This is for cases where there was no update yet.
        lastUpdatedLabel.text = @""; // NSLocalizedString(@"Last Updated: Never", @"Refresh header update never string");
    }
    
}

- (void)setStatus:(int)status
{
    switch (status) 
    {
        case kReleaseToReloadStatus:
            statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Refresh header release to refresh string");
            break;
        case kPullToReloadStatus:
            statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Refresh header pull down to refresh string");
            break;
        case kLoadingStatus:
            statusLabel.text = NSLocalizedString(@"Loading...", @"Refresh header loading string");
            break;
        default:
            break;
    }
}

- (void)toggleActivityView:(BOOL)isON
{
    if (!isON) 
    {
        [activityView stopAnimating];
        arrowImage.hidden = NO;
    } 
    else 
    {
        [activityView startAnimating];
        arrowImage.hidden = YES;
        [self setStatus:kLoadingStatus];
    }
}

-(void)setProgressValue:(CGFloat)aProgressValue
{
    NSAssert(aProgressValue >= 0.0 && aProgressValue <= 1.0, @"Progress value must lie in the interval [0, 1]");
    progressValue = aProgressValue;
    CGRect progressFrame = self.bounds;
    progressFrame.size.width = progressFrame.size.width * aProgressValue;
    // TODO: Use animation!
    progressOverlayView.frame = progressFrame;
}


- (void)dealloc 
{
    [progressOverlayView release];
    [lastUpdatedDate release];
    [lastUpdatedLabel release];
    [statusLabel release];
    [networkStatusLabel release];
    [arrowImage release];
    [activityView release];
    

    [super dealloc];
}

@end
