//
//  MessageViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#define MAX_ENTRIES_LOADED 10

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextField;
@property NSString *userName;
@property NSMutableArray *messageData;
@property Profile *currentUserProfile;
@property Profile *recipientProfile;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.messageData = [NSMutableArray array];
    self.messageTextField.delegate = self;
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error) {
        self.currentUserProfile = profile;
    }];
    
    self.userName = @"Jon";
    //passed profiles username here
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
//    self.userTaggingTableView.contentInset = self.commentViewTable.contentInset;
//    self.userTaggingTableView.scrollIndicatorInsets = self.commentViewTable.scrollIndicatorInsets;
    
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - 100, [[UIScreen mainScreen] bounds].size.width, self.toolbar.frame.size.height);
    [self.view addSubview:self.toolbar];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDate *theDate = [self.messageData [indexPath.row] objectForKey:@"date"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    NSString *timeString = [formatter stringFromDate:theDate];
    
    cell.textLabel.text = [self.messageData[indexPath.row] objectForKey:@"text"];
//    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[self.messageData[indexPath.row] objectForKey:@"date"]];
    cell.detailTextLabel.text = timeString;
    
    return cell;
}





- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSLog(@"the text content%@",self.messageTextField.text);
    [textField resignFirstResponder];
    
    self.recipientProfile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:[NSString stringWithFormat:@"%@", self.recipientTextField.text]];
        
    //need to resize table view as well
    
    if (self.messageTextField.text.length>0) {
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"sender", @"recipient", @"text", @"userName", @"date", nil];
        NSArray *objects = [NSArray arrayWithObjects:self.currentUserProfile, self.recipientProfile, self.messageTextField.text, self.userName, [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [self.messageData addObject:dictionary];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0]; //in the future make it the last
        [insertIndexPaths addObject:newPath];
        
        //add in the messages through UI Table View.
        [self.messageTableView beginUpdates];
        [self.messageTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.messageTableView endUpdates];
        [self.messageTableView reloadData];
        
        //adds to Parse back-server.
        Message *newMessage = [Message object];
        
//        newMessage.userRecipient = self.recipientTextField
        //have to find recipient using some dropdown

        newMessage.userRecipient = self.recipientProfile;
        newMessage.text = self.messageTextField.text;
        newMessage.userName = self.userName;
        newMessage.sender = self.currentUserProfile;
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage saveInBackground];
//        [newMessage setObject:self.messageTextField.text forKey:@"text"];
//        [newMessage setObject:self.userName forKey:@"userName"];
//        [newMessage setObject:[NSDate date] forKey:@"date"]; already in parse
//        [newMessage saveInBackground];
        self.messageTextField.text = @"";
    }
    
    // reload the data
    [self loadLocalChat];
    return NO;
}

- (void)loadLocalChat
{
    PFQuery *query = [Message query];
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.messageData count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu chats from cache.", (unsigned long)objects.count);
                [self.messageData removeAllObjects];
                [self.messageData addObjectsFromArray:objects];
                [self.messageTableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    
    
    __block int totalNumberOfEntries = 0;
    [query orderByAscending:@"createdAt"];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            NSLog(@"There are currently %d entries", number);
            
            
            totalNumberOfEntries = number;
            if (totalNumberOfEntries > [self.messageData count]) {
                NSLog(@"Retrieving data");
                
                int newMessageLimit;
                if (totalNumberOfEntries-[self.messageData count]>MAX_ENTRIES_LOADED) {
                    newMessageLimit = MAX_ENTRIES_LOADED;
                }
                else {
                    newMessageLimit = totalNumberOfEntries-[self.messageData count];
                }
                
                query.limit = (int)[NSNumber numberWithInt:newMessageLimit];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved %lu chats.", (unsigned long)objects.count);
                        
                        [self.messageData addObjectsFromArray:objects];
                        //so I need a key for profile right? but that's
                        
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        for (int ind = 0; ind < objects.count; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        
                        [self.messageTableView beginUpdates];
                        [self.messageTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                        [self.messageTableView endUpdates];
                        [self.messageTableView reloadData];
                        [self.messageTableView scrollsToTop];
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
        } else {
            // The request failed, we'll keep the chatData count? ......
            number = [self.messageData count];
        }
    }];
}

- (IBAction)onButtonPressedSendMessage:(UIBarButtonItem *)sender
{
    [self textFieldShouldReturn:self.messageTextField];
}


@end
