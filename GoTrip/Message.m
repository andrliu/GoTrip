//
//  Message.m
//  GoTrip
//
//  Created by Jonathan Chou on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "Message.h"

@implementation Message

@dynamic userName;
@dynamic timeStamp;
@dynamic text;


+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Message";
}


@end