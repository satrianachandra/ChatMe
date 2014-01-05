//
//  CMGContactDetailsViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/29/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMGAppDelegate.h"
#import "Favorite.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "SVProgressHUD.h"

@interface CMGContactDetailsViewController : UITableViewController <MFMessageComposeViewControllerDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;
//@property(retain,nonatomic)NSDictionary *contactDictionary;


@property (nonatomic,copy) NSString *mobileStatus;
@property (nonatomic,copy) NSString *iphoneStatus;
@property (nonatomic,copy) NSString *mobileNumber;
@property (nonatomic,copy) NSString *iphoneNumber;
@property (nonatomic,copy) NSString *name;
@property (nonatomic, copy)NSData *photo;

@end
