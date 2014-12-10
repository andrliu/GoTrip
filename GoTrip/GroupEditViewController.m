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
#import "GKImagePicker.h"
//#import "GKImageCropViewController.h"



@interface GroupEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GKImagePickerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property BOOL showStartDate;
@property BOOL showEndDate;
@property NSDateFormatter *dateFormat;
@property Group *editGroup;
@property NSIndexPath *textFieldIndexPath;
@property NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property BOOL isEditing;
@property CGFloat kbHeight;
@property GKImagePicker *imagePicker;

@end

@implementation GroupEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.editGroup = self.group;

    self.isEditing = NO;

    self.dateFormat = [[NSDateFormatter alloc] init];
    //    [self.dateFormat setDateFormat:@"MM/dd/yyyy"];
    [self.dateFormat setDateStyle:NSDateFormatterLongStyle];

    self.showStartDate = NO;
    self.showEndDate = NO;

    self.tableView.tableFooterView = [[UIView alloc] init];
}


//MARK: delegation methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theFloat = 0;


    CGFloat height = [self heightForString:self.editGroup.memo];
    if (height < 200)
    {
        height =  200;
    }


    switch (indexPath.section)
    {
        case 0:
            theFloat = self.view.frame.size.width/2.5;
            break;
        case 1:
            theFloat = 60.0;
            break;
        case 2:

            if ((indexPath.row % 2) == 0)
            {
                theFloat =  60.0;
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
//            if (self.isEditing)
//            {
//                theFloat = self.view.frame.size.height - self.kbHeight;
//            }
//            else
//            {
//                theFloat =  height*1.03 + 20;
//            }
            theFloat = height*1.03 + 20;
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
    [self.view endEditing:YES];
    if (indexPath.section == 0)
    {
        [self changeImageOnImagePressed];
        NSLog(@"image tapped");
    }

    if (indexPath.section != 1)
    {
        [self.view endEditing:YES];
    }

    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            self.showStartDate = !self.showStartDate;
            if (self.showEndDate)
            {
                self.showEndDate = NO;
            }
            self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:2];
        }
        else if (indexPath.row == 2)
        {
            self.showEndDate = !self.showEndDate;
            if (self.showStartDate)
            {
                self.showStartDate = NO;
            }
            self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:2];
        }

    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:2]];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

    if (indexPath.section == 3)
    {
//       [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
    //   [headerView setBackgroundColor:[UIColor grayColor]];
//    [headerView setBackgroundColor:[UIColor colorWithRed:(33.0/255.0) green:(33.0/255.0) blue:(33.0/255.0) alpha:1.0f]];
    [headerView setBackgroundColor:[UIColor colorWithRed:(229.0/255.0) green:(229.0/255.0) blue:(229.0/255.0) alpha:1.0f]];
//    [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.bounds.size.width - 10, 20)];
    UIButton *button = [[UIButton alloc] initWithFrame:headerView.frame];
    [button addTarget:self action:@selector(headerButtonAction:) forControlEvents:UIControlEventAllEvents];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.text = @"";

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
//    label.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];
    [headerView addSubview:label];
    [headerView addSubview:button];
    return headerView;
}

-(void)headerButtonAction:(id)sender
{
    [self.view endEditing:YES];
    self.isEditing = NO;
//    UIButton *clickedButton = (UIButton*)sender;
//    NSLog(@"section : %i",clickedButton.tag);


}

//MARK: UIImagePickerDelegate Methods
- (void)changeImageOnImagePressed
{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width/2.5);
    self.imagePicker.delegate = self;
    [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    UIImage *resizedImage = [self compressForUpload:image];
    self.editGroup.imageData = UIImageJPEGRepresentation(resizedImage, 0.5);

    NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[textViewIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    [self hideImagePicker];
}

- (void)hideImagePicker
{
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
//     self.editGroup.imageData = UIImageJPEGRepresentation(image, 0.1);
    UIImage *resizedImage = [self compressForUpload:image];
    self.editGroup.imageData = UIImageJPEGRepresentation(resizedImage, 0.5);

    NSIndexPath *imageIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[imageIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    [picker dismissViewControllerAnimated:YES completion:nil];

}

//MARK: image compressor
- (UIImage *)compressForUpload:(UIImage *)original
{
    // Calculate new size given scale factor.

    CGSize originalSize = original.size;
    CGFloat scale = 750.0 / originalSize.width;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);

    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return compressedImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 0;
            break;
        case 1:
            return 35.0;
            break;
        case 2:
            return 0;
            break;
        case 3:
            return 35.0;
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
            if (self.editGroup.imageData)
            {
                cell.backgroundImageView.image = [UIImage imageWithData:self.editGroup.imageData];
            }
            else
            {
                cell.backgroundImageView.image = [UIImage imageNamed:@"750x300"];
            }
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
                cell.textField.text = self.editGroup.name;
                cell.textField.tag = 0;
            }
            else
            {
                cell.textField.placeholder = @"Group Destination";
                cell.textField.text = self.editGroup.destination;
                cell.textField.tag = 1;
            }
//            cell.textView.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];

//            cell.textView.scrollEnabled = NO;
            cell.textField.delegate = self;
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


            switch (indexPath.row)
            {
                case 0:
                    {
                        cell.nameLabel.text = @"Start Date";
                        NSString *startDateString = [self.dateFormat stringFromDate:self.editGroup.startDate];
                        cell.startLabel.text = startDateString;
                        cell.backgroundColor = [UIColor clearColor];
                        break;
                    }
                case 1:
                    cell.backgroundColor = [UIColor whiteColor];
                    break;
                case 2:
                    {
                        cell.nameLabel.text = @"End Date";
                        NSString *endDateString = [self.dateFormat stringFromDate:self.editGroup.endDate];
                        cell.startLabel.text = endDateString;
                        cell.backgroundColor = [UIColor clearColor];
                         break;
                    }
                case 3:
                    cell.backgroundColor = [UIColor whiteColor];
                    break;

                default:
                    cell.backgroundColor = [UIColor clearColor];
                    break;
            }
//            if (indexPath.row == 0)
//            {
//                cell.nameLabel.text = @"Start Date";
//                NSString *startDateString = [self.dateFormat stringFromDate:self.editGroup.startDate];
//                cell.startLabel.text = startDateString;
//            }
//            else if (indexPath.row == 2)
//            {
//                cell.nameLabel.text = @"End Date";
//                NSString *endDateString = [self.dateFormat stringFromDate:self.editGroup.endDate];
//                cell.startLabel.text = endDateString;
//            }

            return cell;
        }
            break;

        case 3:
        {
            TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textEditCell" forIndexPath:indexPath];
            //            cell.label.numberOfLines = 0;
            //            cell.label.text = self.aString;
            cell.textView.delegate = self;
            cell.textView.text = self.editGroup.memo;
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


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    self.isEditing = YES;

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.editGroup.memo = textView.text;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    self.isEditing = NO;

    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
//    self.isEditing = YES;
    // Assign new frame to your view
//    [self.view setFrame:CGRectMake(0,-110,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.

    NSDictionary *userInfo = [notification userInfo];
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];

    self.tableViewBottomConstraint.constant = kbFrame.size.height;
    [self.view layoutIfNeeded];
