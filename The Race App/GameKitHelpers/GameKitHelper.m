//
//  GameKitHelper.m
//  The Race App
//
//  Created by Rob Longridge on 11-07-16.
//  Copyright 2011 Pawn Company Ltd. All rights reserved.
//

#import "GameKitHelper.h"


@implementation GameKitHelper



+ (BOOL)isGameCenterAPIAvailable
{
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // The device must be running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

+ (GKLocalPlayer *)authenticatedGKLocalPlayer
{
    __block GKLocalPlayer *currentPlayer = [GKLocalPlayer localPlayer];

    [currentPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (![currentPlayer isAuthenticated]) {
            currentPlayer = nil;
        }
    }];
    return currentPlayer;
}

+ (void)addGKNotificationObserver:(id)observer selector:(SEL)aSelector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

+ (void)removeGKNotificationObserver:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}
        
@end
