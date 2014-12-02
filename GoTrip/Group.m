//
//  Group.m
//  GoTrip
//
//  Created by Alex on 11/25/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "Group.h"
#import "Profile.h"

@implementation Group

@dynamic name;
@dynamic canonicalName;
@dynamic destination;
@dynamic imageData;
@dynamic memo;
@dynamic profiles;
@dynamic creator;
@dynamic startDate;
@dynamic endDate;
@dynamic sizeLimit;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Group";
}




@end
