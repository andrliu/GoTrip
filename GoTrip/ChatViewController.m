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
#import "JSQMessagesAvatarImageFactory.h"

#import "UIColor+JSQMessages.h"




#import "JSQMessagesViewController.h"

#import "JSQMessagesKeyboardController.h"
#import "GTMessage.h"
#import "JSQMessageAvatarImageDataSource.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "JSQMessagesAvatarImage.h"

#import "JSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

#import "JSQMessageData.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessageAvatarImageDataSource.h"

#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "JSQMessagesTypingIndicatorFooterView.h"
#import "JSQMessagesLoadEarlierHeaderView.h"

#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesTimestampFormatter.h"

#import "NSString+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "UIDevice+JSQMessages.h"
#define MAX_ENTRIES_LOADED 10

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource>
@property NSMutableDictionary *avatars;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextField;
@property NSString *userName;
@property NSMutableArray *messageData;
@property Profile *currentUserProfile;
@property Profile *recipientProfile;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property NSTimer *timer;
@property UIRefreshControl *refreshControl;
@property BOOL isGroupChat;
@property Group *currentGroupProfile;


@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    
    //basic setup
    [super viewDidLoad];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.avatars = [NSMutableDictionary dictionary];
    
    if(self.passedGroup != nil)
        self.isGroupChat = YES;
    
    
    
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.messageData = [NSMutableArray array];
    self.messageTextField.delegate = self;
    [self.messageTableView setHidden:YES];
    
    if(self.isGroupChat) //group converstaion logic
    {
        [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error) {
            self.currentUserProfile = profile;
            NSString *nameString = [NSString stringWithFormat:@"%@ %@",self.currentUserProfile.firstName, self.currentUserProfile.lastName];
            //            self.userName = self.currentUserProfile.objectId;
            self.userName = nameString;
            self.senderId = nameString;
            self.currentGroupProfile = self.passedGroup;
            PFQuery *group = [Group query];
            [group whereKey:@"objectId" equalTo:self.passedGroup.objectId];
            [group findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                self.passedGroup = objects.firstObject;
                self.navigationItem.title = self.passedGroup.name;
                
                [self loadLocalChat];
                
            }];
        }];
    }
    
    
    else //one-to-one conversations logic
    {
        
        //sets the recipient profile

        
        self.recipientProfile =  self.passedRecipient;
        
        [Profile getCurrentProfileWithCompletion:^(Profile *profile, NSError *error) {
            self.currentUserProfile = profile;
            self.userName = self.currentUserProfile.objectId;
            NSString *nameString = [NSString stringWithFormat:@"%@ %@",self.currentUserProfile.firstName, self.currentUserProfile.lastName];
            //            self.userName = self.currentUserProfile.objectId;
            self.userName = nameString;
            self.senderId = nameString;
            [self loadLocalChat];
        }];
        
        self.navigationItem.title = self.recipientProfile.firstName;
    }
    
    //timer and refersh control
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(retrievingFromParse) userInfo:nil repeats:YES];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(retrievingFromParse) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    
}

-(void)retrievingFromParse
{
    
    if(self.isGroupChat) //group converstaion logic
    {
        PFObject *group = [Group objectWithoutDataWithObjectId:self.currentGroupProfile.objectId];
        PFQuery *senderQuery = [Message query];
        
        [senderQuery whereKey:@"groupRecipient" equalTo:self.currentGroupProfile];
        //        [senderQuery whereKey:@"groupRecipient" equalTo:group];
        
        [senderQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                NSLog(@"There are currently %d entries", number);
                
                
                NSInteger totalNumberOfEntries = number;
                
                if (totalNumberOfEntries > [self.messageData count]) {
                    NSLog(@"Retrieving data");
                    [self loadLocalChat];
                }
                [self.refreshControl endRefreshing];

            }
        }];
        
    }
    else
    {
        PFObject *user1 = [Profile objectWithoutDataWithObjectId:self.currentUserProfile.objectId];
        PFObject *user2 = [Profile objectWithoutDataWithObjectId:self.passedRecipient.objectId];
        NSArray *arrayOfUsers  = @[user2, user1];
        PFQuery *senderQuery = [Message query];
        [senderQuery whereKey:@"sender" containedIn:arrayOfUsers];
        [senderQuery whereKey:@"userRecipient" containedIn:arrayOfUsers];
        [senderQuery orderByAscending:@"createdAt"];
        [senderQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                NSLog(@"There are currently %d entries", number);
                
                
                NSInteger totalNumberOfEntries = number;
                if (totalNumberOfEntries > [self.messageData count]) {
                    NSLog(@"Retrieving data");
                    [self loadLocalChat];
                }
                [self.refreshControl endRefreshing];

            }
        }];
    }
    
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

