//
//  CMGFavoritesViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/22/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CMGStatusChangeDelegate.h"
#import "CMGContactDetailsViewController.h"

@interface CMGFavoritesViewController : UIViewController<ABNewPersonViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>{
    //UIBarButtonItem *addContactButton;
   // NSFetchedResultsController *fetchedResultsController;
       dispatch_queue_t backgroundQueue;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;

@property (strong,nonatomic)NSMutableArray *contacts;

@property (strong,nonatomic)NSArray *searchResults;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain) NSOperationQueue *queue;

- (IBAction)broadcastMessage:(id)sender;

- (IBAction)groupChat:(id)sender;


-(NSString *)getStatusInUserCoreData:(NSString *)phoneNumber;
-(void)contactListArray;
-(void)addContact;

@end
