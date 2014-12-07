//
//  UserDetailViewController.h
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Profile;

@interface UserDetailViewController : UIViewController

@property Profile *profile;
@property Profile *currentProfile;

@end