#pragma mark: Table Method Views


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
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:theDate];
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



#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITextField *textField = [[UITextField alloc] init];
    
    textField.text = text;
    
    [self textFieldShouldReturn:textField];
    
    
}

- (void)finishSendingMessage: (NSString *)text
{
    
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = nil;
    [textView.undoManager removeAllActions];
    
    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    
    PFQuery *senderQuery = [Message query];
    
    PFQuery *queryInstallation = [PFInstallation query];
    
    if(self.isGroupChat) //group converstaion logic
    {
        NSMutableArray *tempArray = [NSMutableArray array];
        NSMutableArray *tempArray2 = [NSMutableArray array];
        
        
        //            PFObject *group = [Group objectWithoutDataWithObjectId:self.currentGroupProfile.objectId];
        [senderQuery whereKey:@"groupRecipient" equalTo:self.currentGroupProfile];
        //        [senderQuery whereKey:@"groupRecipient" co
        
        
        //        [senderQuery whereKey:@"groupRecipient" equalTo:group];
        [senderQuery orderByAscending:@"createdAt"];
        [senderQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for(Message *message in objects)
            {
                if([tempArray containsObject:message.sender.objectId])
                {
                    
                }
                else
                {
                    [tempArray addObject: message.sender.objectId];
                }
                
            }
            
            [tempArray removeObject:self.currentUserProfile.objectId];
            
            PFQuery *query = [Profile query];
            [query whereKey:@"objectId" containedIn:tempArray];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for(Profile *profile in objects)
                {
                    [tempArray2 addObject:profile.user];
                }
                
                [queryInstallation whereKey:@"user" containedIn:tempArray2];
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:queryInstallation];
                NSString *stringText = [NSString stringWithFormat:@"%@ > %@: %@", self.currentGroupProfile.name, self.userName, text];
                NSDictionary *dict = @{@"aps":@{@"alert":stringText},@"groupId":self.currentGroupProfile.objectId};
                [push setData:dict];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil)
                     {
                         NSLog(@"SendPushNotification send error.");
                     }
                 }];
            }];
            
            
            
        }];
        
    }
    else
    {
        PFObject *user1 = [Profile objectWithoutDataWithObjectId:self.currentUserProfile.objectId];
        PFObject *user2 = [Profile objectWithoutDataWithObjectId:self.passedRecipient.objectId];
        NSArray *arrayOfUsers  = @[user2, user1];
        
        [senderQuery whereKey:@"sender" containedIn:arrayOfUsers];
        [senderQuery whereKey:@"userRecipient" containedIn:arrayOfUsers];
        [senderQuery whereKey:@"sender" notEqualTo:user1];
        
        [senderQuery orderByAscending:@"createdAt"];
        
        [senderQuery setLimit:1000];
        [queryInstallation whereKey:@"user" equalTo:self.passedRecipient.user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:queryInstallation];
        NSString *stringText = [NSString stringWithFormat:@"%@: %@", self.userName, text];

        NSDictionary *dict = @{@"aps":@{@"alert":stringText},@"objectId":self.currentUserProfile.objectId};
        [push setData:dict];
        //        [push setMessage:text];
        
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"SendPushNotification send error.");
             }
         }];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    //    NSLog(@"the text content%@",self.messageTextField.text);
    [textField resignFirstResponder];
    
    //    self.recipientProfile = [Profile objectWithoutDataWithClassName:@"Profile" objectId:[NSString stringWithFormat:@"%@", self.recipientTextField.text]];
    
    //for test purposes
    
    //need to resize table view as well
    
    //    if (self.messageTextField.text.length>0) {
    //        // updating the table immediately
    //        NSArray *keys = [NSArray arrayWithObjects:@"sender", @"recipient", @"text", @"userName", @"date", nil];
    //        NSArray *objects = [NSArray arrayWithObjects:self.currentUserProfile, self.recipientProfile, self.messageTextField.text, self.userName, [NSDate date], nil];
    //        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //        [self.messageData addObject:dictionary];
    
    //        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    //        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0]; //in the future make it the last
    //        [insertIndexPaths addObject:newPath];
    //
    //        //add in the messages through UI Table View.
    //        [self.messageTableView beginUpdates];
    //        [self.messageTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    //        [self.messageTableView endUpdates];
    //        [self.messageTableView reloadData];
    //
    //adds to Parse back-server.
    
    
    Message *newMessage = [Message object];
    
    if(self.isGroupChat) //group conversation logic
    {
        newMessage.groupRecipient = self.currentGroupProfile;
        newMessage.text = textField.text;
        newMessage.userName = self.userName;
        newMessage.sender = self.currentUserProfile;
        [newMessage setObject:[NSDate date] forKey:@"date"];
    }
    
    else
    {
        newMessage.userRecipient = self.recipientProfile;
        newMessage.text = textField.text;
        newMessage.userName = self.userName;
        newMessage.sender = self.currentUserProfile;
        [newMessage setObject:[NSDate date] forKey:@"date"];
    }
    
    [newMessage saveInBackground];
    
    
    [self addIsMessagingRelationshipInParse];
    
    
    //        [newMessage setObject:self.messageTextField.text forKey:@"text"];
    //        [newMessage setObject:self.userName forKey:@"userName"];
    //        [newMessage setObject:[NSDate date] forKey:@"date"]; already in parse
    //        [newMessage saveInBackground];
    self.messageTextField.text = @"";
    
    
    // reload the data
    
    [self loadLocalChat];
    [self finishSendingMessage: textField.text];
    return NO;
}

