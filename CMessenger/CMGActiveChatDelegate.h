//
//  CMGActiveChatDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/14/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#ifndef CMessenger_CMGActiveChatDelegate_h
#define CMessenger_CMGActiveChatDelegate_h



#endif

#import <UIKit/UIKit.h>


@protocol CMGActiveChatDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;
- (void)messageDelivered:(NSDictionary *)response;

@end
