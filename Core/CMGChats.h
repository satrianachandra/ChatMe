//
//  CMGChats.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/13/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <Foundation/Foundation.h>


@interface CMGChats : NSObject

@property (nonatomic,copy) NSString *chatWithUser;
@property (nonatomic,retain) NSMutableArray	*messages;

-(id)initWithUser:(NSString *)uname;
-(id)initWithUser:(NSString *)uname withMessage:(NSDictionary *)messageContent;
-(unsigned)countOfMessages;
-(void)addMessages:(NSMutableDictionary *)theMessage;


@end
