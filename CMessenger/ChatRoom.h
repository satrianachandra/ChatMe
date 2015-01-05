//
//  ChatRoom.h
//  CMessenger
//
//  Created by Chandra Satriana on 4/4/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatRoom : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * invited;
@property (nonatomic, retain) NSString * subject;

@end
