//
//  CMGStatusDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#ifndef CMessenger_CMGStatusDelegate_h
#define CMessenger_CMGStatusDelegate_h



#endif

#import <UIKit/UIKit.h>


@protocol CMGStatusDelegate


- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;


@end
