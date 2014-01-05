//
//  Favorite.h
//  CMessenger
//
//  Created by Eueung Mulyana on 3/15/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;

@end
