//
//  ViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
@import Parse;
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface HomeViewController () <PFLogInViewControllerDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser])
    {
        [self returnLoginView];
    }
}

- (void)loadFacebookData
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        // handle response
        if (!error)
        {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *firstName = userData[@"first_name"];
            NSString *lastName = userData[@"last_name"];
            NSString *canonicalFirstName = [userData[@"first_name"] lowercaseString];
            NSString *canonicalLastName = [userData[@"last_name"] lowercaseString];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            // Run network request asynchronously
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
            {
                if (connectionError == nil && data != nil)
                {

                }
                else
                {
                    [self error:connectionError];
                }
            }];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"])
        {
            // Since the request failed, we can check if it was due to an invalid session
            [self logOutAction];
        }
        else
        {
            [self error:error];
        }
    }];
}

//MARK: PFLogInViewController delegate
- (void)logInViewController:(LoginViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [self error:error];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logOutAction
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    [self returnLoginView];
}

- (void)returnLoginView
{
    LoginViewController *logInViewController = [[LoginViewController alloc]init];
    [logInViewController setDelegate:self];
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    logInViewController.fields = PFLogInFieldsFacebook;
    [self presentViewController:logInViewController animated:YES completion:NULL];
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
