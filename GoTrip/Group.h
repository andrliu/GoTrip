//
//  Group.h
//  GoTrip
//
//  Created by Alex on 11/25/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
@class Profile;

@interface Group : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *canonicalName;
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) Profile *creator;
@property (nonatomic, strong) NSArray *profiles;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSNumber *sizeLimit;

@end
