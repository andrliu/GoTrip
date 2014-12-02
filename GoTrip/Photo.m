//
//  Photo.m
//  GoTrip
//
//  Created by Alex on 12/1/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic imageData;
@dynamic isPublic;
@dynamic group;
@dynamic ownerProfile;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Photo";
}


@end
