//
//  CMGMessageDelegate.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/11/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#ifndef CMessenger_CMGMessageDelegate_h
#define CMessenger_CMGMessageDelegate_h



#endif
#import <UIKit/UIKit.h>


@protocol CMGMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;

@end
