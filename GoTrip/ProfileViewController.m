//
//  ProfileViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserDetailViewController.h"
#import "GroupDetailViewController.h"
#import "ActivityViewController.h"
#import "CustomCollectionViewCell.h"
#import "Group.h"
#import "Profile.h"
#import "User.h"

@interface ProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property Profile *profile;
@property BOOL isImagePickerCalled;
@property NSArray *groupListArray;
@property NSArray *friendListArray;
@property NSArray *pendingFriendListArray;
@property NSArray *listArray;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property BOOL isLoadingGroups;
@property BOOL isLoadingFriends;

@end

@implementation ProfileViewController

//MARK: view controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                green:(243.0/255.0)
                                                 blue:(243.0/255.0)
                                                alpha:1.0f];
    self.collectionView.backgroundColor = [UIColor colorWithRed:(243.0/255.0)
                                                          green:(243.0/255.0)
                                                           blue:(243.0/255.0)
                                                          alpha:1.0f];
    [self.mapButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.mapButton.layer setBorderWidth:2.0f];
    [self.mapButton.layer setCornerRadius:5.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isImagePickerCalled)
    {
        [self editMode:NO];
        self.editButton.title = @"Edit";
        self.cancelButton.title = @"Logout";
        [self refreshPersonalProfile];
    }
    else
    {
        self.isImagePickerCalled = NO;
    }
}

//MARK: user logout
- (IBAction)logOutOnButtonPressed:(UIBarButtonItem *)sender
{
    if ([sender.title isEqual: @"Logout"])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation removeObjectForKey:@"user"];
        [installation saveInBackground];
        [PFUser logOut];
    }
    else
    {
        [self editMode:NO];
        sender.title = @"Logout";
        self.editButton.title = @"Edit";
        [self refreshPersonalProfile];
        [self.view endEditing:YES];
    }
}

//MARK: custom refresh method
- (void)refreshNumberOfPageControl
{
    if (self.listArray.count <= 2)
    {
        [self.pageControl setHidden:YES];
    }
    else if (2 < self.listArray.count && self.listArray.count <= 4)
    {
        [self.pageControl setHidden:NO];
        self.pageControl.numberOfPages = 2;
    }
    else
    {
        [self.pageControl setHidden:NO];
        self.pageControl.numberOfPages = 3;
    }
    [self refreshCurrentPageControl];
}

- (void)refreshCurrentPageControl
{
    NSArray *array = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *index = array.firstObject;
    if (array.count == 2)
    {
        NSIndexPath *firstIndex = array.firstObject;
        NSIndexPath *secondIndex = array[1];
        if (firstIndex > secondIndex)
        {
            index = secondIndex;
        }
    }
    if (index.item == 0)
    {
        self.pageControl.currentPage = 0;
    }
    else if (index.item == self.listArray.count - 2 && self.pageControl.numberOfPages == 3)
    {
        self.pageControl.currentPage = 2;
    }
    else
    {
        self.pageControl.currentPage = 1;
    }
}

- (void)refreshPersonalProfile
{
    self.isLoadingFriends = YES;
    self.isLoadingGroups = YES;
    [Profile checkForProfile:^(Profile *profile, NSError *error)
    {
         if (!error)
         {
             self.profile = profile;
             [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
             self.firstNameLabel.text = self.profile.firstName;
             self.lastNameLabel.text = self.profile.lastName;
             self.memoLabel.text = self.profile.memo;
             if ([self.profile.locationName isEqual:@""] || !self.profile.locationName)
             {
                self.locationLabel.text = @"Location";
             }
             else
             {
                 self.locationLabel.text = self.profile.locationName;
             }
             [Group getCurrentGroupsWithCurrentProfile:self.profile withCompletion:^(NSArray *objects, NSError *error)
              {
                  if (!error)
                  {
                    self.isLoadingGroups = NO;
                      self.groupListArray = objects;
                      if (self.segmentedControl.selectedSegmentIndex == 2)
                      {
                          [self segmentedControl:self.segmentedControl];
                      }
                      [self.segmentedControl setTitle:[NSString stringWithFormat:@"Groups (%lu)",(unsigned long)self.groupListArray.count] forSegmentAtIndex:2];
                  }
                  else
                  {
                      [self error:error];
                  }
              }];
         }
         else
         {
             [self error:error];
         }
    }];
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error)
    {
        if (!error)
        {
            self.isLoadingFriends = NO;
            self.profile = profile;
            self.friendListArray = self.profile.friends;
            self.pendingFriendListArray = self.profile.pendingFriends;
            if (self.segmentedControl.selectedSegmentIndex == 0)
            {
                [self segmentedControl:self.segmentedControl];
            }
            else if (self.segmentedControl.selectedSegmentIndex == 1)
            {
                [self segmentedControl:self.segmentedControl];
            }
            [self.segmentedControl setTitle:[NSString stringWithFormat:@"Friends (%lu)",(unsigned long)self.profile.friends.count] forSegmentAtIndex:0];
            [self.segmentedControl setTitle:[NSString stringWithFormat:@"Pendings (%lu)",(unsigned long)self.profile.pendingFriends.count] forSegmentAtIndex:1];

        }
        else
        {
            [self error:error];
        }

    }];
}

