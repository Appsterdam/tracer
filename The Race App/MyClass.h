//
//  MyClass.h
//  The Race App
//
//  Created by Peter Tuszynski on 7/9/11.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RaceDelegate <NSObject>

@optional

-(void)gotResponse:(NSDictionary *)_dict;
-(void)gotError:(NSError *)_err;

@end


@interface MyClass : NSObject {
    id<RaceDelegate> delegate;
}
@property (nonatomic, assign) id<RaceDelegate> delegate;

-(void)getTracks;

@end
