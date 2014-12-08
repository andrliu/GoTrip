//
//  MessagesViewController.m
//  GoTrip
//
//  Created by Jonathan Chou on 11/25/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "MessagesViewController.h"
#import "Message.h"
#import "Profile.h"
#import "ChatViewController.h"
#import "TestViewController.h"

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrayOfMessages;
@property (strong, nonatomic) NSArray *arrayOfGroupMessages;
@property Profile *currentProfile;
@property Profile *recipientProfile;
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Messages";
    self.tableView.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadGroupMessages];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadGroupMessages
{
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error) {
        self.currentProfile = profile;
        self.arrayOfMessages = profile.isMessaging;
        self.arrayOfGroupMessages= profile.isGroupMessaging;
        NSMutableArray *tempArray = [NSMutableArray array];
        for(Group *linkedGroup in self.arrayOfGroupMessages)
        {
            PFQuery *group = [Group query];
            [group whereKey:@"objectId" equalTo:linkedGroup.objectId];
            Group *tempGroup = [[group findObjects] firstObject];
            //            [group findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //                Group *tempGroup = objects.firstObject;
            if (tempGroup != nil) {
                [tempArray addObject:tempGroup];
            }
            else{
                
                //forget this group, it's deleted
            }
            if ([self.arrayOfGroupMessages lastObject] == linkedGroup) {
                NSLog(@"Last iteration");
                self.arrayOfGroupMessages = tempArray;
                [self.tableView reloadData];
            }
            //        }];
        }
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:  withRowAnimation:UITableViewRowAnimationBottom];
        //          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
        
    }];
    
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    //   [headerView setBackgroundColor:[UIColor grayColor]];
    [headerView setBackgroundColor:[UIColor colorWithRed:(33.0/255.0) green:(33.0/255.0) blue:(33.0/255.0) alpha:1.0f]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.bounds.size.width - 10, 20)];
    
    switch (section)
    {
        case 0:
            label.text = @"Groups";
            break;
        case 1:
            label.text = @"Users";
            break;
        default:
            label.text = @"";
            break;
    }
    
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if (section == 0)
    //    {
    //        return 0;
    //    }
    //    else
    //    {
    return 30;
    //    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    if(self.currentProfile.isGroupMessaging )
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
    if (section == 0)
        return @"Group";
    else
        return @"User";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1)
        return self.arrayOfMessages.count;
    
    else
        return self.arrayOfGroupMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0f];
    
    if(indexPath.section == 1)
    {
        Profile *linkedProfile = self.arrayOfMessages[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",linkedProfile.firstName ];
        
    }
    
    else
    {
        
        Group *linkedGroup = self.arrayOfGroupMessages[indexPath.row];
        
        //        PFQuery *group = [Group query];
        //        [group whereKey:@"objectId" equalTo:linkedGroup.objectId];
        //        [group findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //            Group *tempGroup = objects.firstObject;
        //            if (tempGroup != nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",linkedGroup.name, linkedGroup.destination ];
        //            }
        //            else{
        //                cell.textLabel.text = @"Deleted group";
        //            }
        //        }];
    }
    
    
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //     TestViewController *testVC = [[TestViewController alloc] init];
//    //      [self.navigationController pushViewController:testVC animated:YES];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *chatVC = segue.destinationViewController;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if(indexPath.section == 1)
        chatVC.passedRecipient = self.arrayOfMessages[indexPath.row];
    else
        chatVC.passedGroup = self.arrayOfGroupMessages[indexPath.row];
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
