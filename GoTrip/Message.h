//
//  Message.h
//  GoTrip
//
//  Created by Jonathan Chou on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "Profile.h"
#import "Group.h"
@class Message;

@interface Message : PFObject <PFSubclassing>

@property NSString *userName;
@property NSDate *timeStamp;
@property NSString *text;
@property Profile *sender;
@property Profile *userRecipient;
@property Group *groupRecipient;


@end