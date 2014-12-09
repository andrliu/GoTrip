//
//  GTMessage.h
//  GoTrip
//
//  Created by Jonathan Chou on 12/9/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "JSQMessage.h"

@interface GTMessage : JSQMessage <JSQMessageData>

@property (assign, nonatomic) NSString *profileId;

@end
