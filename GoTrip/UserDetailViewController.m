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
#import "GroupDetailViewController.h"
#import "Comment.h"

@interface UserDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *relationButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property BOOL isFriend;
@property BOOL isPending;
@property BOOL isRequesting;
@property NSArray *arrayOfComment;
@property NSArray *arrayOfGroup;
@property NSArray *arrayOfFriend;
@property NSArray *listArray;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation UserDetailViewController

//MARK: view controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                green:(243.0/255.0)
                                                 blue:(243.0/255.0)
                                                alpha:1.0f];
    self.collectionView.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                          green:(243.0/255.0)
                                                           blue:(243.0/255.0)
                                                          alpha:1.0f];
    [self.commentButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.commentButton.layer setBorderWidth:1.0f];
    [self.commentButton.layer setCornerRadius:4.0f];
    [self.messageButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.messageButton.layer setBorderWidth:1.0f];
    [self.messageButton.layer setCornerRadius:4.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)refreshNumberOfPageControl
{
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        if (self.listArray.count == 0)
        {
            [self.pageControl setHidden:YES];
        }
        else if (0 < self.listArray.count && self.listArray.count < 3)
        {
            [self.pageControl setHidden:NO];
            self.pageControl.numberOfPages = self.listArray.count;
        }
        else
        {
            [self.pageControl setHidden:NO];
            self.pageControl.numberOfPages = 3;
        }
    }
    else
    {
        if (self.listArray.count == 0)
        {
            [self.pageControl setHidden:YES];
        }
        else if (0 < self.listArray.count && self.listArray.count <= 2)
        {
            [self.pageControl setHidden:NO];
            self.pageControl.numberOfPages = 1;
        }
        else if (2 < self.listArray.count && self.listArray.count <= 4)
        {
            [self.pageControl setHidden:NO];
            self.pageControl.numberOfPages = 2;
        }
        else
        {
            [self.pageControl setHidden:NO];
            self.pageControl.numberOfPages = 3;
        }
    }
    [self refreshCurrentPageControl];
}

- (void)refreshCurrentPageControl
{
    NSArray *array = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *index = array.firstObject;
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        if (index.item == 0)
        {
            self.pageControl.currentPage = 0;
        }
        else if (index.item == self.listArray.count - 1)
        {
            self.pageControl.currentPage = 2;
        }
        else
        {
            self.pageControl.currentPage = 1;
        }
    }
    else
    {
        if (index.item == 0)
        {
            self.pageControl.currentPage = 0;
        }
        else if (index.item == self.listArray.count - 2 && self.pageControl.numberOfPages == 3)
        {
            self.pageControl.currentPage = 2;
        }
        else
        {
            self.pageControl.currentPage = 1;
        }
    }
}

- (void)refreshView
{
    [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
    self.nameLabel.text = self.profile.firstName;
    self.memoLabel.text = self.profile.memo;
    [Profile getProfileWithProfileId:self.profile.objectId withCompletion:^(Profile *profile, NSError *error) {
        if (!error)
        {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"canonicalFirstName" ascending:YES];
            profile.friends = [[profile.friends sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            self.arrayOfFriend = profile.friends;
            if (self.segmentedControl.selectedSegmentIndex == 0)
            {
                [self changeListOnSegmentControl:self.segmentedControl];
            }
            [self.segmentedControl setTitle:[NSString stringWithFormat:@"Friends (%lu)",(unsigned long)self.profile.friends.count] forSegmentAtIndex:0];
        }
        else
        {
            [self error:error];
        }
    }];

    [Comment getCurrentCommentsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.arrayOfComment = objects;
            if (self.segmentedControl.selectedSegmentIndex == 1)
            {
                [self changeListOnSegmentControl:self.segmentedControl];
            }
            [self.segmentedControl setTitle:[NSString stringWithFormat:@"Comments (%lu)",(unsigned long)self.arrayOfComment.count] forSegmentAtIndex:1];
        }
        else
        {
            [self error:error];
        }
    }];
    [Group getCurrentGroupsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.arrayOfGroup = objects;
             if (self.segmentedControl.selectedSegmentIndex == 2)
             {
                 [self changeListOnSegmentControl:self.segmentedControl];
             }
             if  (self.segmentedControl.numberOfSegments == 3)
             {
                 [self.segmentedControl setTitle:[NSString stringWithFormat:@"Groups (%lu)",(unsigned long)self.arrayOfGroup.count] forSegmentAtIndex:2];
             }
         }
         else
         {
             [self error:error];
         }
     }];
    [self checkRelationStatus];
    [self switchButtonTitleBasedOnRelationStatus];
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
    if ([self.profile.objectId isEqual: self.currentProfile.objectId])
    {
        self.relationButton.title = @"";
        [self.commentButton setHidden:YES];
        [self.messageButton setHidden:YES];
    }
    else
    {
        [self.commentButton setHidden:NO];
        [self.messageButton setHidden:NO];
        if (self.isFriend)
        {
            if  (self.segmentedControl.numberOfSegments < 3)
            {
                [self.segmentedControl insertSegmentWithTitle:@"Groups" atIndex:2 animated:YES];
            }
            self.relationButton.title = @"Remove";
        }
        else
        {
            if  (self.segmentedControl.numberOfSegments == 3)
            {
                [self.segmentedControl removeSegmentAtIndex:2 animated:YES];
            }
            if (self.isPending == YES && self.isRequesting == NO)
            {
                self.relationButton.title = @"Accept";
            }
            else if (self.isPending == NO && self.isRequesting == YES)
            {
                self.relationButton.title = @"Pending";
            }
            else
            {
                self.relationButton.title = @"Invite";
            }
        }
    }
}

