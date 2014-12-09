//
//  ActivityViewController.h
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface ActivityViewController : UIViewController

@property Profile *currentProfile;
@property NSArray *userProfiles;

@end
