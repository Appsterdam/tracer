//
//  MyClass.h
//  The Race App
//
//  Created by Appsterdam on 7/9/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol RaceDelegate <NSObject>

@optional

-(void)gotResponse:(NSArray *)_arr;
-(void)gotError:(NSError *)_err;

@end


@interface RaceApi : NSObject <ASIHTTPRequestDelegate>  {
    id<RaceDelegate> delegate;
}
@property (nonatomic, assign) id<RaceDelegate> delegate;

-(void)getTracks;
-(void)getTracksAsynchronous;

@end
