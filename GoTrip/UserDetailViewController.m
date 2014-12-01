//
//  UserDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "UserDetailViewController.h"
#import "Profile.h"

@interface UserDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UIButton *relationButton;
@property Profile *currentProfile;
@property BOOL isFriend;
@property BOOL isPending;
@property BOOL isRequesting;

@end

@implementation UserDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.imageView.image = [UIImage imageWithData:self.profile.avatarData];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
    self.memoLabel.text = self.profile.memo;
//    NSDate *now = [NSDate date];
//    NSDateComponents* age = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
//                                                            fromDate:birth
//                                                              toDate:now
//                                                             options:0];
//    self.ageLabel.text = [NSString stringWithFormat:@"%d",[age year]];
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
     {
         if (!error)
         {
             self.currentProfile = profile;
             [self checkRelationStatus];
             [self switchButtonTitleBasedOnRelationStatus];
         }
         else
         {
             [self error:error];
         }
     }];
}

- (void)checkRelationStatus
{
    for (Profile *profile in self.currentProfile.friends)
    {
        if ([profile.objectId isEqual:self.profile.objectId])
        {
            self.isFriend = YES;
            break;
        }
        else
        {
            self.isFriend = NO;
        }
    }
    for (Profile *profile in self.currentProfile.pendingFriends)
    {
        if ([profile.objectId isEqual:self.profile.objectId])
        {
            self.isPending = YES;
            break;
        }
        else
        {
            self.isPending = NO;
        }
    }
    for (Profile *profile in self.profile.pendingFriends)
    {
        if ([profile.objectId isEqual:self.currentProfile.objectId])
        {
            self.isRequesting = YES;
            break;
        }
        else
        {
            self.isRequesting = NO;
        }
    }
}

- (void)switchButtonTitleBasedOnRelationStatus
{
    if (self.isFriend)
    {
        [self.relationButton setTitle:@"Friend" forState:UIControlStateNormal];
    }
    else
    {
        if (self.isPending == YES && self.isRequesting == NO)
        {
            [self.relationButton setTitle:@"Accept" forState:UIControlStateNormal];
        }
        else if (self.isPending == NO && self.isRequesting == YES)
        {
            [self.relationButton setTitle:@"Pending" forState:UIControlStateNormal];
        }
        else
        {
            [self.relationButton setTitle:@"Invite" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)changeRelationOnButtonPressed:(UIButton *)sender
{
    PFObject *currentUserProfile = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                objectId:self.currentProfile.objectId];
    PFObject *userProfile = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                objectId:self.profile.objectId];
    if ([self.relationButton.titleLabel.text isEqual:@"Friend"])
    {
        NSMutableArray *currentUserFriendArray = [self.currentProfile.friends mutableCopy];
        for (PFObject *object in currentUserFriendArray)
        {
            if ([[object objectId] isEqual:self.profile.objectId])
            {
                [currentUserFriendArray removeObject:object];
                self.currentProfile.friends = currentUserFriendArray;
            }
        }
        NSMutableArray *userFriendArray = [self.profile.friends mutableCopy];
        for (PFObject *object in userFriendArray)
        {
            if ([[object objectId] isEqual:self.currentProfile.objectId])
            {
                [userFriendArray removeObject:object];
                self.profile.friends = userFriendArray;
            }
        }
        [self.relationButton setTitle:@"Invite" forState:UIControlStateNormal];
    }
    else if ([self.relationButton.titleLabel.text isEqual:@"Invite"])
    {
        if (self.profile.pendingFriends.count == 0)
        {
            self.profile.pendingFriends = @[currentUserProfile];
        }
        else
        {
            NSMutableArray *userPendingFriendArray = [self.profile.pendingFriends mutableCopy];
            [userPendingFriendArray addObject:currentUserProfile];
            self.profile.pendingFriends = userPendingFriendArray;
        }
        [self.relationButton setTitle:@"Pending" forState:UIControlStateNormal];
    }
    else if ([self.relationButton.titleLabel.text isEqual:@"Accept"])
    {
        NSMutableArray *currentUserPendingFriendArray = [self.currentProfile.pendingFriends mutableCopy];
        for (PFObject *object in currentUserPendingFriendArray)
        {
            if ([[object objectId] isEqual:self.profile.objectId])
            {
                [currentUserPendingFriendArray removeObject:object];
                self.currentProfile.pendingFriends = currentUserPendingFriendArray;
            }
        }
        if (self.profile.friends.count == 0)
        {
            self.profile.friends = @[currentUserProfile];
        }
        else
        {
            NSMutableArray *userFriendArray = [self.profile.friends mutableCopy];
            [userFriendArray addObject:currentUserProfile];
            self.profile.friends = userFriendArray;
        }
        if (self.currentProfile.friends.count == 0)
        {
            self.currentProfile.friends = @[userProfile];
        }
        else
        {
            NSMutableArray *userCurrentFriendArray = [self.currentProfile.friends mutableCopy];
            [userCurrentFriendArray addObject:userProfile];
            self.currentProfile.friends = userCurrentFriendArray;
        }
        [self.relationButton setTitle:@"Friend" forState:UIControlStateNormal];
    }
    [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (!error)
                {
                    NSLog(@"save finished");
                }
                else
                {
                    [self error:error];
                }
            }];
        }
        else
        {
            [self error:error];
        }
    }];
}

//MARK: UIAlert
- (void)error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
