//
//  ChatRoom.h
//  CMessenger
//
//  Created by Eueung Mulyana on 4/4/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatRoom : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * invited;
@property (nonatomic, retain) NSString * subject;

@end
