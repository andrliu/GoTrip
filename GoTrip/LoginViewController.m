//
//  LoginViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/24/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.logInView.logo setFrame:CGRectMake(self.logInView.frame.size.width/2 - 75, self.logInView.frame.size.height/2 - 80, 150.0f, 55.0f)];
    [self.logInView.facebookButton setFrame:CGRectMake(self.logInView.frame.size.width/2 - 125, self.logInView.frame.size.height/2, 250.0f, 50.0f)];
}

@end
