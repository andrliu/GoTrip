//
//  GroupDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "Group.h"
#import "Profile.h"
#import "Photo.h"
#import "CustomTableViewCell.h"
#import "TextTableViewCell.h"
#import "ImageTableViewCell.h"
#import "ButtonTableViewCell.h"
#import "GroupCollectionViewCell.h"
#import "GroupEditViewController.h"
#import "UserDetailViewController.h"

@interface GroupDetailViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *collectionViewArray;
@property (strong, nonatomic) NSMutableArray *friendArray;
@property BOOL isInGroup;

//@property NSString *aString;

@end

@implementation GroupDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isInGroup = NO;

    [self checkForGroupAccess];

//    PFQuery *query = [Group query];
//    [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject *object, NSError *error)
//    {
//        if (error)
//        {
//            [self errorAlertWindow:error.localizedDescription];
//        }
//        else
//        {
//            Group *group = (Group *)object;
//            if (self.group.profiles.count != group.profiles.count)
//            {
//            self.group = (Group *)object;
//            [self checkForGroupAccess];
//            }
//        }
//    }];
    self.friendArray = [self.group.profiles mutableCopy];

//    PFQuery *profilesQuery = [Profile query];
//    for (int i= 0; i < self.friendArray.count; i++)
//    {
//        Profile *profile = self.friendArray[i];
//        [profilesQuery getObjectInBackgroundWithId:profile.objectId block:^(PFObject *object, NSError *error)
//            {
//                Profile *profileWithData = (Profile *)object;
//                [self.friendArray replaceObjectAtIndex:i withObject:profileWithData];
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
//            }];
//    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    PFQuery *query = [Group query];
    [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject *object, NSError *error)
     {
         if (error)
         {
             [self errorAlertWindow:error.localizedDescription];
         }
         else
         {
             Group *group = (Group *)object;
             if (self.group.profiles.count != group.profiles.count)
             {
                 self.group = (Group *)object;
                 [self checkForGroupAccess];
             }
         }
     }];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];


}

-(void)checkForGroupAccess
{
    //TODO: CHECK FOR THE GROUP != nil !!
    if ([self.group.creator.objectId isEqualToString:self.currentProfile.objectId])
    {
        self.isInGroup = YES;
        //add an Edit button is current profile is the owner
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = nil;
    }
    else
    {
        [self showJoinButtonIfNotInGroup];
    }

    if (self.group.objectId)
    {
        PFQuery *photoQuery = [Photo query];
        [photoQuery whereKey:@"group" equalTo:self.group];
        [photoQuery orderByDescending:@"createdAt"];
        [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error)
             {
                 [self errorAlertWindow:error.localizedDescription];
             }
             else
             {
                 self.collectionViewArray = objects;
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationLeft];
             }
         }];

        //TODO: clean that stuff. For testing only

        //    UIImage *image1 = [UIImage imageNamed:@"minsk"];
        //    UIImage *image2 = [UIImage imageNamed:@"portland"];
        //    UIImage *image3 = [UIImage imageNamed:@"sanfrancisco"];
        //    UIImage *image4 = [UIImage imageNamed:@"chicago"];
        //    self.collectionViewArray = @[image1,image2,image3,image4];


    }
    else
    {
        [self performSegueWithIdentifier:@"editSegue" sender:self.group];
    }

}

-(void)showJoinButtonIfNotInGroup
{
    NSInteger profileIndex = [self isProfileInGroup:self.group profile:self.currentProfile];
    if (profileIndex != -1)
    {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//        self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
        UIBarButtonItem *groupLeaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStylePlain target:self action:@selector(onGroupLeaveButtonPressed:)];

        self.navigationItem.rightBarButtonItem = groupLeaveButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor]; //nil;

        self.isInGroup = YES;
    }
    else
    {
        //            UIBarButtonItem *groupJoinButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:nil title  target:self action:@selector(testButton:)];
        //            groupJoinButton.style = UIBarButtonItemStylePlain;

        UIBarButtonItem *groupJoinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(onGroupJoinButtonPressed:)];

        self.navigationItem.rightBarButtonItem = groupJoinButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = nil;

        self.isInGroup = NO;

    }
    
}

-(NSInteger)isProfileInGroup:(Group *)group profile:(Profile *)profile
{

    NSInteger i=0;
    NSInteger objectIndex = -1;
    for (Profile *profileFromGroup in group.profiles)
    {
        if ([profileFromGroup.objectId isEqualToString:profile.objectId])
        {
            objectIndex = i;

            break;
        }
        else
        {
            if (i>group.profiles.count)
            {
                break;
            }
            else
            {
                i++;
            }
        }

    }
    return objectIndex;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theFloat = 0;


    CGFloat height = [self heightForString:self.group.memo];


    switch (indexPath.section)
    {
        case 0:
            theFloat = self.view.frame.size.width/2.5; //imageView
            break;
        case 1:
            theFloat = height*1.03 + 20; //textView
            break;
        case 2:
        {
            if (self.isInGroup)
            {
                theFloat =  192.0;  //userList
            }
            else
            {
                theFloat = 0;
            }
            break;
        }
        case 3:
            theFloat =  190.0;  //imageList
            break;
        case 4:
            theFloat =  40.0;
            break;

        default:
            theFloat =  0;
            break;
    }

//    NSLog(@"section: %li row: %li height: %f",(long)indexPath.section, (long)indexPath.row, theFloat);

    return theFloat;

}

