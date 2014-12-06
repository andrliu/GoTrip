//
//  GroupDetailViewController.h
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@class Profile;

@interface GroupDetailViewController : UIViewController

@property Group *group;
@property Profile *currentProfile;
@property NSIndexPath *indexPath;

@end
