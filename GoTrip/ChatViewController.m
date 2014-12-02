//
//  MessageViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "Profile.h"
#import "JSQMessage.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "UIColor+JSQMessages.h"
#define MAX_ENTRIES_LOADED 10

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource>
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
    [self.messageTableView setHidden:YES];
    //sets the recipient profile
    self.recipientProfile = self.passedProfile;
    self.messageTextField.delegate = self;
    [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error) {
        self.currentUserProfile = profile;
        [self loadLocalChat];
    }];
    
    self.userName = @"Jon";
    //passed profiles username here
    
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
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
    [formatter setDateFormat:@"MM-dd"];
    
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:theDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        [formatter setDateFormat:@"HH:mm a"];
        
    }
    
    cell.textLabel.text = [self.messageData[indexPath.row] objectForKey:@"text"];
    //    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[self.messageData[indexPath.row] objectForKey:@"date"]];
    
    
    NSString *timeString = [formatter stringFromDate:theDate];
    
    cell.detailTextLabel.text = timeString;
    
    return cell;
}





- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSLog(@"the text content%@",self.messageTextField.text);
    [textField resignFirstResponder];
    
    //    self.recipientProfile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:[NSString stringWithFormat:@"%@", self.recipientTextField.text]];
    
    //for test purposes
    self.recipientProfile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:@"Q8DIiKZFYI"];
    
    
    
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
        [self changeProfileMessagingSystem];
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
        
        
        PFQuery *a = [Message query];
        //        PFObject *abc = [Message objectWithoutDataWithClassName:@"Profile" objectId:@"Q8DIiKZFYI"];
        
        PFObject *user1 = [Profile objectWithoutDataWithObjectId:@"Q8DIiKZFYI"];
        PFObject *user2 = [Profile objectWithoutDataWithObjectId:@"yKcMGScuaA"];
        [a whereKey:@"sender" equalTo:user1];
        [a whereKey:@"userRecipient" equalTo:user2];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu chats from cache.", (unsigned long)objects.count);
                [self.messageData removeAllObjects];
                
//                [self.messageData addObjectsFromArray:objects];
                for(Message *originalMessage in objects){
                    
//                     JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Jon" senderDisplayName:@"Jon" date:[NSDate date] text:@"hihihihihi"];
                    JSQMessage *message = [[JSQMessage alloc] initWithSenderId: originalMessage.userName senderDisplayName: originalMessage.userName  date:originalMessage.createdAt text:originalMessage.text];
                    
                    [self.messageData addObject:message];
                    
                }
                [(JSQMessagesCollectionView *)self.collectionView reloadData];
//                JSQMessagesCollectionView *temp = [[JSQMessagesCollectionView alloc] init];
//                [temp reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        //    PFQuery *b = [Message query];
        //    [query whereKey:@:sender" equalTo:@"yKcMGScuAa"];
        //    [query find:@"yKcMGScuaA" block:^(PFObject *object, NSError *error) {
        //        <#code#>
        //    }];
        
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByDescending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        
        
        
        //original query for all the data
        
        //        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //
        //            if (!error) {
        //                // The find succeeded.
        //                NSLog(@"Successfully retrieved %lu chats from cache.", (unsigned long)objects.count);
        //                [self.messageData removeAllObjects];
        //
        //                [self.messageData addObjectsFromArray:objects];
        //                [self.messageTableView reloadData];
        //            } else {
        //                // Log details of the failure
        //                NSLog(@"Error: %@ %@", error, [error userInfo]);
        //            }
        //        }];
        //    }
        
        
        
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
                            //                        [self.messageTableView scrollsToTop];
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
    
}
- (void)changeProfileMessagingSystem
{
    
    PFQuery *query = [Profile query];
    
    [query getObjectInBackgroundWithId:@"Q8DIiKZFYI" block:^(PFObject *object, NSError *error) {
        
        BOOL checkRecipientBOOL = YES;
        
        NSMutableArray *listOfUsersThatHaveMessagesWith = [NSMutableArray array];
        
        
        self.recipientProfile = (Profile *)object;
        if(self.recipientProfile.isMessaging.count == 0)
        {
            
        }
        else
        {
            listOfUsersThatHaveMessagesWith = [self.recipientProfile.isMessaging mutableCopy];
        }
        
        for(Profile *profile in listOfUsersThatHaveMessagesWith){
            if([profile.objectId isEqualToString:self.currentUserProfile.objectId])
                checkRecipientBOOL = NO;
        }
        
        
        
        
        if(checkRecipientBOOL)
        {
            [listOfUsersThatHaveMessagesWith addObject:self.currentUserProfile];
            self.recipientProfile.isMessaging = listOfUsersThatHaveMessagesWith;
            [self.recipientProfile saveInBackground];
        }
    }];
    
    
    NSMutableArray *listOfUsersThatIHaveMessagesWith = [NSMutableArray array];
    
    
    if(self.currentUserProfile.isMessaging.count == 0)
    {
    }
    
    else
    {
        listOfUsersThatIHaveMessagesWith = [self.currentUserProfile.isMessaging mutableCopy];
    }
    
    BOOL checkBOOL = YES;
    for(Profile *profile in listOfUsersThatIHaveMessagesWith){
        
        if([profile.objectId isEqualToString:self.recipientProfile.objectId])
            checkBOOL = NO;
    }
    
    if(checkBOOL){
        [listOfUsersThatIHaveMessagesWith addObject:self.recipientProfile];
        self.currentUserProfile.isMessaging = listOfUsersThatIHaveMessagesWith;
        [self.currentUserProfile saveInBackground];
    }
    
    
    
    
}



