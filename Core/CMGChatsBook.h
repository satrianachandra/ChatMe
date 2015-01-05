//
//  CMGChatsBook.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/14/12.
//  Copyright (c) 2012 Chandra Satriana.
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
