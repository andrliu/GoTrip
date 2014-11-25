//
//  ProfileViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ProfileViewController.h"
#import "Profile.h"
#import "User.h"

@interface ProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthDayTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property Profile *profile;
@property BOOL isImagePickerCalled;

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
            self.imageView.image = [UIImage imageWithData:self.profile.avatarData];
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
            self.locationLabel.text = self.profile.locationName;
            self.memoLabel.text = self.profile.memo;
            self.genderLabel.text = self.profile.gender;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            self.birthDateLabel.text = [dateFormatter stringFromDate:self.profile.birthDate];
            self.isImagePickerCalled = NO;
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
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.locationTextField resignFirstResponder];
    [self.memoTextField resignFirstResponder];
    [self.genderTextField resignFirstResponder];
    [self.birthYearTextField resignFirstResponder];
    [self.birthMonthTextField resignFirstResponder];
    [self.birthDayTextField resignFirstResponder];
    return YES;
}

- (void)editMode:(BOOL)yes
{
    [self.nameLabel setHidden:yes];
    [self.locationLabel setHidden:yes];
    [self.memoLabel setHidden:yes];
    [self.genderLabel setHidden:yes];
    [self.birthDateLabel setHidden:yes];
    [self.firstNameTextField setHidden:!yes];
    [self.lastNameTextField setHidden:!yes];
    [self.locationTextField setHidden:!yes];
    [self.memoTextField setHidden:!yes];
    [self.genderTextField setHidden:!yes];
    [self.birthYearTextField setHidden:!yes];
    [self.birthMonthTextField setHidden:!yes];
    [self.birthDayTextField setHidden:!yes];
    [self.imageButton setHidden:!yes];
}

- (IBAction)editProfileOnButtonPressed:(UIBarButtonItem *)sender
{
    if ([sender.title isEqual: @"Edit"])
    {
        self.firstNameTextField.text = self.profile.firstName;
        self.lastNameTextField.text = self.profile.lastName;
        self.locationTextField.text = self.profile.locationName;
        self.memoTextField.text = self.profile.memo;
        self.genderTextField.text = self.profile.gender;
        [self editMode:YES];
        sender.title = @"Save";
    }
    else
    {
        self.profile.firstName = self.firstNameTextField.text;
        self.profile.canonicalFirstName = [self.firstNameTextField.text lowercaseString];
        self.profile.lastName = self.lastNameTextField.text;
        self.profile.canonicalLastName = [self.lastNameTextField.text lowercaseString];
        self.profile.locationName = self.locationTextField.text;
        self.profile.memo = self.memoTextField.text;
        self.profile.gender = self.genderTextField.text;
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
