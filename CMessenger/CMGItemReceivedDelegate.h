//
//  CMGItemReceivedDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 3/9/12.
//  Copyright (c) 2012 ITB. All rights reserved.
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
