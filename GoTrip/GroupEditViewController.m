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

- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender
{
    [self deleteGroupAlertWindow];
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

//deletes the group and jumps to the homeViewController
- (void)deleteGroupAlertWindow
{
    NSString *warningMessage = [NSString stringWithFormat:@"You are about to delete the group. \nDelete?"]; //add variable to the warning message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:warningMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Yes"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action)
                                                    {
                                                        [self.group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                                        {
                                                            if (error)
                                                            {
                                                                [self errorAlertWindow:error.localizedDescription];
                                                            }
                                                            else
                                                            {
                                                                [self performSegueWithIdentifier:@"goHomeSegue" sender:nil];
                                                            }
                                                        }];


                                                    }];
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:@"NO!"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:nil];
    [alert addAction:confirm];
    [alert addAction:cancell];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)errorAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"😭 OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
