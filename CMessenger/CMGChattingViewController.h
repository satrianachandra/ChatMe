//
//  CMGChattingViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import "CMGMessageDelegate.h"
#import <CoreData/CoreData.h>
#import "ChatWith.h"
#import "MessagesInfo.h"
#import "CMGMessageViewTableCell.h"
#import "TURNSocket.h"
#import "CMGItemReceivedDelegate.h"
#import "CMGMapItemViewController.h"
//#import "UIImagePickerController.h"

@interface CMGChattingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource ,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CMGItemReceivedDelegate,CLLocationManagerDelegate>{

    NSArray	*messages;
    //NSString *chatWithUser;
	NSMutableArray *turnSockets;
    NSArray *chatwithArray;
    NSManagedObjectContext *moc;
    
    //NSFetchedResultsController *fetchedResultsController;
    
}
@property (unsafe_unretained, nonatomic) IBOutlet UINavigationItem *navItem;


@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *messageField;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,retain) ChatWith *chatwith;
@property (nonatomic,retain) XMPPJID *chatwithJID;
@property (nonatomic,retain) NSData *theItem;



@property (unsafe_unretained, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;

- (id) initWithUser:(ChatWith *) chatwithto;
//- (id) initWithUserName:(NSString *)uname;
-(id) initWithUserName:(NSString *)uname andNIB:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


- (IBAction) sendMessage;
- (IBAction) closeChat;
- (IBAction)textFieldShouldReturn:(id)sender;
- (IBAction)backgroundTap:(id)sender;

-(IBAction) textFieldDidBeginEditing:(id)sender;

- (IBAction)sendItems:(id)sender;


@end
