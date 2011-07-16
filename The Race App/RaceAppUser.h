//
//  RaceAppUser.h
//  The Race App
//
//  Created by Sergey Novitsky on 7/16/11.
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
