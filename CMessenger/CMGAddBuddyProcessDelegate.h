//
//  CMGAddBuddyProcessDelegate.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/21/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#ifndef CMessenger_CMGAddBuddyProcessDelegate_h
#define CMessenger_CMGAddBuddyProcessDelegate_h



#endif
#import <UIKit/UIKit.h>
#import "XMPPJID.h"


@protocol CMGAddBuddyProcessDelegate

- (void)addBuddyProcessWithJID:(XMPPJID *)thejid success:(BOOL)isSuccess;

@end
