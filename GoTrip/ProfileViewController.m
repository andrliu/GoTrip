//
//  ProfileViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserDetailViewController.h"
#import "GroupDetailViewController.h"
#import "CustomCollectionViewCell.h"
#import "Group.h"
#import "Profile.h"
#import "User.h"

@interface ProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property Profile *profile;
@property BOOL isImagePickerCalled;
@property NSArray *groupListArray;
@property NSArray *friendListArray;
@property NSArray *pendingFriendListArray;
@property NSArray *listArray;
@property BOOL isGroup;

@end

@implementation ProfileViewController

//MARK: view controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];
    self.collectionView.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isImagePickerCalled)
    {
        [self editMode:NO];
        self.navigationItem.rightBarButtonItem.title = @"Edit";
        [self refreshPersonalProfile];
    }
    else
    {
        self.isImagePickerCalled = NO;
    }
}

//MARK: user logout
- (IBAction)logOutOnButtonPressed:(UIBarButtonItem *)sender
{
    self.listArray = @[];
    UIImage *image = [UIImage imageNamed:@"avatar"];
    NSData *data = UIImageJPEGRepresentation(image, 0.1);
    [self setImageView:self.imageView withData:data withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
    self.firstNameLabel.text = @"First";
    self.lastNameLabel.text = @"Last";
    self.memoLabel.text = @"Memo";
    self.isImagePickerCalled = NO;
    self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:0];
    [PFUser logOut];
}

//MARK: custom refresh method
- (void)refreshPersonalProfile
{
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error)
        {
            self.profile = profile;
            [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
            self.firstNameLabel.text = self.profile.firstName;
            self.lastNameLabel.text = self.profile.lastName;
            self.memoLabel.text = self.profile.memo;
            self.isImagePickerCalled = NO;
            self.isGroup = NO;
            self.listArray = self.profile.friends;
            self.segmentedControl.selectedSegmentIndex = 0;
            [Group getCurrentGroupsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error)
            {
                if (!error)
                {
                    self.groupListArray = objects;
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
}

//MARK: dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//MARK: custom IBOutlet hidden method
- (void)editMode:(BOOL)yes
{
    [self.firstNameLabel setHidden:yes];
    [self.lastNameLabel setHidden:yes];
    [self.memoLabel setHidden:yes];
    [self.firstNameTextField setHidden:!yes];
    [self.lastNameTextField setHidden:!yes];
    [self.memoTextField setHidden:!yes];
    [self.imageButton setHidden:!yes];
}

//MARK: custom bar button action
- (IBAction)editProfileOnButtonPressed:(UIBarButtonItem *)sender
{
    if ([sender.title isEqual: @"Edit"])
    {
        self.firstNameTextField.text = self.profile.firstName;
        self.lastNameTextField.text = self.profile.lastName;
        self.memoTextField.text = self.profile.memo;
        [self editMode:YES];
        sender.title = @"Save";
    }
    else
    {
        self.profile.firstName = self.firstNameTextField.text;
        self.profile.canonicalFirstName = [self.firstNameTextField.text lowercaseString];
        self.profile.lastName = self.lastNameTextField.text;
        self.profile.canonicalLastName = [self.lastNameTextField.text lowercaseString];
        self.profile.memo = self.memoTextField.text;
        [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)
            {
                [self editMode:NO];
                sender.title = @"Edit";
                [self refreshPersonalProfile];
            }
            else
            {
                [self error:error];
            }
        }];
    }
}

//MARK: custom segment action
- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.listArray = self.profile.friends;
        self.isGroup = NO;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        self.listArray = self.profile.pendingFriends;
        self.isGroup = NO;
    }
    else
    {
        self.listArray = self.groupListArray;
        self.isGroup = YES;
    }
    [self.collectionView reloadData];
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
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.isGroup)
    {
        Group *group = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:group.imageData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ (%lu☺︎)",group.name,(unsigned long)group.profiles.count];
        cell.memoLabel.text = group.destination;
    }
    else
    {
        Profile *profile = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:profile.avatarData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = profile.firstName;
        cell.memoLabel.text = profile.memo;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width*0.4, self.collectionView.frame.size.width*0.4 + 30.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isGroup)
    {
        Group *group = self.listArray[indexPath.item];
        [self performSegueWithIdentifier:@"groupSegue" sender:group];
    }
    else
    {
        Profile *profile = self.listArray[indexPath.item];
        [self performSegueWithIdentifier:@"friendSegue" sender:profile];
    }
}

//MARK: segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"groupSegue"])
    {
        GroupDetailViewController *gdvc = segue.destinationViewController;
        gdvc.group = sender;
        gdvc.currentProfile = self.profile;
    }
    else
    {
        UserDetailViewController *udvc = segue.destinationViewController;
        udvc.profile = sender;
    }
}

//MARK: triger UIImagePicker(PhotoLibrary) by button pressed
- (IBAction)changeImageOnButtonPressed:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    self.isImagePickerCalled = YES;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

//MARK: UIImagePicker delegate to store and SAVE profile.avatarData and display on imageview
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickerImage = info[UIImagePickerControllerEditedImage];
    self.profile.avatarData = UIImageJPEGRepresentation(pickerImage, 0.1);
    self.imageView.image = pickerImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
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
