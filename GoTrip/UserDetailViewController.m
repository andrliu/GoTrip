//
//  UserDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "UserDetailViewController.h"
#import "CustomCollectionViewCell.h"
#import "Comment.h"

@interface UserDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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

//MARK: view controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Comment getCurrentCommentsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.arrayOfComment = objects;
            [self.collectionView reloadData];
        }
        else
        {
            [self error:error];
        }
    }];
    [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
    self.memoLabel.text = self.profile.memo;
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

//MARK: custom relation status checking method
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

//MARK: custom button title method
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

//MARK: custom button action
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
    }
    [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (!error)
                {
                    [self checkRelationStatus];
                    [self switchButtonTitleBasedOnRelationStatus];
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
                                         if (!error)
                                         {
                                             [Comment getCurrentCommentsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error) {
                                                 if (!error)
                                                 {
                                                     self.arrayOfComment = objects;
                                                     [self.collectionView reloadData];
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
                                }];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: custom imageView method
- (void)setImageView:(UIImageView *)imageView withData:(NSData *)data withLayerRadius:(CGFloat)radius withBorderColor:(CGColorRef)color
{
    imageView.image = [UIImage imageWithData:data];
    [imageView.layer setCornerRadius:radius];
    [imageView setClipsToBounds:YES];
    [imageView.layer setBorderWidth:2.0f];
    [imageView.layer setBorderColor:color];
}

//MARK: collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayOfComment.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Comment *comment = self.arrayOfComment[indexPath.item];
    cell.textView.text = comment.text;
    [cell.textView setFont: [UIFont fontWithName:@"Chalkduster" size:12.0f]];
    [self setImageView:cell.imageView withData:nil withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *stringOfDate = [dateFormatter stringFromDate:comment.createdAt];
    cell.nameLabel.text = [NSString stringWithFormat:@"by %@ %@", comment.sender.firstName, stringOfDate];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width*0.8, self.collectionView.frame.size.height*0.6);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width*0.1, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width*0.1, self.collectionView.frame.size.height);
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
