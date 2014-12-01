//
//  Profile.m
//  GoTrip
//
//  Created by Andrew Liu on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "Profile.h"

@implementation Profile

@dynamic objectId;
@dynamic facebookID;
@dynamic firstName;
@dynamic lastName;
@dynamic canonicalFirstName;
@dynamic canonicalLastName;
@dynamic locationName;
@dynamic gender;
@dynamic birthDate;
@dynamic memo;
@dynamic avatarData;
@dynamic friends;
@dynamic pendingFriends;
@dynamic user;
@dynamic isMessaging;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Profile";
}

+ (void) getCurrentProfileWithCompletion:(searchCurrentProfileBlock)complete
{
    PFQuery *profileQuery = [self query];
    [profileQuery includeKey:@"friends"];
    [profileQuery includeKey:@"pendingFriends"];
    [profileQuery whereKey:@"user" equalTo:[User currentUser]];
    [profileQuery includeKey:@"isMessaging"];
    [profileQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (!error)
         {
             Profile *profile = (Profile *)object;
             complete(profile,nil);
         }
         else
         {
             complete(nil,error);
         }
     }];

}

@end