- (IBAction)onButtonPressedSendMessage:(UIBarButtonItem *)sender
{
    [self textFieldShouldReturn:self.messageTextField];
}












/**
 *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
 *
 *  @return An initialized string describing the current sender to display in a `JSQMessagesCollectionViewCell`.
 *
 *  @warning You must not return `nil` from this method. This value does not need to be unique.
 */
- (NSString *)senderDisplayName
{
    return @"Jon";
}

/**
 *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
 *
 *  @return An initialized string identifier that uniquely identifies the current sender.
 *
 *  @warning You must not return `nil` from this method. This value must be unique.
 */
- (NSString *)senderId
{
    return @"1";
}

/**
 *  Asks the data source for the message data that corresponds to the specified item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `JSQMessageData` protocol. You must not return `nil` from this method.
 */
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Jon" senderDisplayName:@"Jon" date:[NSDate date] text:@"hihihihihi"];
//    return message;
//    
    return self.messageData[indexPath.item];

}

/**
 *  Asks the data source for the message bubble image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `JSQMessageBubbleImageDataSource` protocol. You may return `nil` from this method if you do not
 *  want the specified item to display a message bubble image.
 *
 *  @discussion It is recommended that you utilize `JSQMessagesBubbleImageFactory` to return valid `JSQMessagesBubbleImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `JSQMessageBubbleImageDataSource` protocol.
 *
 *  @warning Note that providing your own bubble image data source objects may require additional
 *  configuration of the collectionView layout object, specifically regarding its `messageBubbleTextViewFrameInsets` and `messageBubbleTextViewTextContainerInsets`.
 *
 *  @see JSQMessagesBubbleImageFactory.
 *  @see JSQMessagesCollectionViewFlowLayout.
 */
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImage *outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    JSQMessagesBubbleImage *incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    JSQMessage *message = self.messageData[indexPath.item];
    if ([message.senderId isEqualToString:@"Jon"])
    {
       
    return outgoingBubbleImageData;
    }
    else
        return incomingBubbleImageData;
    
}

/**
 *  Asks the data source for the avatar image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A initialized object that conforms to the `JSQMessageAvatarImageDataSource` protocol. You may return `nil` from this method if you do not want
 *  the specified item to display an avatar.
 *
 *  @discussion It is recommended that you utilize `JSQMessagesAvatarImageFactory` to return valid `JSQMessagesAvatarImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `JSQMessageAvatarImageDataSource` protocol.
 *
 *  @see JSQMessagesAvatarImageFactory.
 *  @see JSQMessagesCollectionViewFlowLayout.
 */
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messageData.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    //    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    //
//        if (!msg.isMediaMessage) {
    JSQMessage *message = [self.messageData objectAtIndex:indexPath.item];

    
            if ([message.senderId isEqualToString:@"Jon"]){
                cell.textView.textColor = [UIColor blackColor];
            }
            else {
                cell.textView.textColor = [UIColor whiteColor];
            }
    //
    //        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
    //                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    //    }
    
    return cell;
}


@end
