//
//  CMGChatsBook.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/14/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMGChats.h"

@interface CMGChatsBook : NSObject
  
@property (nonatomic,retain) NSMutableArray *chatsbook;


-(void)addMessages:(NSMutableDictionary *)theMessage chatWith:(NSString *)chatWithUser;
-(NSDictionary *)lastMessageReceivedFromUser:(NSString *)fromUser;
-(NSDictionary *)lastMessageDuringChatWithUser:(NSString *)withUser;

-(unsigned)countOfChatsbook;

-(NSMutableArray *)exchangedMessageswith:(NSString *)uname;

@end