//MARK: dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//MARK: custom IBOutlet hidden method
- (void)editMode:(BOOL)yes
{
    [self.firstNameLabel setHidden:yes];
    [self.lastNameLabel setHidden:yes];
    [self.memoLabel setHidden:yes];
    [self.locationLabel setHidden:yes];
    [self.segmentedControl setHidden:yes];
    [self.mapButton setHidden:yes];
    [self.collectionView setHidden:yes];
    [self.firstNameTextField setHidden:!yes];
    [self.lastNameTextField setHidden:!yes];
    [self.memoTextField setHidden:!yes];
    [self.locationTextField setHidden:!yes];
    [self.imageButton setHidden:!yes];
}

//MARK: custom bar button action
- (IBAction)editProfileOnButtonPressed:(UIBarButtonItem *)sender
{
    if ([sender.title isEqual: @"Edit"] && self.profile)
    {
        self.firstNameTextField.text = self.profile.firstName;
        self.lastNameTextField.text = self.profile.lastName;
        self.memoTextField.text = self.profile.memo;
        if ([self.profile.locationName isEqual:@""] || !self.profile.locationName)
        {
            self.locationTextField.text = @"";
        }
        else
        {
            self.locationTextField.text = self.profile.locationName;
        }
        [self editMode:YES];
        sender.title = @"Save";
        self.cancelButton.title = @"Cancel";
    }
    else if (self.profile)
    {
        self.profile.firstName = self.firstNameTextField.text;
        self.profile.canonicalFirstName = [self.firstNameTextField.text lowercaseString];
        self.profile.lastName = self.lastNameTextField.text;
        self.profile.canonicalLastName = [self.lastNameTextField.text lowercaseString];
        self.profile.memo = self.memoTextField.text;
        self.profile.locationName = self.locationTextField.text;
        if (![self.locationTextField.text isEqual:@""])
        {
            NSString *address = self.locationTextField.text;
            CLGeocoder *geocoder = [[CLGeocoder alloc]init];
            [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (!error)
                 {
                     for (CLPlacemark *placemark in placemarks)
                     {
                         CLLocationCoordinate2D center = placemark.location.coordinate;
                         PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:center.latitude longitude:center.longitude];
                         self.profile.currentLocation = geoPoint;
                         [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                          {
                              if (!error)
                              {
                                  [self editMode:NO];
                                  sender.title = @"Edit";
                                  self.cancelButton.title = @"Logout";
                                  [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
                                  self.firstNameLabel.text = self.profile.firstName;
                                  self.lastNameLabel.text = self.profile.lastName;
                                  self.memoLabel.text = self.profile.memo;
                                  if ([self.profile.locationName isEqual:@""] || !self.profile.locationName)
                                  {
                                      self.locationLabel.text = @"";
                                  }
                                  else
                                  {
                                      self.locationLabel.text = self.profile.locationName;
                                  }
                                  [self.view endEditing:YES];
                              }
                              else
                              {
                                  [self error:error];
                              }
                          }];
                     }
                 }
                 else
                 {
                     [self error:error];
                 }
             }];
        }
        else
        {
            [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (!error)
                {
                    [self editMode:NO];
                    sender.title = @"Edit";
                    self.cancelButton.title = @"Logout";
                    [self setImageView:self.imageView withData:self.profile.avatarData withLayerRadius:15.0f withBorderColor:[UIColor blackColor].CGColor];
                    self.firstNameLabel.text = self.profile.firstName;
                    self.lastNameLabel.text = self.profile.lastName;
                    self.memoLabel.text = self.profile.memo;
                    if ([self.profile.locationName isEqual:@""] || !self.profile.locationName)
                    {
                        self.locationLabel.text = @"";
                    }
                    else
                    {
                        self.locationLabel.text = self.profile.locationName;
                    }
                    [self.view endEditing:YES];
                }
                else
                {
                    [self error:error];
                }
            }];
        }
    }
}

