//
//  CMGBroadcastMessageViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 5/16/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import "JSTokenField.h"

@interface CMGBroadcastMessageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,JSTokenFieldDelegate>{
    NSMutableArray *_toRecipients;
    //NSMutableArray *_ccRecipients;
    
    JSTokenField *_toField;
    //JSTokenField *_ccField;
}
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *messageField;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;

@property (strong,nonatomic)NSMutableArray *contacts;
@property (strong,nonatomic)NSArray *searchResults;

- (IBAction)sendMessage:(id)sender;
- (IBAction)cancel:(id)sender;

@end
