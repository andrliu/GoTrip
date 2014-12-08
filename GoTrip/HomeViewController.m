//
//  ViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "GroupDetailViewController.h"
@import Parse;
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Profile.h"
#import "Group.h"
#import "User.h"
#import "CustomTableViewCell.h"

#import "SINavigationMenuView.h"

@interface HomeViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SINavigationMenuDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *tableViewArray;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedComtrol;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addGroupButton;
@property Profile *currentProfile;
@property NSIndexPath *selectedIndexPath;

@end

@implementation HomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    //quick check for the profile for access privileges
//    [Profile checkForProfile:^(Profile *profile, NSError *error)
//    {
//        if (error)
//        {
//            NSLog(@"no profile found for the user");
//        }
//        else
//        {
//            self.currentProfile = profile;
//        }
//    }];

    self.tableViewArray = [NSMutableArray array];

    if (self.navigationItem)
    {
        CGRect frame = CGRectMake(-20.0, 0.0, 40.0, self.navigationController.navigationBar.bounds.size.height);
        SINavigationMenuView *menu = [[SINavigationMenuView alloc] initWithFrame:frame title:@""];
        //Set in which view we will display a menu
        [menu displayMenuInView:self.view];
        //Create array of items
        menu.items = @[@"Group Name", @"Destination", @"Departure Date"];
        menu.delegate = self;
        UIBarButtonItem *leftLabelBarButton = [[UIBarButtonItem alloc] initWithCustomView:menu];
        self.navigationItem.leftBarButtonItem = leftLabelBarButton;
    }


//    [self refreshDisplay:nil];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshDisplay:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(247.0/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0f];
//    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:(100.0/255.0) green:(100.0/255.0) blue:(100.0/255.0) alpha:1.0f];
    self.tableView.tableFooterView = [[UIView alloc] init] ;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([PFUser currentUser])
    {
        [self checkUserProfileAccountExisted];
        [self updateInstallationWith:[PFUser currentUser]];
    }

    if (self.selectedIndexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        self.selectedIndexPath = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![PFUser currentUser])
    {
        [self presentLoginView];
    }
}

//- (void)checkCurrentUser
//{
//    if (![PFUser currentUser])
//    {
//        [self presentLoginView];
//    }
//    else
//    {
//        [self checkUserProfileAccountExisted];
//        [self updateInstallationWith:[PFUser currentUser]];
//    }
//}

- (void)updateInstallationWith:(PFUser *)user
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = user;
    [installation saveInBackground];
}

- (void)checkUserProfileAccountExisted
{
    [Profile checkForProfile:^(Profile *profile, NSError *error)
//[Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error || error.code == kPFErrorObjectNotFound)
        {
            if (profile)
            {
                self.currentProfile = profile;
                NSLog(@"user has profile existed");
            }
            else
            {
                [self loadFacebookData];
                NSLog(@"no profile found for the user");
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

- (void)logOutAction
{
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    [self presentLoginView];
}

//MARK: PFLogInViewController delegate
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES;
    }
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO;
}

- (void)logInViewController:(LoginViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:0];
    self.segmentedComtrol.selectedSegmentIndex = 0;
    [self segmentedControlValueChanged:self.segmentedComtrol];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [self error:error];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:0];
    self.segmentedComtrol.selectedSegmentIndex = 0;
    [self segmentedControlValueChanged:self.segmentedComtrol];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)presentLoginView
{
    LoginViewController *logInViewController = [[LoginViewController alloc]init];
    [logInViewController setDelegate:self];
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsFacebook | PFLogInFieldsDismissButton;
    SignupViewController *signUpViewController = [[SignupViewController alloc]init];
    [signUpViewController setDelegate:self];
    signUpViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton |PFSignUpFieldsDismissButton;
    [logInViewController setSignUpController:signUpViewController];
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

//MARK: PFSignUpViewController delegate
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        {
            informationComplete = NO;
            break;
        }
    }
    if (!informationComplete)
    {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    Profile *profile = [Profile object];
    profile.user = (User *)user;
    profile.firstName = profile.user.username;
    profile.lastName = @"";
    profile.canonicalFirstName = [profile.user.username lowercaseString];
    profile.canonicalLastName = @"";
    profile.memo = @"Newbie";
    profile.friends = @[];
    profile.pendingFriends = @[];
    profile.isMessaging = @[];
    profile.isGroupMessaging = @[];
    UIImage *image = [UIImage imageNamed:@"avatar"];
    profile.avatarData = UIImageJPEGRepresentation(image, 0.1);
    [profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
            self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:0];
            self.segmentedComtrol.selectedSegmentIndex = 0;
            [self segmentedControlValueChanged:self.segmentedComtrol];
            [self.navigationController popViewControllerAnimated:NO];
        }
        else
        {
            [self error:error];
        }
    }];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    [self error:error];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: tableView delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = self.view.frame.size.width/2.5;
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];

    Group *group = self.tableViewArray[indexPath.row];
