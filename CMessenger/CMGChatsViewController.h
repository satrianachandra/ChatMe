//
//  CMGChatsViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMGAppDelegate.h"
#import "CMGActiveChatDelegate.h"
#import "NSString+Utils.h"

@interface CMGChatsViewController : UITableViewController<CMGActiveChatDelegate,NSFetchedResultsControllerDelegate>
{
    NSMutableArray	*activeChats;
    NSMutableArray *turnSockets;
    NSManagedObjectContext *moc;
    
    //
    //NSArray *fetchedObjects;
    NSArray *chatwithArray;
    //ChatWith *chatwith;
    NSFetchedResultsController *fetchedResultsController;
    
}

//@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;
@property (assign,nonatomic)BOOL isAppearing;

@property (nonatomic, assign) id  _chatsToChattingDelegate; 


- (CMGAppDelegate *)appDelegate;

@end
