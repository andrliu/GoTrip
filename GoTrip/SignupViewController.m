//
//  SignupViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 12/3/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    self.signUpView.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                       green:(243.0/255.0)
                                                        blue:(243.0/255.0)
                                                       alpha:1.0f];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.signUpView.logo setFrame:CGRectMake(self.signUpView.frame.size.width/6,
                                              self.signUpView.frame.size.height/8,
                                              self.signUpView.frame.size.width*2/3,
                                              self.signUpView.frame.size.width*2/9)];
    [self.signUpView.usernameField setFrame:CGRectMake(-5.0f,
                                                       self.signUpView.frame.size.height*3/8 - 5.0f,
                                                       self.signUpView.frame.size.width + 10.0f,
                                                       self.signUpView.frame.size.height/12)];
    [self.signUpView.passwordField setFrame:CGRectMake(-5.0f,
                                                       self.signUpView.frame.size.height*11/24,
                                                       self.signUpView.frame.size.width + 10.0f,
                                                       self.signUpView.frame.size.height/12)];
    [self.signUpView.signUpButton setFrame:CGRectMake(-5.0f,
                                                      self.signUpView.frame.size.height*13/24 + 5.0f,
                                                      self.signUpView.frame.size.width + 10.0f,
                                                      self.signUpView.frame.size.height/12)];
}

@end
