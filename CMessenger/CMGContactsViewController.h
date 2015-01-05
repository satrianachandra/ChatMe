//
//  CMGContactsViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import "CMGAddBuddyViewController.h"
#import <AddressBook/AddressBook.h>
#import "CMGStatusChangeDelegate.h"

@class CMGAppDelegate;
@class CMGUserDataController;
@interface CMGContactsViewController : UITableViewController <NSFetchedResultsControllerDelegate>{
    
    NSFetchedResultsController *fetchedResultsController;
    //NSFetchedResultsController *fetchedResultsControllerFav;
    dispatch_queue_t backgroundQueue;
}
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;
@property (strong,nonatomic)NSMutableArray *addressBookArray;
@property (strong,nonatomic)NSMutableArray *favoriteArray;
@property (assign, nonatomic)dispatch_queue_t backgroundQueue;

//@property (nonatomic, retain) CMGAddBuddyViewController *addBuddyController;
//@property (assign,nonatomic) ABAddressBookRef addressBook; 

@property (nonatomic, assign) id  _statusChangeDelegate; 

- (IBAction)addBuddy:(id)sender;

-(NSString *)getNameByNumber:(NSString *)number;
-(NSData *)getPhotoByNumber:(NSString *)number;

- (CMGAppDelegate *)appDelegate;

-(void)sendPresenceSubscriptionToContacts;
-(void)addUser:(NSString *)theNumber;
-(void)fillAddressBookArray;

+ (CMGContactsViewController *)sharedInstance;


void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          );

 
@end
