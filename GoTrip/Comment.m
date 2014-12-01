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

@end
