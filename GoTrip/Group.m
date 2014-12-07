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
@dynamic imageFile;
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

+ (void) getCurrentGroupsWithCurrentProfile:(Profile *)profile withCompletion:(searchCurrentGroupsBlock)complete
{
    PFQuery *query = [self query];
    [query orderByAscending:@"canonicalName"];
    [query includeKey:@"profiles"];
    [query whereKey:@"profiles" equalTo:profile];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects,nil);
         }
         else
         {
             complete(nil,error);
         }
     }];
}

@end
