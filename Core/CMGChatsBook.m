//
//  CMGChatsBook.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/14/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGChatsBook.h"

@implementation CMGChatsBook

@synthesize chatsbook=_chatsbook;



-(NSMutableArray *)exchangedMessageswith:(NSString *)uname{
    return nil;
}


-(void)addMessages:(NSMutableDictionary *)theMessage chatWith:(NSString *)chatWithUser{
    
    
    BOOL found = NO;
    for(CMGChats *chats in [self chatsbook]){
        if  ([[chats chatWithUser] caseInsensitiveCompare:chatWithUser]==NSOrderedSame){
            [chats addMessages:theMessage];
            found = YES;
        }
    }
    
        if (!found){
            CMGChats *toAdd = [[CMGChats alloc] initWithUser:chatWithUser withMessage:theMessage];
            if(toAdd){                
                [[self chatsbook] addObject:toAdd];
            }else{
                NSLog(@"tidak berhasil menambahkan data");
            }
        }
        
    
}

-(NSDictionary *)lastMessageReceivedFromUser:(NSString *)fromUser{
   //implement cuy..
    return nil;
}

-(NSDictionary *)lastMessageDuringChatWithUser:(NSString *)withUser{
    for(CMGChats *chats in _chatsbook){
        if  ([[chats chatWithUser] caseInsensitiveCompare:withUser]==NSOrderedSame){
            return [[chats messages] objectAtIndex:( [[chats messages] count] -1) ];
            
        }
    }
    return nil;
}

- (void)initializeDefaultDataList{
    NSMutableArray *chatsbook = [[NSMutableArray alloc] init];
    self.chatsbook = chatsbook;
    NSString *body = @"the body";
    NSString *thejid = @"thejid";
    
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:body forKey:@"msg"];
    [m setObject:thejid forKey:@"sender"];
    
    [self addMessages:m chatWith:thejid];
}

-(id)init{
    if (self = [super init]){
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}


-(unsigned)countOfChatsbook{
    return [[self chatsbook] count];
}

@end
