//
//  Photo.h
//  GoTrip
//
//  Created by Alex on 12/1/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "Profile.h"
#import "Group.h"

@interface Photo : PFObject <PFSubclassing>

@property PFFile *imageData;
@property BOOL isPublic;
@property Group *group;
@property Profile *ownerProfile;


@end