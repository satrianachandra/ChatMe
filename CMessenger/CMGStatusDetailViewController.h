//
//  CMGStatusDetailViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 3/1/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "CMGAppDelegate.h"

@interface CMGStatusDetailViewController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,retain)Status* status;
@property (nonatomic,assign)BOOL current;

@property (nonatomic,retain)Status* currentStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *updateStatus;

- (IBAction)updateStatus:(id)sender;

@end
