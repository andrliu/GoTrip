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
@dynamic birthday;
@dynamic memo;
@dynamic avatarData;
@dynamic user;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Profile";
}

@end
