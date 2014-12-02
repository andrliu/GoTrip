//
//  Comment.h
//  GoTrip
//
//  Created by Andrew Liu on 12/1/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "Profile.h"

typedef void(^searchCurrentCommentsBlock)(NSArray *objects, NSError *error);

@interface Comment : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *text;
@property Profile *recipient;
@property Profile *sender;

+ (void) getCurrentCommentsWithCurrentProfile:(Profile *)profile withCompletion:(searchCurrentCommentsBlock)complete;

@end
