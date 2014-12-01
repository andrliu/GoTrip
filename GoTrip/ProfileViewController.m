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
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *friendListButton;
@property (weak, nonatomic) IBOutlet UIButton *groupListButton;
//@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
//@property (weak, nonatomic) IBOutlet UILabel *birthDateLabel;
//@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
//@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
//@property (weak, nonatomic) IBOutlet UITextField *birthYearTextField;
//@property (weak, nonatomic) IBOutlet UITextField *birthMonthTextField;
//@property (weak, nonatomic) IBOutlet UITextField *birthDayTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property Profile *profile;
@property BOOL isImagePickerCalled;
@property NSArray *groupListArray;
@property NSArray *friendListArray;
@property NSArray *pastGroupListArray;
@property NSArray *pendingFriendListArray;
@property NSArray *listArray;
@property BOOL isGroup;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)refreshPersonalProfile
{
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error)
        {
            self.profile = profile;
            self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
            self.imageView.clipsToBounds = YES;
            self.imageView.layer.borderWidth = 2.0f;
            self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
            self.imageView.image = [UIImage imageWithData:self.profile.avatarData];
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
            self.memoLabel.text = self.profile.memo;
//            self.locationLabel.text = self.profile.locationName;
//            self.genderLabel.text = self.profile.gender;
//            self.birthDateLabel.text = [self stringFromDateFormat:@"MM/dd/yyyy"];
            self.isImagePickerCalled = NO;
            self.isGroup = NO;
            self.listArray = self.profile.friends;

            PFQuery *query = [Group query];
            [query includeKey:@"profiles"];
            [query whereKey:@"profiles" equalTo:self.profile];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
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

//- (NSString *)stringFromDateFormat:(NSString *)format
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:format];
//    NSString *string = [dateFormatter stringFromDate:self.profile.birthDate];
//    return string;
//}

//MARK: dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.memoTextField resignFirstResponder];
//    [self.locationTextField resignFirstResponder];
//    [self.genderTextField resignFirstResponder];
//    [self.birthYearTextField resignFirstResponder];
//    [self.birthMonthTextField resignFirstResponder];
//    [self.birthDayTextField resignFirstResponder];
    return YES;
}

- (void)editMode:(BOOL)yes
{
    [self.nameLabel setHidden:yes];
    [self.memoLabel setHidden:yes];
    [self.firstNameTextField setHidden:!yes];
    [self.lastNameTextField setHidden:!yes];
    [self.memoTextField setHidden:!yes];
//    [self.locationLabel setHidden:yes];
//    [self.genderLabel setHidden:yes];
//    [self.birthDateLabel setHidden:yes];
//    [self.locationTextField setHidden:!yes];
//    [self.genderTextField setHidden:!yes];
//    [self.birthYearTextField setHidden:!yes];
//    [self.birthMonthTextField setHidden:!yes];
//    [self.birthDayTextField setHidden:!yes];
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
//        self.locationTextField.text = self.profile.locationName;
//        self.genderTextField.text = self.profile.gender;
//        self.birthYearTextField.text = [self stringFromDateFormat:@"yyyy"];
//        self.birthMonthTextField.text = [self stringFromDateFormat:@"MM"];
//        self.birthDayTextField.text = [self stringFromDateFormat:@"dd"];
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
//        self.profile.locationName = self.locationTextField.text;
//        self.profile.gender = self.genderTextField.text;
//        NSString *stringOfDate = [NSString stringWithFormat:@"%@/%@/%@", self.birthMonthTextField.text,self.birthDayTextField.text,self.birthYearTextField.text];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//        self.profile.birthDate = [dateFormatter dateFromString:stringOfDate];
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

- (IBAction)logOutOnButtonPressed:(UIBarButtonItem *)sender
{
    self.isImagePickerCalled = NO;
    self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:0];
    [PFUser logOut];
}

//MARK: custom button action
- (IBAction)friendListOnButtonPressed:(UIButton *)sender
{
    self.listArray = self.profile.friends;
    self.isGroup = NO;
    [self.collectionView reloadData];
}

- (IBAction)pendingFriendListOnButtonPressed:(UIButton *)sender
{
    self.listArray = self.profile.pendingFriends;
    self.isGroup = NO;
    [self.collectionView reloadData];
}

- (IBAction)groupListOnButtonPressed:(UIButton *)sender
{
    self.listArray = self.groupListArray;
    self.isGroup = YES;
    [self.collectionView reloadData];
}

- (IBAction)pastGroupListOnButtonPressed:(id)sender
{
    self.listArray = self.pastGroupListArray;
    self.isGroup = YES;
    [self.collectionView reloadData];
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
        cell.imageView.image = [UIImage imageWithData:group.imageData];
        cell.nameLabel.text = group.name;
        cell.memoLabel.text = group.destination;
    }
    else
    {
        Profile *profile = self.listArray[indexPath.item];
        cell.imageView.image = [UIImage imageWithData:profile.avatarData];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];;
        cell.memoLabel.text = profile.memo;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width/2, self.collectionView.frame.size.height*0.8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width/4, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width/4, self.collectionView.frame.size.height);
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