//MARK: custom button action
- (IBAction)changeRelationshipOnButtonPressed:(UIBarButtonItem *)sender{

    PFObject *currentUserProfile = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                objectId:self.currentProfile.objectId];
    PFObject *userProfile = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                objectId:self.profile.objectId];
    if ([self.relationButton.title isEqual:@"Remove"])
    {
        self.currentProfile.friends = [self removeObjectId:self.profile.objectId inArray:self.currentProfile.friends];
        self.profile.friends = [self removeObjectId:self.currentProfile.objectId inArray:self.profile.friends];
    }
    else if ([self.relationButton.title isEqual:@"Invite"])
    {
        self.profile.pendingFriends = [self addObjectId:currentUserProfile inArray:self.profile.pendingFriends];
    }
    else if ([self.relationButton.title isEqual:@"Accept"])
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
                                                     if (self.segmentedControl.selectedSegmentIndex == 1)
                                                     {
                                                         self.listArray = self.arrayOfComment;
                                                         [self.collectionView reloadData];
                                                         [self refreshNumberOfPageControl];
                                                     }
                                                     [self.segmentedControl setTitle:[NSString stringWithFormat:@"Comments (%lu)",(unsigned long)self.arrayOfComment.count] forSegmentAtIndex:1];
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

- (IBAction)segueToChatOnButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"chatSegue" sender:self.profile];
}

- (IBAction)changeListOnSegmentControl:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0 && self.arrayOfFriend)
    {
        self.listArray = self.arrayOfFriend;
        [self refreshNumberOfPageControl];
        [self.collectionView reloadData];
    }
    else if (sender.selectedSegmentIndex == 1 && self.arrayOfComment)
    {
        self.listArray = self.arrayOfComment;
        if (self.listArray.count > 1)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:YES];
        }
        [self.collectionView reloadData];
        [self refreshNumberOfPageControl];
    }
    else if (sender.selectedSegmentIndex == 2 && self.arrayOfGroup)
    {
        self.listArray = self.arrayOfGroup;
        [self refreshNumberOfPageControl];
        [self.collectionView reloadData];
    }

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
    return self.listArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [CustomCollectionViewCell new];
    if (self.segmentedControl.selectedSegmentIndex == 0 && self.arrayOfFriend)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"listCell" forIndexPath:indexPath];
        Profile *profile = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:profile.avatarData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = profile.firstName;
        cell.memoLabel.text = profile.memo;
        cell.numberLabel.text = @"";
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1 && self.arrayOfComment)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        Comment *comment = self.listArray[indexPath.item];
        cell.textView.text = comment.text;
        [self setImageView:cell.backgroundImageView withData:nil withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        [self setImageView:cell.imageView withData:comment.sender.avatarData withLayerRadius:cell.imageView.frame.size.width/2 withBorderColor:[UIColor whiteColor].CGColor];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *stringOfDate = [dateFormatter stringFromDate:comment.createdAt];
        cell.nameLabel.text = [NSString stringWithFormat:@"by %@ %@", comment.sender.firstName, stringOfDate];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 2 && self.arrayOfGroup)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"listCell" forIndexPath:indexPath];
        Group *group = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:group.imageData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = group.name;
        cell.memoLabel.text = group.destination;
        cell.numberLabel.text = [NSString stringWithFormat:@"%lu ☺︎",(unsigned long)group.profiles.count];
    }
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshCurrentPageControl];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 2 && self.arrayOfGroup)
    {
        Group *group = self.listArray[indexPath.item];
        [self performSegueWithIdentifier:@"groupSegue" sender:group];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1 && self.arrayOfComment)
    {
        Comment *comment = self.listArray[indexPath.item];
        self.profile = comment.sender;
        [self refreshView];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 0 && self.arrayOfFriend)
    {
        Profile *profile = self.listArray[indexPath.item];
        self.profile = profile;
        [self refreshView];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        return CGSizeMake(self.collectionView.frame.size.width - 20.0f, self.collectionView.frame.size.width*0.5 + 10.0f);
    }
    else
    {
        return CGSizeMake(self.collectionView.frame.size.width*0.5 - 20.0f, self.collectionView.frame.size.width*0.5 + 10.0f);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"chatSegue"])
    {
        ChatViewController *cvc = segue.destinationViewController;
        cvc.passedRecipient = sender;
    }
    else if ([segue.identifier isEqual:@"groupSegue"])
    {
        GroupDetailViewController *gdvc = segue.destinationViewController;
        gdvc.group = sender;
        gdvc.currentProfile = self.currentProfile;
    }
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
