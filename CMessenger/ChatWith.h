//
//  ChatWith.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatWith : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, assign) BOOL isactive;
@property (nonatomic, retain) NSSet *messages;
@end

@interface ChatWith (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
