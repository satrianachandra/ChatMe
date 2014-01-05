//
//  CMGNewGroupChatViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 3/23/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSTokenField.h"

@interface CMGNewGroupChatViewController : UIViewController<JSTokenFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_toRecipients;
    //NSMutableArray *_ccRecipients;
    
    JSTokenField *_toField;
    //JSTokenField *_ccField;
}


@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *subjectField;

@property (strong,nonatomic)NSMutableArray *contacts;
@property (strong,nonatomic)NSArray *searchResults;

- (IBAction)cancel:(id)sender;
- (IBAction)newRoom:(id)sender;

@end
