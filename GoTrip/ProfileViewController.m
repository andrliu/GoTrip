//
//  ProfileViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

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


@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)changeNameOnButtonPressed:(UIButton *)sender {
}
- (IBAction)changeLocationOnButtonPressed:(UIButton *)sender {
}
- (IBAction)changeMemoOnButtonPressed:(UIButton *)sender {
}
- (IBAction)changeImageOnButtonPressed:(UIButton *)sender {
}


@end
