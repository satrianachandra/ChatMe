//
//  CMGChats.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/13/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGChats.h"

@implementation CMGChats
@synthesize chatWithUser=_chatWithUser;
@synthesize messages = _messages;



-(id)initWithUser:(NSString *)uname withMessage:(NSMutableDictionary *)messageContent{
    self = [super init];
    if (self){
        self.chatWithUser = uname;
        self.messages = [[NSMutableArray alloc] init];
        
        [self.messages addObject:messageContent];
        return self;
    }
    return nil;
}

-(id)initWithUser:(NSString *)uname{
    return [self initWithUser:uname withMessage:nil];
}

-(unsigned)countOfMessages{
    return [self.messages count];
}

-(void)addMessages:(NSMutableDictionary *)theMessage{
    [[self messages] addObject:theMessage];
}




@end
