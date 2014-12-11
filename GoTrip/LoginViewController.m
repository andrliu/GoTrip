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
    self.logInView.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                     green:(243.0/255.0)
                                                      blue:(243.0/255.0)
                                                     alpha:1.0f];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.logInView.logo setFrame:CGRectMake(self.logInView.frame.size.width/6,
                                             self.logInView.frame.size.height/8 + 20.0f,
                                             self.logInView.frame.size.width*2/3,
                                             self.logInView.frame.size.width*2/9)];
    [self.logInView.usernameField setFrame:CGRectMake(-5.0f,
                                                      self.logInView.frame.size.height*3/8 - 5.0f,
                                                      self.logInView.frame.size.width + 10.0f,
                                                      self.logInView.frame.size.height/12)];
    [self.logInView.passwordField setFrame:CGRectMake(-5.0f,
                                                      self.logInView.frame.size.height*11/24,
                                                      self.logInView.frame.size.width + 10.0f,
                                                      self.logInView.frame.size.height/12)];
    [self.logInView.logInButton setFrame:CGRectMake(-5.0f,
                                                    self.logInView.frame.size.height*13/24 + 5.0f,
                                                    self.logInView.frame.size.width + 10.0f,
                                                    self.logInView.frame.size.height/12)];
    [self.logInView.signUpButton setFrame:CGRectMake(-5.0f,
                                                     self.logInView.frame.size.height*15/24 + 10.0f,
                                                     self.logInView.frame.size.width + 10.0f,
                                                     self.logInView.frame.size.height/12)];
    [self.logInView.facebookButton setFrame:CGRectMake(-5.0f,
                                                       self.logInView.frame.size.height*5/6,
                                                       self.logInView.frame.size.width + 10.0f,
                                                       self.logInView.frame.size.height/12)];
}

@end
