//
//  CMGMessageDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#ifndef CMessenger_CMGMessageDelegate_h
#define CMessenger_CMGMessageDelegate_h



#endif
#import <UIKit/UIKit.h>


@protocol CMGMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;

@end
