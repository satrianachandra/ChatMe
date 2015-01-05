//
//  CMGUserDataController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <Foundation/Foundation.h>

@class CMGUser;
@interface CMGUserDataController : NSObject

@property (nonatomic, copy) NSMutableArray *userList;

- (unsigned)countOfUserList;

- (CMGUser *)objectInUserListAtIndex:(NSUInteger)index;

- (void)addUserListWithName:(NSString *)inputUserName status:(NSString *)inputStatus;

@end
