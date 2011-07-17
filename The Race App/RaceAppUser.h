//
//  RaceAppUser.h
//  The Race App
//
//  Created by Appsterdam on 7/16/11.
//  Use this code at your own risk for whatever you want.
//  But if you make money out of it, please give something back to Appsterdam.
//

#import <Foundation/Foundation.h>

// TODO: Convert to NSManagedObject when we have proper caching!
@interface RaceAppUser : NSObject
{
    NSString*   faceBookUID;
    NSString*   firstName;
    NSString*   middleName;
    NSString*   lastName;
    NSString*   gender;
    NSString*   homeTown;
}

@property(nonatomic, retain) NSString*   faceBookUID;
@property(nonatomic, retain) NSString*   firstName;
@property(nonatomic, retain) NSString*   lastName;
@property(nonatomic, retain) NSString*   gender;
@property(nonatomic, retain) NSString*   middleName;
@property(nonatomic, retain) NSString*   homeTown;

@end
