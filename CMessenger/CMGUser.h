//
//  CMGUser.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMGUser : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *status;
// @property ... picture of user 

-(id)initWithName:(NSString *)name status:(NSString *)status;

@end
