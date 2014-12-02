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
        
        
        [self.tableView reloadData];
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Profile *linkedProfile = self.arrayOfMessages[indexPath.row];
    
    //    this is for alexey's bs
    //    PFQuery *query = [Profile query];
    //
    //    [query getObjectInBackgroundWithId:linkedProfile.objectId block:^(PFObject *object, NSError *error) {
    //        self.recipientProfile = (Profile *)object;
    //
    //    }];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",linkedProfile.firstName ];
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
        chatVC.passedRecipient = self.arrayOfMessages[indexPath.row];
    
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
