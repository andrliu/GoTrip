//
//  GroupEditViewController.m
//  GoTrip
//
//  Created by Alex on 12/3/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupEditViewController.h"
#import "Group.h"

@interface GroupEditViewController ()

@end

@implementation GroupEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancellButtonPressed:(UIBarButtonItem *)sender
{
//   [self dismissViewControllerAnimated:NO completion:^{
////
//   }];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.group.objectId)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
