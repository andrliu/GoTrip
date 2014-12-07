//
//  GroupEditViewController.h
//  GoTrip
//
//  Created by Alex on 12/3/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@class Profile;

@interface GroupEditViewController : UIViewController

@property Group *group;
@property Profile *currentProfile;

@end