- (void)loadLocalChat
{
    PFQuery *senderQuery = [Message query];
    
    
    
    if(self.isGroupChat) //group conversation logic
    {
        PFObject *group = [Group objectWithoutDataWithObjectId:self.currentGroupProfile.objectId];
        
        [senderQuery whereKey:@"groupRecipient" equalTo:self.currentGroupProfile];
        //        [senderQuery whereKey:@"groupRecipient" equalTo:group];
        [senderQuery orderByAscending:@"createdAt"];
        
    }
    
    else
    {
        
        
        PFObject *user1 = [Profile objectWithoutDataWithObjectId:self.currentUserProfile.objectId];
        
        PFObject *user2 = [Profile objectWithoutDataWithObjectId:self.passedRecipient.objectId];
        
        NSArray *arrayOfUsers  = @[user2, user1];
        
        
        [senderQuery whereKey:@"sender" containedIn:arrayOfUsers];
        [senderQuery whereKey:@"userRecipient" containedIn:arrayOfUsers];
        [senderQuery orderByAscending:@"createdAt"];
        
        //  alternative query method
        //        [senderQuery whereKey:@"sender" equalTo:user1];
        //        [senderQuery whereKey:@"userRecipient" equalTo:user2];
        //        PFQuery *recipientQuery = [Message query];
        //
        //        [recipientQuery whereKey:@"sender" equalTo:user2];
        //        [recipientQuery whereKey:@"userRecipient" equalTo:user1];
        
        
        //        PFQuery *bothQueries = [PFQuery orQueryWithSubqueries:@[senderQuery, recipientQuery]];
    }
    
    
    
    [senderQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            // The find succeeded.
            //            NSLog(@"Successfully retrieved %lu chats from cache.", (unsigned long)objects.count);
            [self.messageData removeAllObjects];
            
            //                [self.messageData addObjectsFromArray:objects];
            for(Message *originalMessage in objects){
                
                //                     JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Jon" senderDisplayName:@"Jon" date:[NSDate date] text:@"hihihihihi"];
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId: originalMessage.userName senderDisplayName: originalMessage.userName  date:originalMessage.createdAt text:originalMessage.text];
                
                
                //                GTMessage *gtMessage = [[GTMessage alloc] init];
                //                gtMessage = (GTMessage *)message;
                //                message.profileId = originalMessage.sender.objectId;
                
                [self.messageData addObject:message];
                
            }
            [(JSQMessagesCollectionView *)self.collectionView reloadData];
            [self scrollToBottomAnimated:YES];
            
        }
        
        
    }];
}

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


