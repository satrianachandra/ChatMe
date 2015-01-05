//
//  CMGUserDataController.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGUserDataController.h"
#import "CMGUser.h"



@interface CMGUserDataController()
- (void)initializeDefaultDataList;

@end



@implementation CMGUserDataController
@synthesize userList=_userList;

-(void)initializeDefaultDataList{
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    self.userList = userList;
    
    [self addUserListWithName:@"Username" status:@"Available"];
    
}

-(void)setUserList:(NSMutableArray *)userList{
    if (_userList != userList){
        _userList = [userList mutableCopy];
    }
}

-(id)init{
    
    if (self = [super init]){
        [self initializeDefaultDataList];
        return self;
    }
    
    return nil;
}

- (unsigned)countOfUserList{
    return [self.userList count];
}
- (CMGUser *)objectInUserListAtIndex:(unsigned)theIndex{
    return [self.userList objectAtIndex:theIndex];
}

- (void)addUserListWithName:(NSString *)inputUserName status:(NSString *)inputStatus{
    CMGUser *user;
    user = [[CMGUser alloc] initWithName:inputUserName status:inputStatus];
    [self.userList addObject:user];
}

@end