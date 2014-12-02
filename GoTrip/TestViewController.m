//
//  TestViewController.m
//  GoTrip
//
//  Created by Jonathan Chou on 12/1/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "TestViewController.h"
#import "JSQMessage.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "UIColor+JSQMessages.h"


@interface TestViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout>

@end

@implementation TestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
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
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Jon" senderDisplayName:@"Jon" date:[NSDate date] text:@"hihihihihi"];
    return message;
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
    
    return outgoingBubbleImageData;
    
    
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
    return 2;
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
    //    if (!msg.isMediaMessage) {
    //
    //        if ([msg.senderId isEqualToString:self.senderId]) {
    //            cell.textView.textColor = [UIColor blackColor];
    //        }
    //        else {
    //            cell.textView.textColor = [UIColor whiteColor];
    //        }
    //
    //        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
    //                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    //    }
    
    return cell;
}



@end