//
//        __block int totalNumberOfEntries = 0;
//        [query orderByAscending:@"createdAt"];
//
//
//
//        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//            if (!error) {
//                // The count request succeeded. Log the count
//                NSLog(@"There are currently %d entries", number);
//
//
//                totalNumberOfEntries = number;
//                if (totalNumberOfEntries > [self.messageData count]) {
//                    NSLog(@"Retrieving data");
//
//                    int newMessageLimit;
//                    if (totalNumberOfEntries-[self.messageData count]>MAX_ENTRIES_LOADED) {
//                        newMessageLimit = MAX_ENTRIES_LOADED;
//                    }
//                    else {
//                        newMessageLimit = totalNumberOfEntries-[self.messageData count];
//                    }
//
//                    query.limit = (int)[NSNumber numberWithInt:newMessageLimit];
//                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                        if (!error) {
//                            // The find succeeded.
//                            NSLog(@"Successfully retrieved %lu chats.", (unsigned long)objects.count);
//
//                            [self.messageData addObjectsFromArray:objects];
//                            //so I need a key for profile right? but that's
//
//                            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
//                            for (int ind = 0; ind < objects.count; ind++) {
//                                NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
//                                [insertIndexPaths addObject:newPath];
//                            }
//
//                            [self.messageTableView beginUpdates];
//                            [self.messageTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
//                            [self.messageTableView endUpdates];
//                            [self.messageTableView reloadData];
//                            //                        [self.messageTableView scrollsToTop];
//                        } else {
//                            // Log details of the failure
//                            NSLog(@"Error: %@ %@", error, [error userInfo]);
//                        }
//                    }];
//                }
//
//            } else {
//                // The request failed, we'll keep the chatData count? ......
//                number = [self.messageData count];
//            }
//        }];


