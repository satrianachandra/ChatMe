//
//  CMGLoginViewControllerDelegate.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/23/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#ifndef CMessenger_CMGLoginViewControllerDelegate_h
#define CMessenger_CMGLoginViewControllerDelegate_h



#endif

#import <UIKit/UIKit.h>
@class CMGLoginViewController;   

@protocol CMGLoginViewControllerDelegate

- (void)loginViewControllerDidFinish:(CMGLoginViewController *)loginViewController;
@end