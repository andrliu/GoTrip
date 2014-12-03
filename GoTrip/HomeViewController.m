//
//  ViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "GroupDetailViewController.h"
@import Parse;
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Profile.h"
#import "Group.h"
#import "User.h"
#import "CustomTableViewCell.h"

@interface HomeViewController () <PFLogInViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *tableViewArray;


@end

@implementation HomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

//TODO: remove example group from here
//    PFQuery *query = [Group query];
//    [query getObjectInBackgroundWithId:@"Zs30vE5wdx" block:^(PFObject *object, NSError *error)
//    {
//        Group *testGroup = (Group *)object;
//
//        self.tableViewArray = @[testGroup];
//        [self.tableView reloadData];
//        
//    }];
    PFQuery *groupListQuery = [Group query];
    [groupListQuery whereKey:@"isFeatured" equalTo:[NSNumber numberWithBool:YES]];
    [groupListQuery orderByAscending:@"startDate"];
    [groupListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (error)
        {
            [self error:error];
        }
        else
        {
            self.tableViewArray = objects;
            [self.tableView reloadData];
        }
    }];

// to here
    self.tableView.tableFooterView = [[UIView alloc] init] ;
    self.navigationItem.title = @"Featured Groups";

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser])
    {
        [self presentLoginView];
    }
    else
    {
        [self checkUserProfileAccountExisted];
    }
}

- (void)checkUserProfileAccountExisted
{
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error || error.code == kPFErrorObjectNotFound)
        {
            if (profile)
            {
                //TODO: something after login
                NSLog(@"user has profile existed");
            }
            else
            {
                [self loadFacebookData];
            }
        }
        else
        {
            [self error:error];
        }
    }];
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
            Profile *profile = [Profile object];
            User *user = [User currentUser];
            profile.user = user;
            profile.facebookID = userData[@"id"];
            profile.firstName = userData[@"first_name"];
            profile.lastName = userData[@"last_name"];
            profile.canonicalFirstName = [userData[@"first_name"] lowercaseString];
            profile.canonicalLastName = [userData[@"last_name"] lowercaseString];
            profile.locationName = userData[@"locale"];
            profile.gender = userData[@"gender"];
            profile.memo = @"Newbie";
            // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            // Run network request asynchronously
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
            {
                if (connectionError == nil && data != nil)
                {
                    profile.avatarData = data;
                    [profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                    {
                        if (!error)
                        {
                            //TODO: something after login
                            NSLog(@"finished saving data");
                        }
                        else
                        {
                            [self error:error];
                        }
                    }];
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
    [self presentLoginView];
}

- (void)presentLoginView
{
    LoginViewController *logInViewController = [[LoginViewController alloc]init];
    [logInViewController setDelegate:self];
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    logInViewController.fields = PFLogInFieldsFacebook;
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

//MARK: tableView delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = self.view.frame.size.width/2.5;
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: row count
    return self.tableViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];

    Group *group = self.tableViewArray[indexPath.row];
//    cell.textLabel.text = group.name;
    //TODO: change to group.imageData
    cell.backgroundImageView.image = [UIImage imageNamed:@"hawaii"];
    [cell.backgroundImageView setClipsToBounds:YES];
    cell.nameLabel.text = group.name;
    cell.destinationLabel.text = group.destination;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    NSString *startDateString = [dateFormat stringFromDate:group.startDate];
    cell.startLabel.text = startDateString;
    NSString *endDateString = [dateFormat stringFromDate:group.endDate];
    cell.endLabel.text = endDateString;

    cell.goingNumberLabel.text = [NSString stringWithFormat:@"☺︎ %lu",group.profiles.count];


    return cell;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GroupDetailViewController *detailVC = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Group *group = self.tableViewArray[indexPath.row];
    detailVC.group = group;
}

@end
