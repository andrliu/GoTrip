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
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *memoButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property Profile *profile;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error)
        {
            self.profile = profile;
            self.imageView.image = [UIImage imageWithData:self.profile.avatarData];
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
            self.locationLabel.text = self.profile.locationName;
            self.memoLabel.text = self.profile.memo;
        }
        else
        {
            [self error:error];
        }
    }];
}
- (IBAction)editProfileOnButtonPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)changeImageOnButtonPressed:(UIButton *)sender
{

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
