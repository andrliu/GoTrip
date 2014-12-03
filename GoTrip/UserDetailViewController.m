//
//  UserDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "UserDetailViewController.h"
#import "CustomCollectionViewCell.h"
#import "ChatViewController.h"
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
    [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:self.imageView.frame.size.width/2 withBorderColor:[UIColor blackColor].CGColor];
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
    self.isFriend = [self getBoolValueByCheckId:self.profile.objectId inArray:self.currentProfile.friends];
    self.isPending = [self getBoolValueByCheckId:self.profile.objectId inArray:self.currentProfile.pendingFriends];
    self.isRequesting = [self getBoolValueByCheckId:self.currentProfile.objectId inArray:self.profile.pendingFriends];
}

- (BOOL)getBoolValueByCheckId:(NSString *)objectId inArray:(NSArray *)array
{
    for (Profile *profile in array)
    {
        if ([profile.objectId isEqual:objectId])
        {
            return YES;
        }
    }
    return NO;
}

//MARK: custom button title setting method
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
        self.currentProfile.friends = [self removeObjectId:self.profile.objectId inArray:self.currentProfile.friends];
        self.profile.friends = [self removeObjectId:self.currentProfile.objectId inArray:self.profile.friends];
    }
    else if ([self.relationButton.titleLabel.text isEqual:@"Invite"])
    {
        self.profile.pendingFriends = [self addObjectId:currentUserProfile inArray:self.profile.pendingFriends];
    }
    else if ([self.relationButton.titleLabel.text isEqual:@"Accept"])
    {
        self.currentProfile.pendingFriends = [self removeObjectId:self.profile.objectId inArray:self.currentProfile.pendingFriends];
        self.profile.friends = [self addObjectId:currentUserProfile inArray:self.profile.friends];
        self.currentProfile.friends = [self addObjectId:userProfile inArray:self.currentProfile.friends];
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

- (NSArray *)removeObjectId:(NSString *)ObjectId inArray:(NSArray *)array
{
    NSMutableArray *currentUserFriendArray = [array mutableCopy];
    NSMutableArray *currentUserFriendsToRemove = [NSMutableArray array];
    for (PFObject *object in currentUserFriendArray)
    {
        if ([[object objectId] isEqual:ObjectId])
        {
            [currentUserFriendsToRemove addObject:object];
        }
    }
    [currentUserFriendArray removeObjectsInArray:currentUserFriendsToRemove];
    return currentUserFriendArray;
}

- (NSArray *)addObjectId:(PFObject *)Object inArray:(NSArray *)array
{
    if (array.count == 0)
    {
        return @[Object];
    }
    else
    {
        NSMutableArray *userPendingFriendArray = [array mutableCopy];
        [userPendingFriendArray addObject:Object];
        return userPendingFriendArray;
    }
}

- (IBAction)addCommentOnButtonPressed:(UIButton *)sender
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
                                             [Comment getCurrentCommentsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error)
                                             {
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
    if (data)
    {
        imageView.image = [UIImage imageWithData:data];
    }
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
    [self setImageView:cell.backgroundImageView withData:nil withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
    [self setImageView:cell.imageView withData:comment.sender.avatarData withLayerRadius:cell.imageView.frame.size.width/2 withBorderColor:[UIColor whiteColor].CGColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *stringOfDate = [dateFormatter stringFromDate:comment.createdAt];
    cell.nameLabel.text = [NSString stringWithFormat:@"by %@ %@", comment.sender.firstName, stringOfDate];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width*0.7, self.collectionView.frame.size.height*0.6);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width*0.15, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width*0.15, self.collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return -self.collectionView.frame.size.width*0.3;
}

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSMutableArray *attributes = [NSMutableArray new];
//
//    NSIndexPath *decorationIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//
//    UICollectionViewLayoutAttributes *decorationAttributes =
//    [UICollectionViewLayoutAttributes
//     layoutAttributesForDecorationViewOfKind:@"BackgroundView"
//     withIndexPath:decorationIndexPath];
//
//    decorationAttributes.frame = CGRectMake(0.0f,
//                                            0.0f,
//                                            self.collectionViewContentSize.width,
//                                            self.collectionViewContentSize.height);
//
//    [allAttributes addObject:decorationAttributes];
//
//    ... now add the rest of the attributes ...
//
//    return attributes;
//}
//
//-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray* array = [super layoutAttributesForElementsInRect:rect];
//
//    UICollectionViewLayoutAttributes* att = [array lastObject];
//    if (att){
//        CGFloat lastY = att.frame.origin.y + att.frame.size.height;
//        CGFloat diff = self.collectionView.frame.size.height - lastY;
//        if (diff > 0){
//            for (UICollectionViewLayoutAttributes* a in array){
//                a.frame = CGRectMake(a.frame.origin.x, a.frame.origin.y + diff/2, a.frame.size.width, a.frame.size.height) ;
//            }
//        }
//    }
//    return array;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *cvc = segue.destinationViewController;
    cvc.passedRecipient = self.profile;
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
