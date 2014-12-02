//
//  Comment.m
//  GoTrip
//
//  Created by Andrew Liu on 12/1/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic text;
@dynamic recipient;
@dynamic sender;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Comment";
}

+ (void) getCurrentCommentsWithCurrentProfile:(Profile *)profile withCompletion:(searchCurrentCommentsBlock)complete
{
    PFQuery *query = [self query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"sender"];
    [query includeKey:@"recipient"];
    [query whereKey:@"recipient" equalTo:profile];
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
