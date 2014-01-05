//
//  CMGUserDataController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMGUser;
@interface CMGUserDataController : NSObject

@property (nonatomic, copy) NSMutableArray *userList;

- (unsigned)countOfUserList;

- (CMGUser *)objectInUserListAtIndex:(NSUInteger)index;

- (void)addUserListWithName:(NSString *)inputUserName status:(NSString *)inputStatus;

@end
