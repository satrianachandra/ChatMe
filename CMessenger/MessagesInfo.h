//
//  MessagesInfo.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatWith;

@interface MessagesInfo : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * item;
@property (nonatomic) NSNumber* latitude;
@property (nonatomic) NSNumber* longitude;
@property (nonatomic) NSNumber* isLocation;
//@property (nonatomic, assign) BOOL primitiveIsLocation;

@property (nonatomic, retain) ChatWith *chatwith;
@property (nonatomic) NSNumber* delivered;
//@property (nonatomic, assign) BOOL primitiveDelivered;
@property (nonatomic, retain) NSString * idMess;

- (BOOL) isLocationScalar;
- (void) setIsLocationScalar:(BOOL)deli;

- (BOOL) deliveredScalar;
- (void) setDeliveredScalar:(BOOL)deli;

- (double) latitudeScalar;
- (void) setLatitudeScalar:(double)deli;

- (double) longitudeScalar;
- (void) setLongitudeScalar:(double)deli;

@end