//    [self.tableViewBottomConstraint setConstant:kbFrame.size.height];
//    self.kbHeight = kbFrame.size.height;
    if (self.isEditing)
    {
        NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    //    [self.tableView reloadRowsAtIndexPaths:@[textViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView scrollToRowAtIndexPath:textViewIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }


}

-(void)keyboardDidHide:(NSNotification *)notification
{
//    self.isEditing = NO;
//    NSDictionary *userInfo = [notification userInfo];
//    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.tableViewBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];

//    NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
//    [self.tableView reloadRowsAtIndexPaths:@[textViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
//    [self.tableView scrollToRowAtIndexPath:textViewIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self.view endEditing:YES];
//    NSLog(@"did tap");
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    [self resignFirstResponder];
//    NSLog(@"did scroll");
//}


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
    if (!self.editGroup.imageData)
    {
        [self defaultImagePicker];
    }

    if (!self.editGroup.memo)
    {
        self.editGroup.memo = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et auctor nulla. Pellentesque non odio vel nibh sagittis pulvinar. Proin sed dolor ut nisi scelerisque maximus. Cras gravida accumsan leo ut facilisis. Aenean rhoncus hendrerit orci, at fermentum ante venenatis et. Mauris vitae aliquam arcu, eget ultricies nisi. Praesent gravida dictum eros sed ultricies. Suspendisse dignissim vehicula purus, sollicitudin pretium ante lacinia non. Pellentesque blandit finibus ligula, eu viverra elit rhoncus sed. Ut mattis, felis ut lobortis luctus, neque augue aliquet mi, eget ullamcorper ex nisi a risus. Pellentesque a metus ac tellus tincidunt aliquam eu id velit. Phasellus rhoncus quis magna sed hendrerit. Donec urna justo, egestas id imperdiet sit amet, hendrerit a ligula. Fusce ultricies nibh a velit fringilla, at tempor nunc volutpat. Fusce laoreet tristique tellus, eget auctor metus.\n\nSuspendisse sit amet neque at leo ullamcorper elementum eu in metus. Proin at purus vel felis molestie tristique at eget augue. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aenean varius risus vel imperdiet interdum. Suspendisse nec diam nec dui aliquam convallis vel id ex. Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut imperdiet ante tellus, quis finibus diam posuere quis.";
    }

    if (!self.editGroup.name)
    {
        NSString *name = [NSString stringWithFormat:@"New Group %@",[self randomStringWithLength:3]];
        self.editGroup.name = name;
        self.editGroup.canonicalName = [name lowercaseString];
    }

    if (!self.editGroup.destination)
    {
        self.editGroup.destination = @"undecided";
    }

//TODO: doublecheck this logic
    //for new group creation
    self.group = self.editGroup;

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

- (IBAction)textFieldAction:(UITextField *)textField
{
    if (textField.tag == 0)
    {
        self.editGroup.name = textField.text;
        self.editGroup.canonicalName = [textField.text lowercaseString];
    }
    else if (textField.tag == 1)
    {
        self.editGroup.destination = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)datePickerAction:(UIDatePicker *)sender
{
    NSIndexPath *targetedCellIndexPath = nil;

//    if ([self hasInlineDatePicker])
//    {
//        // inline date picker: update the cell's date "above" the date picker cell
//        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:2];
//    }
//    else
//    {
//        // external date picker: update the current "selected" cell's date
//        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
//    }
    CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;

    // update our data model
//    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
//    [itemData setValue:targetedDatePicker.date forKey:kDateKey];

    // update the cell's date string
    cell.startLabel.text = [self.dateFormat stringFromDate:targetedDatePicker.date];
    if (self.datePickerIndexPath.row == 1)
    {
        self.editGroup.startDate = targetedDatePicker.date;
    }
    else if (self.datePickerIndexPath.row == 3)
    {
        self.editGroup.endDate = targetedDatePicker.date;

    }

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
    self.editGroup.imageData = data;
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