//MARK: custom segment action
- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0 && !self.isLoadingFriends)
    {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"canonicalFirstName" ascending:YES];
        self.friendListArray = [[self.friendListArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        self.listArray = self.friendListArray;
        [self refreshNumberOfPageControl];
        [self.collectionView reloadData];
    }
    else if (sender.selectedSegmentIndex == 1 && !self.isLoadingFriends)
    {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"canonicalFirstName" ascending:YES];
        self.pendingFriendListArray = [[self.pendingFriendListArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        self.listArray = self.pendingFriendListArray;
        [self refreshNumberOfPageControl];
        [self.collectionView reloadData];
    }
    else if (!self.isLoadingGroups)
    {
        self.listArray = self.groupListArray;
        [self refreshNumberOfPageControl];
        [self.collectionView reloadData];
    }
}

//MARK: custom imageView method
- (void)setImageView:(UIImageView *)imageView withData:(NSData *)data withLayerRadius:(CGFloat)radius withBorderColor:(CGColorRef)color
{
    if (data)
    {
        imageView.image = [UIImage imageWithData:data];
    }
    [imageView.layer setCornerRadius:radius];
    [imageView setClipsToBounds:YES];
    [imageView.layer setBorderWidth:2.0f];
    [imageView.layer setBorderColor:color];
}

//MARK: collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.segmentedControl.selectedSegmentIndex == 2 && !self.isLoadingGroups)
    {
        Group *group = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:group.imageData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = group.name;
        cell.memoLabel.text = group.destination;
        cell.numberLabel.text = [NSString stringWithFormat:@"%lu ☺︎",(unsigned long)group.profiles.count];
    }
    else if (!self.isLoadingFriends)
    {
        Profile *profile = self.listArray[indexPath.item];
        [self setImageView:cell.imageView withData:profile.avatarData withLayerRadius:10.0f withBorderColor:[UIColor blackColor].CGColor];
        cell.nameLabel.text = profile.firstName;
        cell.memoLabel.text = profile.memo;
        cell.numberLabel.text = @"";
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width*0.5 - 20.0f, self.collectionView.frame.size.width*0.5 + 10.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10.0f, self.collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 2 && !self.isLoadingGroups)
    {
        Group *group = self.listArray[indexPath.item];
        [self performSegueWithIdentifier:@"groupSegue" sender:group];
    }
    else if (!self.isLoadingFriends)
    {
        Profile *profile = self.listArray[indexPath.item];
        [self performSegueWithIdentifier:@"friendSegue" sender:profile];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshCurrentPageControl];
}

- (IBAction)mapOnButtonPressed:(UIButton *)sender
{
    if (!self.isLoadingFriends)
    {
        [self performSegueWithIdentifier:@"mapSegue" sender:self];
    }
}

//MARK: segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"groupSegue"])
    {
        GroupDetailViewController *gdvc = segue.destinationViewController;
        gdvc.group = sender;
        gdvc.currentProfile = self.profile;
    }
    else if ([segue.identifier isEqual:@"friendSegue"])
    {
        UserDetailViewController *udvc = segue.destinationViewController;
        udvc.profile = sender;
        udvc.currentProfile = self.profile;
    }
    else
    {
        ActivityViewController *avc = segue.destinationViewController;
        avc.currentProfile = self.profile;
        avc.userProfiles = self.profile.friends;
    }
}

//MARK: triger UIImagePicker(PhotoLibrary) by button pressed
- (IBAction)changeImageOnButtonPressed:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    self.isImagePickerCalled = YES;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

//MARK: UIImagePicker delegate to store and SAVE profile.avatarData and display on imageview
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickerImage = info[UIImagePickerControllerEditedImage];
    self.profile.avatarData = UIImageJPEGRepresentation(pickerImage, 0.1);
    self.imageView.image = pickerImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
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
