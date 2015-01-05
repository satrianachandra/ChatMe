//
//  CMGItemReceivedDelegate.h
//  CMessenger
//
//  Created by Chandra Satriana on 3/9/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#ifndef CMessenger_CMGItemReceivedDelegate_h
#define CMessenger_CMGItemReceivedDelegate_h



#endif

#import <UIKit/UIKit.h>


@protocol CMGItemReceivedDelegate

@optional
- (void)itemReceived:(NSData *)theItem;
-(void)siAnsweredwithSID:(NSString *)theID;

@end
