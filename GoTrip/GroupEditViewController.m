//
//  GroupEditViewController.m
//  GoTrip
//
//  Created by Alex on 12/3/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupEditViewController.h"
#import "Group.h"
#import "Profile.h"
#import "CustomTableViewCell.h"
#import "EditTableViewCell.h"
#import "TextTableViewCell.h"



@interface GroupEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isDateOpen;
@property BOOL showStartDate;
@property BOOL showEndDate;
@property NSDateFormatter *dateFormat;

@end

@implementation GroupEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateFormat = [[NSDateFormatter alloc] init];
    //    [self.dateFormat setDateFormat:@"MM/dd/yyyy"];
    [self.dateFormat setDateStyle:NSDateFormatterLongStyle];

    self.showStartDate = NO;
    self.showEndDate = NO;

    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: delegation methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theFloat = 0;


    CGFloat height = [self heightForString:self.group.memo];


    switch (indexPath.section)
    {
        case 0:
            theFloat = self.view.frame.size.width/2.5;
            break;
        case 1:
            theFloat = 44.0;
            break;
        case 2:

            if ((indexPath.row % 2) == 0)
            {
                theFloat =  44.0;
            }
            else
            {
                // This is the index path of the date picker cell in the static table
                if ((indexPath.row == 1 && self.showStartDate) || (indexPath.row == 3 && self.showEndDate))
                {
                    theFloat = 162; //expands only one datePicker at a time
                }
                else
                {
                    theFloat = 0;
                }
            }
            break;
        case 3:
            theFloat =  height*1.03 + 20;
//            theFloat = 200.0;
            break;

        default:
            theFloat =  0;
            break;
    }

    //    NSLog(@"section: %li row: %li height: %f",(long)indexPath.section, (long)indexPath.row, theFloat);

    return theFloat;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            self.showStartDate = !self.showStartDate;
            if (self.showEndDate)
            {
                self.showEndDate = NO;
            }
        }
        else if (indexPath.row == 2)
        {
            self.showEndDate = !self.showEndDate;
            if (self.showStartDate)
            {
                self.showStartDate = NO;
            }
        }

    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:2]];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    if (indexPath.section != 1)
    {
        [self.view endEditing:YES];
    }

}

- (CGFloat)heightForString:(NSString *)theString
{
    CGRect textViewSize = [theString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 16, CGFLOAT_MAX)
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                  context:nil];

    return textViewSize.size.height;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    //   [headerView setBackgroundColor:[UIColor grayColor]];
//    [headerView setBackgroundColor:[UIColor colorWithRed:(33.0/255.0) green:(33.0/255.0) blue:(33.0/255.0) alpha:1.0f]];
    [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.bounds.size.width - 10, 20)];

    switch (section)
    {
        case 0:
            label.text = @"";
            break;
        case 1:
            label.text = @"Info";
            break;
        case 2:
            label.text = @"";
            break;
        case 3:
            label.text = @"Description";
            break;

        default:
            label.text = @"";
            break;
    }

    label.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 0;
            break;
        case 1:
            return 30.0;
            break;
        case 2:
            return 0;
            break;
        case 3:
            return 30.0;
            break;

        default:
            return 0;
            break;
    }
}




-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 2; //name + destination
            break;
        case 2:
            return 4; //dateCell + datePicker
            break;
        case 3:
            return 1;
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
            CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoEditCell"];
            //            cell.backgroundImageView.image = [UIImage imageWithData:self.group.imageData];
            cell.backgroundImageView.image = [UIImage imageWithData:self.group.imageData];
            [cell.backgroundImageView setClipsToBounds:YES];

            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
            break;
        case 1:
        {
            EditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailsCell" forIndexPath:indexPath];
            cell.textField.delegate = self;

            if (indexPath.row == 0)
            {
                cell.textField.placeholder = @"Group Name";
                cell.textField.text = self.group.name;
            }
            else
            {
                cell.textField.placeholder = @"Group Destination";
                cell.textField.text = self.group.destination;
            }
//            cell.textView.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];

//            cell.textView.scrollEnabled = NO;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
            break;

        case 2:
        {

            CustomTableViewCell *cell = nil;

            NSString *cellID;

            if ((indexPath.row % 2) == 0)
            {
                // the indexPath is the one containing the inline date picker
                cellID = @"dateCell";     // the current/opened date picker cell
            }
            else if ((indexPath.row % 2) == 1)
            {
                // the indexPath is one that contains the date information
                cellID = @"datePicker";       // the start/end date cells
            }
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (indexPath.row == 0)
            {
                cell.nameLabel.text = @"Start Date";
                NSString *startDateString = [self.dateFormat stringFromDate:self.group.startDate];
                cell.startLabel.text = startDateString;
            }
            else if (indexPath.row == 2)
            {
                cell.nameLabel.text = @"End Date";
                NSString *endDateString = [self.dateFormat stringFromDate:self.group.endDate];
                cell.startLabel.text = endDateString;
            }

            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
            break;

        case 3:
        {
            TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textEditCell" forIndexPath:indexPath];
            //            cell.label.numberOfLines = 0;
            //            cell.label.text = self.aString;
            cell.textView.text = self.group.memo;
            cell.textView.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0f];

            cell.textView.scrollEnabled = YES;

//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:230.0/250.0 blue:230.0/250.0 alpha:0.5f];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
    
}




//MARK: cutom methods
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

    //    self.group.creator;
    //for new group creation
    [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             [self errorAlertWindow:error.localizedDescription];
         }
         else
         {
             Group *group = [Group objectWithoutDataWithClassName:@"Group" objectId:self.group.objectId];

             //check is the group is in isGroupMessagin array and add if not
             NSInteger groupIndex = [self isInGroupMessaging:group profile:self.currentProfile];
             if (groupIndex == -1)
             {
                 self.currentProfile.isGroupMessaging = [self addObjectId:group inArray:self.currentProfile.isGroupMessaging];

                 [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error)
                      {
                          [self errorAlertWindow:error.localizedDescription];
                      }
                      else
                      {
                          [self dismissViewControllerAnimated:YES completion:nil];
                          NSLog(@"profile save complete");
                      }
                  }];

             }
             //            [self dismissViewControllerAnimated:YES completion:nil];
             else
             {
                 NSLog(@"group is already in isGroupMessaging");
                 [self dismissViewControllerAnimated:YES completion:nil];
             }

         }

     }];

}

-(NSInteger)isInGroupMessaging:(Group *)group profile:(Profile *)profile
{

    NSInteger i=0;
    NSInteger objectIndex = -1;
    for (Group *groupForProfile in profile.isGroupMessaging)
    {
        if ([groupForProfile.objectId isEqualToString:group.objectId])
        {
            objectIndex = i;

            break;
        }
        else
        {
            if (i>profile.isGroupMessaging.count)
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
                                  NSMutableArray *groupArray = [self.currentProfile.isGroupMessaging mutableCopy];
                                  NSInteger profileIndex = [self isInGroupMessaging:self.group profile:self.currentProfile];
                                  if (profileIndex != -1)
                                  {
                                      [groupArray removeObjectAtIndex:profileIndex];
                                      self.currentProfile.isGroupMessaging = groupArray;
                                      [self.currentProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                       {
                                           if (error)
                                           {
                                               [self errorAlertWindow:error.localizedDescription];
                                           }
                                       }];

                                  }

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
