//
//  Profile.h
//  GoTrip
//
//  Created by Andrew Liu on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "User.h"

@interface Profile : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *canonicalFirstName;
@property (nonatomic, strong) NSString *canonicalLastName;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSData *avatarData;
@property (nonatomic, strong) User *user;

@end