//
//  CMGAddBuddyProcessDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/21/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#ifndef CMessenger_CMGAddBuddyProcessDelegate_h
#define CMessenger_CMGAddBuddyProcessDelegate_h



#endif
#import <UIKit/UIKit.h>
#import "XMPPJID.h"


@protocol CMGAddBuddyProcessDelegate

- (void)addBuddyProcessWithJID:(XMPPJID *)thejid success:(BOOL)isSuccess;

@end
