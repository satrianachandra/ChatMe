//
//  CMGChattingViewGroupChatController.h
//  CMessenger
//
//  Created by Chandra Satriana on 4/18/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ChatWith.h"
#import "MessagesInfo.h"
#import "XMPPRoom.h"

@interface CMGChattingViewGroupChatController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic,retain) ChatWith *chatwith;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *messageField;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;
@property (nonatomic, retain) XMPPRoom *theXMPPRoom;


- (id) initWithUser:(ChatWith *) chatwithto;

- (IBAction)sendMessage:(id)sender;

- (IBAction)closeChat:(id)sender;

- (IBAction)textFieldShouldReturn:(id)sender;

@end
