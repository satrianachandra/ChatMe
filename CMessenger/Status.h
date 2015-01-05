//
//  ThisUser.h
//  CMessenger
//
//  Created by Chandra Satriana on 3/1/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Status : NSManagedObject

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * show;
@property (nonatomic, retain ) NSString * inuse;

@end
