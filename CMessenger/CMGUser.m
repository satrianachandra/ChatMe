//
//  CMGUser.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGUser.h"

@implementation CMGUser

@synthesize name=_name;
@synthesize status= _status;


-(id)initWithName:(NSString *)name status:(NSString *)status{
    self = [super init];
    if (self){
        _name = name;
        _status = status;
        return self;
    }

    return nil;
}
    
@end
