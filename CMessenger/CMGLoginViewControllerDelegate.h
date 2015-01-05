//
//  CMGLoginViewControllerDelegate.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/23/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#ifndef CMessenger_CMGLoginViewControllerDelegate_h
#define CMessenger_CMGLoginViewControllerDelegate_h



#endif

#import <UIKit/UIKit.h>
@class CMGLoginViewController;   

@protocol CMGLoginViewControllerDelegate

- (void)loginViewControllerDidFinish:(CMGLoginViewController *)loginViewController;
@end