//
//  MessageViewController.h
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Profile.h"
#import "JSQMessagesViewController.h"


@interface ChatViewController : JSQMessagesViewController

@property Profile *passedProfile;
@property Profile *passedRecipient;

@end
