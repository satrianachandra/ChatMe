//
//  MessagesInfo.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "MessagesInfo.h"
#import "ChatWith.h"


@implementation MessagesInfo

@dynamic message;
@dynamic from;
@dynamic to;
@dynamic chatwith;
@dynamic date;
@dynamic item;
@dynamic idMess;
@dynamic latitude;
@dynamic longitude;
@dynamic isLocation;
@dynamic delivered;


- (BOOL) deliveredScalar {
    return self.delivered.boolValue;
}

- (void) setDeliveredScalar:(BOOL)deli {
    self.delivered = [NSNumber numberWithBool:deli];
}

- (BOOL) isLocationScalar {
    return self.isLocation.boolValue;
}

- (void) setIsLocationScalar:(BOOL)deli {
    self.isLocation = [NSNumber numberWithBool:deli];
}

- (double) latitudeScalar{
    return self.latitude.doubleValue;
}
- (void) setLatitudeScalar:(double)deli{
    self.latitude = [NSNumber numberWithDouble:deli];
}

- (double) longitudeScalar{
    return self.longitude.doubleValue;
}
- (void) setLongitudeScalar:(double)deli{
    self.longitude = [NSNumber numberWithDouble:deli];
}


@end