- (void)addIsMessagingRelationshipInParse
{
    if(self.isGroupChat) //group conversation logic
    {
        
    }
    
    else
    {
        PFQuery *query = [Profile query];
        
        [query getObjectInBackgroundWithId:self.passedRecipient.objectId block:^(PFObject *object, NSError *error) {
            
            BOOL checkRecipientBOOL = YES;
            
            NSMutableArray *listOfUsersThatHaveMessagesWith = [NSMutableArray array];
            
            
            self.passedRecipient = (Profile *)object;
            if(self.passedRecipient.isMessaging.count == 0)
            {
                
            }
            else
            {
                listOfUsersThatHaveMessagesWith = [self.passedRecipient.isMessaging mutableCopy];
            }
            
            for(Profile *profile in listOfUsersThatHaveMessagesWith){
                if([profile.objectId isEqualToString:self.currentUserProfile.objectId])
                    checkRecipientBOOL = NO;
            }
            
            
            
            
            if(checkRecipientBOOL)
            {
                [listOfUsersThatHaveMessagesWith addObject:self.currentUserProfile];
                self.passedRecipient.isMessaging = listOfUsersThatHaveMessagesWith;
                [self.passedRecipient saveInBackground];
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
            
            if([profile.objectId isEqualToString:self.passedRecipient.objectId])
                checkBOOL = NO;
        }
        
        if(checkBOOL){
            [listOfUsersThatIHaveMessagesWith addObject:self.passedRecipient];
            self.currentUserProfile.isMessaging = listOfUsersThatIHaveMessagesWith;
            [self.currentUserProfile saveInBackground];
        }
        
        
        
    }
}



- (IBAction)onButtonPressedSendMessage:(UIBarButtonItem *)sender
{
    [self textFieldShouldReturn:self.messageTextField];
}

//
///**
// *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
// *
// *  @return An initialized string identifier that uniquely identifies the current sender.
// *
// *  @warning You must not return `nil` from this method. This value must be unique.
// */
- (NSString *)senderId
{
    return self.userName;
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
    return self.userName;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isGroupChat) //group converstaion logic
    {
        JSQMessage *message = [self.messageData objectAtIndex:indexPath.item];
        
        /**
         *  iOS7-style sender name labels
         */
        if ([message.senderId isEqualToString:self.senderId]) {
            return nil;
        }
        
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [self.messageData objectAtIndex:indexPath.item - 1];
            if ([[previousMessage senderId] isEqualToString:message.senderId]) {
                return nil;
            }
        }
        
        /**
         *  Don't specify attributes to use the defaults.
         */
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else
        return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messageData objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath   *)indexPath
{
    return nil;
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
    JSQMessagesBubbleImage *outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    JSQMessagesBubbleImage *incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    JSQMessage *message = self.messageData[indexPath.item];
    
    
    
    //TODO: add this
    if ([message.senderId isEqualToString:self.userName])
        
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
    JSQMessagesAvatarImage *placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];
    
    
    if(self.isGroupChat) //group converstaion logic
    {
        
        JSQMessage *message = self.messageData[indexPath.item];
        
        if(self.avatars[message.senderDisplayName] == nil)
        {
            
            PFQuery *query = [Profile query];
            NSString *yourString = message.senderDisplayName;
            yourString = [yourString lowercaseString];
            
            NSArray *values = [yourString componentsSeparatedByCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
            
            // Remove the empty strings.
            values = [values filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            //        yourString = [yourString stringByReplacingOccurrencesOfString:@" " withString:@""];
            [query whereKey:@"canonicalFirstName" equalTo:values[0]];
            [query whereKey:@"canonicalLastName" equalTo:values[1]];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"in loop");
                Profile *profile = objects.firstObject;
                NSString *nameString = [NSString stringWithFormat:@"%@ %@",profile.firstName, profile.lastName];

                if(profile.avatarData != nil)
                {
                    
                    self.avatars[nameString] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:profile.avatarData] diameter:30.0];
                    
                    [self.collectionView reloadData];
                }
                
                else
                
                {
                    self.avatars[nameString] = placeholderImageData;
                }
            }];
        }
        else
            return self.avatars[message.senderDisplayName];
    }
    else
        return placeholderImageData;
    //    PFUser *user = users[indexPath.item];
    //    if (avatars[user.objectId] == nil)
    //    {
    //        PFFile *fileThumbnail = user[PF_USER_THUMBNAIL];
    //        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
    //         {
    //             if (error == nil)
    //             {
    //                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
    //                 [self.collectionView reloadData];
    //             }
    //         }];
    //        return placeholderImageData;
    //    }
    //    else return avatars[user.objectId];
    
    return placeholderImageData;
    //    return nil;
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
    
    
    if ([message.senderId isEqualToString:self.userName]){
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        cell.textView.textColor = [UIColor blackColor];
    }
    //
    //        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
    //                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    //    }
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if(self.isGroupChat) //group converstaion logic
        
    {
        JSQMessage *message = self.messageData[indexPath.item];
        if ([message.senderId isEqualToString:self.userName])
        {
            return 0.0f;
        }
        
        if (indexPath.item - 1 > 0)
        {
            JSQMessage *previousMessage = self.messageData[indexPath.item-1];
            if ([previousMessage.senderId isEqualToString:message.senderId])
            {
                return 0.0f;
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else
        return 0.0f;
}



//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 0.0f;
}







@end
