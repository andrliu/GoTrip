//
//  User.m
//  GoTrip
//
//  Created by Andrew Liu on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "User.h"

@implementation User

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"User";
}

@end
