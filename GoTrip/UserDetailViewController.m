//
//  UserDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "UserDetailViewController.h"
#import "Comment.h"

@interface UserDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UIButton *relationButton;
@property Profile *currentProfile;
@property BOOL isFriend;
@property BOOL isPending;
@property BOOL isRequesting;
@property NSArray *arrayOfComment;

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

- (IBAction)AddCommentOnButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add a comment"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Comment";
     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    UITextField *textFieldForText = alert.textFields.firstObject;
                                    Comment *comment = [Comment object];
                                    comment.text = textFieldForText.text;
                                    comment.sender = self.currentProfile;
                                    comment.recipient = self.profile;
                                    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                     {
                                         //TODO: reload comment
                                     }];
                                }];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: collectionview delegate
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.listArray.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    if (self.isGroup)
//    {
//        Group *group = self.listArray[indexPath.item];
//        cell.imageView.image = [UIImage imageWithData:group.imageData];
//        cell.nameLabel.text = group.name;
//        cell.memoLabel.text = group.destination;
//    }
//    else
//    {
//        Profile *profile = self.listArray[indexPath.item];
//        cell.imageView.image = [UIImage imageWithData:profile.avatarData];
//        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];;
//        cell.memoLabel.text = profile.memo;
//    }
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(self.collectionView.frame.size.width*0.4, self.collectionView.frame.size.width*0.4 +30);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(self.collectionView.frame.size.width*0.3, self.collectionView.frame.size.height);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(self.collectionView.frame.size.width*0.3, self.collectionView.frame.size.height);
//}


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
