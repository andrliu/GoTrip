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
    [self loadGroupMessages];
    // Do any additional setup after loading the view.
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
        
        [self.tableView reloadData];
    }];
    
    
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

    if(indexPath.section == 1)
    {
    Profile *linkedProfile = self.arrayOfMessages[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",linkedProfile.firstName ];

    }
    
    else
    {
        
        Group *linkedGroup = self.arrayOfGroupMessages[indexPath.row];
        PFQuery *group = [Group query];
        [group whereKey:@"objectId" equalTo:linkedGroup.objectId];
        [group findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            Group *tempGroup = objects.firstObject;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",tempGroup.canonicalName ];
        }];
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //     TestViewController *testVC = [[TestViewController alloc] init];
    //      [self.navigationController pushViewController:testVC animated:YES];
}

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
