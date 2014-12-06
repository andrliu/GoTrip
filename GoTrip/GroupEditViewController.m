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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//both Cancel and Save are tide to the unwindSegue and dismiss the view smart based on the group object
- (IBAction)onCancellButtonPressed:(UIBarButtonItem *)sender
{
//   [self dismissViewControllerAnimated:NO completion:^{
////
//   }];
}
- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
    if (!self.group.imageData)
    {
        [self defaultImagePicker];
    }

    if (!self.group.memo)
    {
        self.group.memo = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et auctor nulla. Pellentesque non odio vel nibh sagittis pulvinar. Proin sed dolor ut nisi scelerisque maximus. Cras gravida accumsan leo ut facilisis. Aenean rhoncus hendrerit orci, at fermentum ante venenatis et. Mauris vitae aliquam arcu, eget ultricies nisi. Praesent gravida dictum eros sed ultricies. Suspendisse dignissim vehicula purus, sollicitudin pretium ante lacinia non. Pellentesque blandit finibus ligula, eu viverra elit rhoncus sed. Ut mattis, felis ut lobortis luctus, neque augue aliquet mi, eget ullamcorper ex nisi a risus. Pellentesque a metus ac tellus tincidunt aliquam eu id velit. Phasellus rhoncus quis magna sed hendrerit. Donec urna justo, egestas id imperdiet sit amet, hendrerit a ligula. Fusce ultricies nibh a velit fringilla, at tempor nunc volutpat. Fusce laoreet tristique tellus, eget auctor metus.\n\nSuspendisse sit amet neque at leo ullamcorper elementum eu in metus. Proin at purus vel felis molestie tristique at eget augue. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aenean varius risus vel imperdiet interdum. Suspendisse nec diam nec dui aliquam convallis vel id ex. Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut imperdiet ante tellus, quis finibus diam posuere quis.";
    }

    if (!self.group.name)
    {
        NSString *name = [NSString stringWithFormat:@"New Group %@",[self randomStringWithLength:3]];
        self.group.name = name;
        self.group.canonicalName = [name lowercaseString];
    }

    if (!self.group.destination)
    {
        self.group.destination = @"undecided";
    }

    [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            [self errorAlertWindow:error.localizedDescription];
        }
    }];

    [self dismissViewControllerAnimated:YES completion:nil];

}


//picks random image from the list
-(void)defaultImagePicker
{
    int i = arc4random_uniform(5);
    NSString *imageName;
    switch (i)
    {
        case 0:
            imageName = @"maldives";
            break;
        case 1:
            imageName = @"camp";
            break;
        case 2:
            imageName = @"hawaii";
            break;
        case 3:
            imageName = @"lake";
            break;
        case 4:
            imageName = @"italy";
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    NSData *data = UIImageJPEGRepresentation(image, 0.5f);
    self.group.imageData = data;
}

-(NSString *)randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];

    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }

    return randomString;
}

- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender
{
    [self deleteGroupAlertWindow];
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
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:@"No"
                                                     style:UIAlertActionStyleCancel
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