//    cell.textLabel.text = group.name;
//    cell.backgroundImageView.image = [UIImage imageNamed:@"hawaii"];
    //TODO: change to group.imageData
    cell.backgroundImageView.image = [UIImage imageNamed:@"noimage"];

    if ([[group allKeys] containsObject:@"imageData"])
    {
        cell.backgroundImageView.image = [UIImage imageWithData:group.imageData];
    }
    else
    {
        PFQuery *individualGroupQuery = [Group query];
        [individualGroupQuery getObjectInBackgroundWithId:group.objectId
                                                    block:^(PFObject *object, NSError *error)
         {
             if (error)
             {
                 [self error:error];
             }
             else
             {
                 self.tableViewArray[indexPath.row] = object;
                 cell.backgroundImageView.image = [UIImage imageWithData:[self.tableViewArray[indexPath.row] imageData]];
             }
         }];
    }
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

    NSString *countText;
    if (group.profiles.count > 0)
    {
        countText = [NSString stringWithFormat:@"%lu ☺︎",(unsigned long)group.profiles.count];
    }
    else
    {
        countText = @"☺︎";
    }
    cell.goingNumberLabel.text = countText;
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ([[self.tableViewArray[indexPath.row] allKeys] containsObject:@"imageData"])
     {
        Group *selectedGroup = self.tableViewArray[indexPath.row];
        [self performSegueWithIdentifier:@"groupDetailSegue" sender:selectedGroup];
         self.selectedIndexPath = indexPath;
     }
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sControl
{
    if (sControl.selectedSegmentIndex==1)
    {
        if (![PFUser currentUser])
        {
            [self presentLoginView];
        }
        [self queryForAllGroups:YES];
    }
    else
    {
        [self queryForFeaturedGroups:NO];
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

//creates a new group
- (IBAction)onBarButtonPressed:(UIBarButtonItem *)sender
{
    //TODO: implement a new group creation
    Group *newGroup = [Group object];
    newGroup.creator = self.currentProfile;
    Profile *profile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:self.currentProfile.objectId];
    newGroup.profiles = @[profile];
    [self performSegueWithIdentifier:@"groupDetailSegue" sender:newGroup];

}

-(void)queryForFeaturedGroups:(BOOL)animated //orderBy:(NSString *)attribute
{
    PFQuery *groupListQuery = [Group query];
    [groupListQuery whereKey:@"isFeatured" equalTo:[NSNumber numberWithBool:YES]];
    [groupListQuery orderByAscending:@"startDate"];
//    [groupListQuery orderByAscending:attribute];
    [groupListQuery selectKeys:@[@"name", @"destination", @"startDate", @"endDate", @"profiles", @"creator"]]; //inlcudes specific fields, need to requery later
    [groupListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             [self error:error];
         }
         else
         {
             self.tableViewArray = [objects mutableCopy];

             switch ([[NSNumber numberWithBool:animated]intValue])
             {
                 case 0:
                     [self.tableView reloadData];
                     break;
                 case 1:
                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                     break;

                 default:
                     break;
             }

         }
//         [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
     }];
    self.addGroupButton.enabled = NO;
    self.addGroupButton.tintColor = [UIColor clearColor];

}

-(void)queryForAllGroups:(BOOL)animated
{
    PFQuery *groupListQuery = [Group query];
    [groupListQuery orderByAscending:@"startDate"];
    [groupListQuery selectKeys:@[@"name", @"destination", @"startDate", @"endDate", @"profiles", @"creator"]]; //inlcudes specific fields, need to requery later
    [groupListQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             [self error:error];
         }
         else
         {
             self.tableViewArray = [objects mutableCopy];
             switch ([[NSNumber numberWithBool:animated]intValue])
             {
                 case 0:
                     [self.tableView reloadData];
                     break;
                 case 1:
                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                     break;

                 default:
                     break;
             }
         }
//         [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

     }];
    self.addGroupButton.enabled = YES;
    self.addGroupButton.tintColor = nil;
}

//MARK: helper method converts type File to bytes
-(void)fileToBytes
{
    for (Group *group in self.tableViewArray)
    {
//        PFQuery *query = [Group query];
//        [query whereKey:@"objectId" equalTo:group.objectId];

        PFFile *imageFile = group.imageFile;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (error)
         {
             [self error:error];
         }
         else
         {
             group.imageData = data;
             [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                    if (error)
                    {
                        [self error:error];
                    }
                     else
                     {
                         NSLog(@"file is on the server");
                     }

            }];
//             cell.customImageView.image = [UIImage imageWithData:data];
//             cell.backgroundColor = [UIColor blackColor];

         }
         
     }];
    }
}

//refresh tableview on down slode
-(void)refreshDisplay:(UIRefreshControl *)refreshControl
{

    if (self.segmentedComtrol.selectedSegmentIndex == 1)
    {
        [self queryForAllGroups:YES];
    }
    else
    {
        [self queryForFeaturedGroups:NO];
    }
    [refreshControl endRefreshing];
//    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
//    [query orderByAscending:@"name"]; //sort query
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error)
//         {
//         }
//         else
//         {
//             self.people = objects;
//             [self.tableView reloadData];
//         }
//
//         [refreshControl endRefreshing];
//         
//     }];

    
}

//navigation delegate method
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    if (self.segmentedComtrol.selectedSegmentIndex == 1)
    {
        switch (index)
        {
            case 0:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            case 1:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"destination" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            case 2:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        switch (index)
        {
            case 0:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            case 1:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"destination" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            case 2:
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
                self.tableViewArray = [[self.tableViewArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                break;
            }
            default:
                break;
        }
    }

    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    // same thing, but puts under the nav bar
    //    [self.tableView setContentOffset:CGPointZero animated:YES];
    
    
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
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//    Group *group = self.tableViewArray[indexPath.row];
        detailVC.indexPath = self.selectedIndexPath;
        detailVC.group = sender;
        detailVC.currentProfile = self.currentProfile;
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
   //groupEditViewController jumps here is the group has been deleted
    switch (self.segmentedComtrol.selectedSegmentIndex)
    {
        case 0:
            [self queryForFeaturedGroups:NO];
            break;
        case 1:
            [self queryForAllGroups:NO];
            break;
        default:
            break;
    }
//    self.segmentedComtrol.selectedSegmentIndex = 1;
//    [self queryForAllGroups:NO];
}

@end
