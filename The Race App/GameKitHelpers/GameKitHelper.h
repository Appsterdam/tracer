//
//  GameKitHelper.h
//  The Race App
//
//  Created by Rob Longridge on 11-07-16.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameKitHelper : NSObject {
    
}

//+ (GameKitHelper *)sharedGKHelper;
+ (BOOL)isGameCenterAPIAvailable;
+ (GKLocalPlayer *)authenticatedGKLocalPlayer;
+ (void)addGKNotificationObserver:(id)observer selector:(SEL)aSelector;
+ (void)removeGKNotificationObserver:(id)observer;


@end
