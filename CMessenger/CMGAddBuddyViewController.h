//
//  CMGAddBuddyViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/20/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import "CMGAppDelegate.h"

@interface CMGAddBuddyViewController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *buddyName;
@property (unsafe_unretained, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong,nonatomic) UIAlertView *alertView;


- (IBAction)addBuddy:(id)sender;
-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)backgroundTap:(id)sender;

@end