- (CGFloat)heightForString:(NSString *)theString
{

    CGRect textViewSize = [theString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 16, CGFLOAT_MAX)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}
                                                     context:nil];

    return textViewSize.size.height;

    //    UILabel *label = [[UILabel alloc]init];
    //    label.numberOfLines = 0;
    //    label.text = theString;
    //    label.font = [UIFont systemFontOfSize:14];
    //    CGSize aSize = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 16, CGFLOAT_MAX)];
    //
    //    return aSize.height;

}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
//   [headerView setBackgroundColor:[UIColor grayColor]];
//    [headerView setBackgroundColor:[UIColor colorWithRed:(33.0/255.0) green:(33.0/255.0) blue:(33.0/255.0) alpha:1.0f]];
//    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    [headerView setBackgroundColor:[UIColor colorWithRed:(229.0/255.0) green:(229.0/255.0) blue:(229.0/255.0) alpha:1.0f]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.bounds.size.width - 10, 20)];

    switch (section)
    {
        case 0:
            label.text = self.group.destination;
            break;
        case 1:
            label.text = @"Description";
            break;
        case 2:
        {
            if (self.isInGroup)
            {
                label.text = @"Members";
            }
            else
            {
                headerView = nil;
            }
            break;
        }
        case 3:
            label.text = @"Available pictures";
            break;
        case 4:
            label.text = @"";
            break;

        default:
            label.text = @"";
            break;
    }

//    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    label.textColor = [UIColor colorWithRed:(102.0/255.0) green:(102.0/255.0) blue:(102.0/255.0) alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
    return 35;
    }
}




-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 5; //added userList
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: return the individual array counts
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 0; //number of buttons at the bottom. 3 by default.
            break;

        default:
            return 0;
            break;
    }
}

////using header VIEW method instead
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section)
//    {
//        case 0:
//            return @"Group description";
//            break;
//        case 1:
//            return @"User uploaded pictures";
//            break;
//            //        case 2:
//            //            return @"Control";
//            //            break;
//
//        default:
//            return nil;
//            break;
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoCell"];
//            cell.backgroundImageView.image = [UIImage imageWithData:self.group.imageData];
            cell.backgroundImageView.image = [UIImage imageWithData:self.group.imageData];
            [cell.backgroundImageView setClipsToBounds:YES];
            self.navigationItem.title = self.group.name;
            return cell;
        }
            break;
        case 1:
        {
            TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
            //            cell.label.numberOfLines = 0;
            //            cell.label.text = self.aString;
            cell.textView.text = self.group.memo;
            cell.textView.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];

            cell.textView.scrollEnabled = NO;

            return cell;
        }
            break;

        case 2: //userList
        {
            ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];

            cell.collectionView.dataSource = self;
            cell.collectionView.delegate = self;
            cell.collectionView.pagingEnabled = NO;
            cell.collectionView.tag = 0;

            return cell;
        }
            break;

        case 3: //imageList
        {
            ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];

            cell.collectionView.dataSource = self;
            cell.collectionView.delegate = self;
            cell.collectionView.pagingEnabled = NO;
            cell.collectionView.tag = 1;

            return cell;
        }
            break;

        case 4:
        {
            ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];

            switch (indexPath.row)
            {
                case 0:
                    [cell.button setTitle:@"Join group" forState:UIControlStateNormal];
                    [cell.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [cell.button setHidden:NO];
//                    [cell.button.layer setCornerRadius:15];
                    break;

                case 1:
                    [cell.button setTitle:@"Report group" forState:UIControlStateNormal];
                    [cell.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [cell.button setHidden:NO];
//                    [cell.button.layer setCornerRadius:15];
                    break;
//                case 2:
//                    [cell.button setHidden:YES];
//                    break;

                default:
                    [cell.button setHidden:YES];
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:230.0/250.0 blue:230.0/250.0 alpha:0.5f];

            return cell;
        }
            break;

        default:
            return nil;
            break;
    }

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    if (collectionView.tag == 0)
    {
        return self.friendArray.count;
    }
    else if (collectionView.tag == 1)
    {
        return self.collectionViewArray.count;
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
   if (collectionView.tag == 0)
   {
       NSInteger i = indexPath.item;
       Profile *profile = self.friendArray[i];

       PFQuery *profilesQuery = [Profile query];
       [profilesQuery getObjectInBackgroundWithId:profile.objectId block:^(PFObject *object, NSError *error)
            {
                Profile *profileWithData = (Profile *)object;
                [self.friendArray replaceObjectAtIndex:i withObject:profileWithData];
                cell.customImageView.image = [UIImage imageWithData:profileWithData.avatarData];
//                cell.backgroundColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor colorWithRed:(221.0/255.0) green:(221.0/255.0) blue:(221.0/255.0) alpha:1.0f];
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            }];
//       }
//
//       Profile *profile = self.friendArray[indexPath.item];
//       cell.customImageView.image = [UIImage imageWithData:profile.avatarData];
   }
   else
   {
        cell.customImageView.image = [UIImage imageNamed:@"noimage"];

        Photo *photoObj = self.collectionViewArray[indexPath.item];
        PFFile *imageFile = photoObj.imageData;
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (error)
             {
                 [self errorAlertWindow:error.localizedDescription];
             }
             else
             {
                 cell.customImageView.image = [UIImage imageWithData:data];
//                 cell.backgroundColor = [UIColor blackColor];
                   cell.backgroundColor = [UIColor colorWithRed:(221.0/255.0) green:(221.0/255.0) blue:(221.0/255.0) alpha:1.0f];

             }
             
         }];

    }

    //    cell.customImageView.image = self.collectionViewArray[indexPath.item];
    //    cell.customImageView.image = [UIImage imageNamed:@"textImage"];
