//
//  CMGAppDelegate.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


#import "XMPPFramework.h"
#import "CMGLoginViewController.h"
#import "CMGMessageDelegate.h"
#import "CMGActiveChatDelegate.h"
#import "CMGChatsToChattingDelegate.h"
#import "CMGChattingViewController.h"
#import "CMGContactsViewController.h"
#import "CMGAddBuddyViewController.h"
#import "CMGChatsViewController.h"
#import "CMGAddBuddyProcessDelegate.h"
#import "CMGLoginViewControllerDelegate.h"
#import "CMGFavoritesViewController.h"
#import "CMGAddUserDelegate.h"
#import "CMGItemReceivedDelegate.h"
#import "Status.h"
//#import "GCDMulticastDelegate.h"

#import "MessagesInfo.h"
#import "ChatWith.h"


//#import "SMChatDelegate.h"
//#import "SMMessageDelegate.h"
@class CMGLoginViewController;
@class CMGFavoritesViewController;
@class CMGChatsViewController;
//@protocol CMGChatDelegate;


@interface CMGAppDelegate : UIResponder <UIApplicationDelegate, CMGLoginViewControllerDelegate,XMPPRosterDelegate,UIAlertViewDelegate>
{
    
    __strong XMPPStream *xmppStream;
	__strong XMPPReconnect *xmppReconnect;
    __strong XMPPRoster *xmppRoster;
	 //XMPPRosterCoreDataStorage *xmppRosterStorage;
    __strong XMPPvCardCoreDataStorage *xmppvCardStorage;
	__strong XMPPvCardTempModule *xmppvCardTempModule;
	__strong XMPPvCardAvatarModule *xmppvCardAvatarModule;
	__strong XMPPCapabilities *xmppCapabilities;
	__strong XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    __strong XMPPMUC *xmppMuc;
    __strong XMPPRoom *xmppRoom;
    __strong XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;
    __strong NSMutableArray *roomArray;
	
    
    //__strong CMGChatsCoreDataStorageObject *cmgChatsStorage;
    
    
	NSManagedObjectContext *managedObjectContext_roster;
	NSManagedObjectContext *managedObjectContext_capabilities;
    NSManagedObjectContext *managedObjectContext_muc;
   // NSManagedObjectContext *managedObjectContext_chats;
    
	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
	

    
	
	   
    //__weak NSObject <SMChatDelegate> *_chatDelegate;
	//__weak NSObject <CMGMessageDelegate> *_messageDelegate;

}

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, readonly) XMPPMUC *xmppMuc;
@property (nonatomic, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong)NSMutableArray *roomArray;
@property (nonatomic, readonly) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;

//@property (nonatomic, readonly) CMGChatsCoreDataStorageObject *cmgChatsStorage;


//core data stuffs for chats
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//View Controllers Reference
//@property (weak, nonatomic) IBOutlet UINavigationController *favoriteViewController;
//@property (weak, nonatomic) IBOutlet CMGFavoritesViewController *favoritesViewController;
//@property (weak, nonatomic) IBOutlet CMGContactsViewController *contactsViewController;

@property (unsafe_unretained, nonatomic) IBOutlet CMGContactsViewController *contactsViewController;

@property (unsafe_unretained, nonatomic) IBOutlet CMGFavoritesViewController *favoritesViewController;

@property (unsafe_unretained, nonatomic) IBOutlet CMGChatsViewController *chatsViewController;


@property (nonatomic,strong) CMGChattingViewController *chattingViewController;

//Navigation Controller , Contacts tab
//@property (nonatomic,retain) CMGContactsNavigationController *contactsNavController;
//@property (nonatomic,retain) CMGContactsNavigationController *contactsNavController;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


//@property (nonatomic,assign) GCDMulticastDelegate *multicastDelegate;
//@property (weak,nonatomic) GCDMulticastDelegate <CMGChatDelegate> *chatdelegate;
//@property (strong,nonatomic) id <CMGMessageDelegate> *_messageDelegate;


@property (nonatomic, assign) id  _messageDelegate; 
@property (nonatomic, assign) id  _activeChatDelegate; 
@property (nonatomic, assign) id  _addBuddyProcessDelegate; 
@property (nonatomic,assign) id _userSearchDelegate;
@property (nonatomic,retain) GCDMulticastDelegate <CMGItemReceivedDelegate> *_itemReceivedDelegate;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITabBarController *rootController;

@property (strong,nonatomic)NSMutableArray *turnSockets;
@property (strong,nonatomic) NSString *itemSender;
//@property (strong,nonatomic)NSMutableArray *turnSockets;

//GCDMulticastDelegate

//@property (nonatomic, assign) id  _chatDelegate;  
//@property (nonatomic, assign) id  _messageDelegate; 

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
-(NSManagedObjectContext *)managedObjectContext_muc;
//- (NSManagedObjectContext *)managedObjectContext_chats;

- (BOOL)connect;
- (void)disconnect;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

-(void)newRoomWithName:(NSString *)theName;

@end


/*
@protocol CMGChatDelegate

-(void)newBuddyOnline:(NSString *)buddyName;


@end
*/