//    cell.backgroundColor = [UIColor blackColor];
      cell.backgroundColor = [UIColor colorWithRed:(221.0/255.0) green:(221.0/255.0) blue:(221.0/255.0) alpha:1.0f];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//TODO: optimize the logic for performance
    if (collectionView.tag == 0)
    {
        Profile *profile = self.friendArray[indexPath.item];
        PFQuery *query = [Profile query];
        [query includeKey:@"friends"];
        [query getObjectInBackgroundWithId:profile.objectId block:^(PFObject *object, NSError *error)
        {
            if (error)
            {
                [self errorAlertWindow:error.localizedDescription];
            }
            else
            {
                [self performSegueWithIdentifier:@"groupToUserSegue" sender:(Profile *)object];
            }
        }];

    }
}

//MARK: action methods

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"editSegue" sender:self.group];
}

-(void)onGroupJoinButtonPressed:(id)sender
{

    //create a Parse's pointer to the current Profile object
    Profile *profile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:self.currentProfile.objectId];
    NSMutableArray *profilesArray = [NSMutableArray array];
//    NSMutableArray *groupMessageArray = [NSMutableArray array];
    if (self.group.profiles.count != 0)
    {
        profilesArray = [self.group.profiles mutableCopy];
    }
    [profilesArray addObject:profile];

    PFObject *currentGroup = [PFObject objectWithoutDataWithClassName:@"Group" objectId:self.group.objectId];

    self.currentProfile.isGroupMessaging = [self addObjectId:currentGroup inArray:self.currentProfile.isGroupMessaging];

    [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            [self errorAlertWindow:error.localizedDescription];
        }
    }];
//    [self.currentProfile.isGroupMessaging addObject:self.group]
    self.group.profiles = profilesArray;

    [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            [self errorAlertWindow:error.localizedDescription];
        }
        else
        {
            [self showJoinButtonIfNotInGroup];
        }
    }];

}

-(void)onGroupLeaveButtonPressed:(id)sender
{
    NSMutableArray *profilesArray = [self.group.profiles mutableCopy];
    [profilesArray removeObjectAtIndex:[self isProfileInGroup:self.group profile:self.currentProfile]];
    self.group.profiles = profilesArray;

    self.currentProfile.isGroupMessaging = [self removeObjectId:self.group.objectId inArray:self.currentProfile.isGroupMessaging];

    [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            [self errorAlertWindow:error.localizedDescription];
        }
    }];

    [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             [self errorAlertWindow:error.localizedDescription];
         }
         else
         {
             [self showJoinButtonIfNotInGroup];
         }
     }];

}

- (NSArray *)addObjectId:(PFObject *)Object inArray:(NSArray *)array
{
    if (array.count == 0)
    {
        return @[Object];
    }
    else
    {
        NSMutableArray *groupArray = [array mutableCopy];
        [groupArray addObject:Object];
        return groupArray;
    }
}
- (NSArray *)removeObjectId:(NSString *)ObjectId inArray:(NSArray *)array
{
    NSMutableArray *currentUserFriendArray = [array mutableCopy];
    NSMutableArray *currentUserFriendsToRemove = [NSMutableArray array];
    for (PFObject *object in currentUserFriendArray)
    {
        if ([[object objectId] isEqual:ObjectId])
        {
            [currentUserFriendsToRemove addObject:object];
        }
    }
    [currentUserFriendArray removeObjectsInArray:currentUserFriendsToRemove];
    return currentUserFriendArray;
}

-(void)errorAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"😭 OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"groupToUserSegue"])
    {
        UserDetailViewController *userVC = [segue destinationViewController];
        userVC.currentProfile = self.currentProfile;
        userVC.profile = (Profile *)sender;
    }
    else
    {
        UINavigationController *navVC = [segue destinationViewController];
        GroupEditViewController *editVC = (GroupEditViewController *)navVC.topViewController;
        editVC.group = (Group *)sender;
        editVC.currentProfile = self.currentProfile;
    }
}





@end
