//
//  CMGAppDelegate.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGAppDelegate.h"
#import "CMGLoginViewController.h"
#import "CMGChattingViewController.h"
#import "ChatRoom.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPMessage+XEP_0184.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "XMPPCoreDataStorage.h"

#import <CFNetwork/CFNetwork.h>
#import <AudioToolbox/AudioToolbox.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface CMGAppDelegate()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end
XMPPJID *requestingJID;

@implementation CMGAppDelegate
@synthesize contactsViewController;
@synthesize favoritesViewController;
@synthesize chatsViewController;
//@synthesize favoriteViewController;


@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize turnSockets;
@synthesize chattingViewController;
@synthesize itemSender;

@synthesize xmppMuc;
@synthesize xmppRoomCoreDataStorage;
@synthesize xmppRoom;
@synthesize roomArray;

//@synthesize cmgChatsStorage;
//@synthesize multicastDelegate;

//@synthesize _chatDelegate;
@synthesize _messageDelegate;
@synthesize _activeChatDelegate;
@synthesize _addBuddyProcessDelegate;
@synthesize _userSearchDelegate;
@synthesize _itemReceivedDelegate;

@synthesize window = _window;
@synthesize rootController; 
//@synthesize contactsNavController;

//core data for messages
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


 
-(void)loginViewControllerDidFinish:(CMGLoginViewController *)loginViewController{
    [self.rootController dismissModalViewControllerAnimated:NO];
    [self.rootController setSelectedIndex:1];
    if (![self connect])
	{
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			
            //show login page if not logged in
            CMGLoginViewController *lvc = [[CMGLoginViewController alloc] initWithNibName:@"CMGLoginViewController" bundle:nil];
            lvc.delegate = self;
            [self.rootController presentModalViewController:lvc animated:NO];
            
		});
	}else{
       
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup the XMPP stream
	[self setupStream];

    //multicastDelegate = [[GCDMulticastDelegate alloc] init];
    
    //load the chats view
    
    
    //Setup the view
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [[NSBundle mainBundle] loadNibNamed:@"TabBarController" owner:self options:nil];
    [self.window addSubview:rootController.view];
    
    
    
    [self.window makeKeyAndVisible];
    
    //check if already logged in...
    if (![self connect])
	{
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			
            //show login page if not logged in
            CMGLoginViewController *lvc = [[CMGLoginViewController alloc] initWithNibName:@"CMGLoginViewController" bundle:nil];
            lvc.delegate = self;
            [self.rootController presentModalViewController:lvc animated:NO];
            
		});
	}
    //CMGChattingViewController *cvc = [[CMGChattingViewController alloc] initWithNibName:@"CMGChattingViewController" bundle:nil];
    //lvc.delegate = self;
   // [self.rootController presentModalViewController:cvc animated:NO];
    
    //[self.contactsViewController viewDidLoad];
    
    //load the Chats view, so the didload() method is called, TEMPORARY solution
    UIViewController *chatsView = [[[self rootController] viewControllers] objectAtIndex:2];
    [chatsView view];
    
    [self.chatsViewController viewDidLoad];
    self.roomArray = [[NSMutableArray alloc]init ];
    //move loading the contacts to CMGFavorites
    //load the Contacts view, so the didload() method is called, TEMPORARY solution
    ///UIViewController *contactsView = [[[self rootController] viewControllers] objectAtIndex:1];
    //[contactsView view];
    // this is magic;
    // it causes Apple to load the view,
    // run viewDidLoad etc,
    // for the other controller
    
    
    //setting up delegate for itemReceived
    _itemReceivedDelegate = [[GCDMulticastDelegate alloc]init];
    
    return YES;
}

- (void)dealloc
{
	[self teardownStream];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //[self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) 
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@
                       "kXMPPmyJID"];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyPassword"];
    
	//
	// If you don't want to use the Settings view to set the JID, 
	// uncomment the section below to hard code a JID and password.
	// 
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting" 
		                                                    message:@"See console for error details." 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream {
	
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	// 
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		// 
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	// 
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	// 
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
    //xmppRoster.allowRosterlessOperation = YES;
    
    //mimic "following" on twitter
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
	
    ///
    ///Setup chats core data
    //cmgChatsStorage = [[CMGChatsCoreDataStorageObject alloc] init];
    
    
    ///
    
    
	// Setup vCard support
	// 
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
    
    
    ///
    
    
    // Setup MUC
    xmppMuc = [[XMPPMUC alloc]init];//WithDispatchQueue:dispatch_get_main_queue()];
    xmppRoomCoreDataStorage = [[XMPPRoomCoreDataStorage alloc]init];
    //xmppRoom = [XMPPRoom alloc]initWithRoomStorage:<#(id<XMPPRoomStorage>)#> jid:<#(XMPPJID *)#>
    roomArray = [[NSMutableArray alloc]init];
    ////////
    
    
    
	// Setup capabilities
	// 
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	// 
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	// 
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
    [xmppMuc                activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMuc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	// 
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	// 
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	// 
	// If you don't specify a hostPort, then the default (5222) will be used.
	
	//[xmppStream setHostName:@"eueung-mulyanas-imac.local"];
    [xmppStream setHostName:@"167.205.64.96"];
    [xmppStream setHostPort:5222];	
	
    
	// You may need to alter these settings depending on the server you're connecting to
    
	allowSelfSignedCertificates = YES;
	allowSSLHostNameMismatch = YES;
    
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
    
    //removing delegate & deactivate of rooms
    for (XMPPRoom *room in self.roomArray){
        [room removeDelegate:self];
        [room deactivate];
        NSLog(@"room deactivated");
    }
    [xmppMuc removeDelegate:self];
    
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
    [xmppMuc                deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}


- (void)goOnline
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status"
                                              inManagedObjectContext:moc];
    
    //NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"inuse" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:moc
                                                                     sectionNameKeyPath:@"inuse"
                                                                              cacheName:nil];
    [frc performFetch:nil];
    NSArray *fo =[frc fetchedObjects];
    
    
    //XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	NSXMLElement *presence = [NSXMLElement 
                              elementWithName:@"presence"]; 
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"]; 
    NSXMLElement *status = [NSXMLElement 
                            elementWithName:@"status"]; 
    

    if ([fo count]>0){
        Status *stat = [[frc fetchedObjects]objectAtIndex:0];
        [show setStringValue:stat.show]; 
        [status setStringValue:stat.status]; 
        [presence addChild:show]; 
        [presence addChild:status]; 
        NSLog(@"statusnya: %@",stat.status);
    }else{
        [show setStringValue:@"chat"]; 
        [status setStringValue:@"Available"]; 
        [presence addChild:show]; 
        [presence addChild:status];
    }
        
	    //Query from core data, the user's current status
        
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *)managedObjectContext_roster
{
    
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_roster == nil)
	{
		managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_roster;
    
    //return [xmppRosterStorage mainThreadManagedObjectContext];
     
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_capabilities == nil)
	{
		managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_capabilities;
}


-(NSManagedObjectContext *)managedObjectContext_muc
{
    NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");

    if(managedObjectContext_muc ==nil){
        managedObjectContext_muc = [[NSManagedObjectContext alloc]init ];
        
        NSPersistentStoreCoordinator *psc = [xmppRoomCoreDataStorage persistentStoreCoordinator];
        [managedObjectContext_muc setPersistentStoreCoordinator:psc];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];

    }
        
    return managedObjectContext_muc;
}



- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
		});
    }
	
	if (sender != managedObjectContext_capabilities &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_capabilities", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
		});
	}
    
    if(sender != managedObjectContext_muc && [sender persistentStoreCoordinator]==[managedObjectContext_muc persistentStoreCoordinator])
    {
        DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_muc", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_muc mergeChangesFromContextDidSaveNotification:notification];
		});
    }
    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    
    if(!(self.contactsViewController.backgroundQueue)){
        self.contactsViewController.backgroundQueue = dispatch_queue_create("com.chan.chatme.bgqueue2", NULL); 
    }
    dispatch_async(self.contactsViewController.backgroundQueue, ^(void){
        [self.contactsViewController sendPresenceSubscriptionToContacts];
    });
    //[self.contactsViewController sendPresenceSubscriptionToContacts];
    
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

NSInteger itemLength;


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	
    ////
    //check is as answer from SI
    /*
     RECV: 
     <iq xmlns="jabber:client" 
     id="E02D7826-9A67-4ED3-80A2-FCE06FF6F594" 
     to="6285659237025@eueung-mulyanas-imac.local/5f576fff" 
     from="6285656234506@eueung-mulyanas-imac.local/Spark 2.6.3" 
     type="result">
     <si xmlns="http://jabber.org/protocol/si">
     <feature xmlns="http://jabber.org/protocol/feature-neg">
     <x xmlns="jabber:x:data" 
     type="submit">
     <field var="stream-method">
     <value>http://jabber.org/protocol/bytestreams</value>
     </field>
     </x>
     </feature>
     </si>
     </iq>
     */
    //after receiving above message from the SI reply, then we initiate turn connection to the target
    //check if iq contain SI with iq type result
    NSXMLElement *si = [iq elementForName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    if ((si) && [iq isResultIQ]){
        //call delegate method on CMGChatting to initiate turn
        [_itemReceivedDelegate siAnsweredwithSID:[iq elementID]];
        NSLog(@"iq element id:%@",[iq elementID]);
    }else if((si)&&[iq isSetIQ]){
        /*
         <iq xmlns="jabber:client" 
            type="result" 
            id="9C790A78-4441-43FB-B5FE-2CDA124225E7" 
            to="6285659237025@eueung-mulyanas-imac.local/592d144c" 
            from="6285659237023@eueung-mulyanas-imac.local/Coccinella@wien">
            <si xmlns="http://jabber.org/protocol/si" 
            id="9C790A78-4441-43FB-B5FE-2CDA124225E7">
             <feature xmlns="http://jabber.org/protocol/feature-neg">
                <x xmlns="jabber:x:data" type="submit">
                    <field var="stream-method"><value>http://jabber.org/protocol/bytestreams</value>
                    </field>
                </x>
             </feature>
            </si>
         </iq>
         */
        ///
        NSXMLElement *siResult = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
        [siResult addAttributeWithName:@"id" stringValue:[si attributeStringValueForName:@"id"]];
        NSLog(@"sid: %@",[si attributeStringValueForName:@"id"]);

        //[si addAttributeWithName:@"mime-type" stringValue:theMime];
        //[si addAttributeWithName:@"profile" stringValue:@"http://jabber.org/protocol/si/profile/file-transfer"];
        
        //NSXMLElement *file = [NSXMLElement elementWithName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
        //[file addAttributeWithName:@"name" stringValue:theFileName ];
        //[file addAttributeWithName:@"size" stringValue:theFileSize];
        
        NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
        
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
        [x addAttributeWithName:@"type" stringValue:@"submit"];
        
        NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
        [field addAttributeWithName:@"var" stringValue:@"stream-method"];
        [field addAttributeWithName:@"type" stringValue:@"list-single"];
        
        //NSXMLElement *option1 = [NSXMLElement elementWithName:@"option"];
        NSXMLElement *value1 = [NSXMLElement elementWithName:@"value"];
        [value1 addChild:[DDXMLNode textWithStringValue:@"http://jabber.org/protocol/bytestreams"]];
        
        [field addChild:value1];
        //[field addChild:option1];
        [x addChild:field];
        [feature addChild:x];
        
        //[si addChild:file];
        [siResult addChild:feature];
        
        //for testing purpose, send item to self
        XMPPIQ *iqResult= [XMPPIQ iqWithType:@"result" to:[iq from] elementID:[iq elementID] child:siResult];
        //XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[self appDelegate].xmppStream.myJID elementID:theID child:si];
        [[self xmppStream] sendElement:iqResult];

        //get file size,name,desc,..
        NSXMLElement *file = [si elementForName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
        itemLength = [file attributeIntegerValueForName:@"size"];
        self.itemSender = [[iq from]bare];
        NSLog(@"sender: %@",sender);
        NSLog(@"item length: %d",itemLength);
        ///
    }
    
    
    
    
    
    if ([TURNSocket isNewStartTURNRequest:iq]) { 
        NSLog(@"IS NEW TURN request.."); 
        TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] incomingTURNRequest:iq]; 
        if (self.turnSockets == nil){
            self.turnSockets = [[NSMutableArray alloc]init];
        }
        [[self turnSockets] addObject:turnSocket]; 
        [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()]; 
                
    } 
    
     
    //return  YES;
    //check if the iq is related with user search, by checking is iq result and is xmlns of query == jabber:iq:search 
    if ([iq isResultIQ]){
        NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:search"];
        if (query != nil)
        {
            
        
        DDXMLNode *x = [query childAtIndex:0];
        if ([x childCount]>2){
            DDXMLNode *item = [x childAtIndex:2];
            DDXMLNode *field = [item childAtIndex:3];
            DDXMLNode *value = [field childAtIndex:0];
            //NSString *jidString = value
            //NSLog(@"string value: |%@|",[value stringValue]);
            [self.xmppRoster addUser:[XMPPJID jidWithString:value.stringValue] withNickname:nil];
        }
        }
    }
    
    //if ([iq isErrorIQ]){
    //    [xmppRoster removeUser:[iq from]];
    //}
    
        
    return YES; 
    
    
	//return NO;
}

////
///turn socket delegate
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
	
	NSLog(@"TURN Connection succeeded as Target!");
	NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    [socket readDataToLength:itemLength withTimeout:-1 tag:2];
    [socket setDelegate:self];
    NSLog(@"length:%d",itemLength);
    //read data
    // tag 0 is header
    //[socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    //[[self turnSockets]removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
	
	NSLog(@"TURN Connection as Target, failed!");
	//[turnSockets removeObject:sender];
	[[self turnSockets] removeObject:sender];
}

////


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    /*
    NSString *itemLength;
    if (tag==0){    //header received
        NSData *headerData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
		itemLength= [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
        [sock readDataToLength:[itemLength integerValue] withTimeout:-1 tag:1];
        
    }else if(tag == 1){
        //[_itemReceivedDelegate itemReceived:data];
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:data forKey:@"item"];
        [m setObject:@"" forKey:@"msg"];
        [m setObject:@"" forKey:@"sender"];
        [self._activeChatDelegate newMessageReceived:m];
        
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    }
    */
    if (tag == 2){
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:@""forKey:@"msg"];
        [m setObject:self.itemSender forKey:@"sender"];
        [m setObject:data forKey:@"item"];
        [self._activeChatDelegate newMessageReceived:m];
        NSLog(@"data diterima: length =%d",[data length]);
        //set badge on chats tab and play sound notif & vibrate
        
        // Get the main bundle for the app
        CFBundleRef mainBundle = CFBundleGetMainBundle ();
        
        SystemSoundID soundFileObject;
        
        // Get the URL to the sound file to play. The file in this case
        // is "NewMessage.wav"
        CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (
                                                             mainBundle,
                                                             CFSTR ("NewMessage"),
                                                             CFSTR ("wav"),
                                                             NULL
                                                             );
        
        // Create a system sound object representing the sound file
        AudioServicesCreateSystemSoundID (
                                          soundFileURLRef,
                                          &soundFileObject
                                          );
        
        AudioServicesPlaySystemSound(soundFileObject);
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
        CFRelease(soundFileURLRef);
        if (!([self.chatsViewController isBeingPresented])){
            NSInteger badgeVal = [self.chatsViewController.navigationController.tabBarItem.badgeValue integerValue];
            NSLog(@"badVal awal: %d",badgeVal);
            badgeVal++;
            self.chatsViewController.navigationController.tabBarItem.badgeValue= [NSString stringWithFormat:@"%d",badgeVal];
        }
    }
    
     
}

///////
- (void)addDelegate:(id)delegate
{
    [_itemReceivedDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)delegate
{
    [_itemReceivedDelegate removeDelegate:delegate];
}





//////////

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"message fromStr: %@",[message fromStr]);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody] || [message isLocationMessage])
	{
        //check if contain receipt request
        if ([message hasReceiptRequest]){
            [[self xmppStream]sendElement:[message generateReceiptResponse]];
        }
        
        
        
        //below is a simple function to query the xmppRosterStorage for a user with certain jid
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
        //send this body&displayName to CMGMessageDelegate
        
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
            //we are active, display directly the CMGChattingViewController
            NSString *msg =[body copy];
            //NSString *from = [[[user jid]full]copy];
            NSString *from = [[user  jidStr]copy];
            NSLog(@"message from: %@",from);
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:[msg substituteEmoticons] forKey:@"msg"];
            [m setObject:from forKey:@"sender"];
            if ([message isLocationMessage]){
                [m setObject:@"YES" forKey:@"isLocationInfo"];
            }
            
            //[m setObject:@"" forKey:@"item"];
            //[self._messageDelegate newMessageReceived:m];
            
            
            [self._activeChatDelegate newMessageReceived:m];
            
            //just a log
            //NSLog(@"last message: %@",[[user chats] lastMessageDuringChatWithUser:from]);
            
            
            //NSLog(@"msg from user core data: %@",[user chats])
                        /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Ok" 
                                                      otherButtonTitles:nil];
			[alertView show];
             */
            
            //set badge on chats tab and play sound notif & vibrate
            
            // Get the main bundle for the app
            CFBundleRef mainBundle = CFBundleGetMainBundle ();
            
            SystemSoundID soundFileObject;
            
            // Get the URL to the sound file to play. The file in this case
            // is "NewMessage.wav"
            CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (
                                                        mainBundle,
                                                        CFSTR ("NewMessage"),
                                                        CFSTR ("wav"),
                                                        NULL
                                                        );
            
            // Create a system sound object representing the sound file
            AudioServicesCreateSystemSoundID (
                                              soundFileURLRef,
                                              &soundFileObject
                                              );
            
            AudioServicesPlaySystemSound(soundFileObject);
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            
            CFRelease(soundFileURLRef);
            if (self.chatsViewController.isAppearing == NO){
                NSInteger badgeVal = [self.chatsViewController.navigationController.tabBarItem.badgeValue integerValue];
                NSLog(@"badVal awal: %d",badgeVal);
                badgeVal++;
                self.chatsViewController.navigationController.tabBarItem.badgeValue= [NSString stringWithFormat:@"%d",badgeVal];
            }
            
            
        }
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	//}else if ([message isLocationMessage]){
        
    
    }else{
        //check if contain receipt response, if does then update the corresponding message on MessagesInfo entity
        if ([message hasReceiptResponse]){
            NSString *idDeliveryNotification = [message extractReceiptResponseID];
            
            //find ChatWith where chatwith.name == message from jidstr
            //NSManagedObjectContext *moc = [self managedObjectContext];
            
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:idDeliveryNotification forKey:@"id"];
            [m setObject:[message fromStr] forKey:@"sender"];
            [self._activeChatDelegate messageDelivered:m];
            
        }    
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    /*
	if([presence isErrorPresence]){
        [xmppRoster removeUser:[presence from]];
        [[self _addBuddyProcessDelegate] addBuddyProcessWithJID:[presence from] success:NO];
    }*/
    
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    NSLog(@"show: %@",[presence type]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        NSLog(@"xmpp.hostname: %@",self.xmppStream.hostName);
	}
}
     
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
        {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
    /*        
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
     requestingJID = [presence from];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body 
		                                                   delegate:self 
		                                          cancelButtonTitle:@"Ignore"
                                                  otherButtonTitles:@"Accept",nil];
		[alertView show];
	} 
	else 
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	*/
}


//responding to alert view 
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1){
        [xmppRoster acceptPresenceSubscriptionRequestFrom:requestingJID andAddToRoster:YES];

    }
}
*/


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

////////////
//Core Data stuff
////////////
#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    /*
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CMessenger" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
     */
     if (__managedObjectModel != nil)
     {
     return __managedObjectModel;
     }
     __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
     
     return __managedObjectModel;

}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CMessenger.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


///////////////

-(void)newRoomWithName:(NSString *)theName{
    NSString *myNumber =  self.xmppStream.myJID.user;
    NSString *serviceName = @"conference.eueung-mulyanas-imac.local";
    
    XMPPJID *theRoomJID = [XMPPJID jidWithUser:theName domain:serviceName resource:myNumber];
    //self.xmppRoom = [[XMPPRoom alloc]initWithRoomStorage:self.xmppRoomCoreDataStorage jid:theRoomJID];
    NSLog(@"thesub; %@",theName);
    XMPPRoom *theRoom = [[XMPPRoom alloc]initWithRoomStorage:self.xmppRoomCoreDataStorage jid:theRoomJID];
    //theRoom.roomSubject = @""
    NSLog(@"the room user: %@",[[theRoom roomJID] description]);
    //theRoom = [[XMPPRoom alloc]initWithRoomStorage:[self appDelegate].xmppRoomCoreDataStorage jid:theRoomJID];

    
    [self.roomArray addObject:theRoom];
    [[self.roomArray lastObject] activate:self.xmppStream];
    [[self.roomArray lastObject] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self.roomArray lastObject] joinRoomUsingNickname:myNumber history:nil];
    //[self.roomArray addObject:theRoom];
    
}



////////////
/// delegate MUC
- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"the Room is created");
    [sender configureRoomUsingOptions:nil];

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    NSLog(@"room configuration fetched");
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    NSLog(@"room configured");
    
    //set room subject
    
    
    //after room configured, add new entry on CMGChats
    ////
    // but first check if it's already on ChatWith entity
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error;
   
    
    NSEntityDescription *entitySearch = [NSEntityDescription entityForName:@"ChatWith" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequestSearch = [[NSFetchRequest alloc] init];
    [fetchRequestSearch setEntity:entitySearch];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name contains [cd] %@",sender.roomJID.user];
    [fetchRequestSearch setPredicate:pred];
    NSArray *fetchedObjectsSearch = [moc executeFetchRequest:fetchRequestSearch error:&error];
    if ([fetchedObjectsSearch count]<1){
        //not yet on ChatWith entity
               
        MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
        themessage.message =@"subject";
        themessage.from = [sender roomJID].full;
        themessage.to = @"groupchat";
        themessage.date = [NSDate date];
    
        ChatWith *chatwith2 = (ChatWith *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatWith" inManagedObjectContext:moc];
        chatwith2.name = [NSString stringWithFormat:@"groupchat|%@",[sender roomJID].full];
        //chatwith2.isactive =YES;
        [chatwith2 addMessagesObject:themessage];
    
        
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }
    
    
    ////////////////////////////////
    
    
    //after room configured, invite friends from the ChatRoom entity where ChatRoom.name isequalto room jid.user
    
    //do a fetch with predicate
    NSString *roomName = sender.roomJID.user;
    //NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatRoom" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name = %@", roomName];
    [fetchRequest setPredicate:predicate];
    
    //NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]>0){
        ChatRoom *cr = [fetchedObjects objectAtIndex:0];
        if (cr.invited){
            NSArray *tobeInvited = [cr.invited componentsSeparatedByString:@"|"];
            for (int i=0;i<([tobeInvited count]-1);i++){
                XMPPJID *tobeInvitedJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@eueung-mulyanas-imac.local",[tobeInvited objectAtIndex:i]]];
                [sender inviteUser:tobeInvitedJID withMessage:[NSString stringWithFormat:cr.subject]];
            }
        }
    }
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"I joined the room");
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"I leave the room");
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{

}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    //show message "Occupant enter the room"
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    NSLog(@"message from %@ , of room subject %@",[occupantJID description], [sender roomSubject]);
    
    
}


///////////

////////
/// XMPPMuc delegate methods
- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message{
    NSLog(@"did receive room invitation");
    
    NSString *roomName = message.from.user;
    
    //show dialog box to accept/no the invitation
    //
    NSXMLElement *x = [message elementForName:@"x"];
    NSXMLElement *invite = [x elementForName:@"invite"];
    NSString *inviter  = [invite attributeStringValueForName:@"from"];
    
    NSXMLElement *reason = [invite elementForName:@"reason"];
    NSString *subject = [reason stringValue];
    NSString *body= [NSString stringWithFormat:@"%@ invites you to talk about %@",inviter,subject];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Groupchat Invitation"
		                                                    message:body 
		                                                   delegate:self 
		                                          cancelButtonTitle:@"Deny"
                                                  otherButtonTitles:@"Accept",nil];
		[alertView show];
        alertView.title = roomName;
	} 
	else 
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
    //
    
}

//responding to alert view 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1){
        //join room
        [self newRoomWithName:alertView.title];
       
        //add room data to ChatRoom entity
        NSManagedObjectContext *moc = [self managedObjectContext];
        ChatRoom *chatRoom = (ChatRoom *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatRoom" inManagedObjectContext:moc];
        chatRoom.name = alertView.title; 
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }

        //create new entry CMGChatsView
        //
        //NSManagedObjectContext *moc = [self managedObjectContext];
        MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
        themessage.message =@"subject";
        
        NSString *myNumber =  self.xmppStream.myJID.user;
        NSString *serviceName = @"conference.eueung-mulyanas-imac.local";
        
        XMPPJID *theRoomJID = [XMPPJID jidWithUser:alertView.title domain:serviceName resource:myNumber];
        
        themessage.from = theRoomJID.full;
        themessage.to = @"groupchat";
        themessage.date = [NSDate date];
        
        ChatWith *chatwith2 = (ChatWith *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatWith" inManagedObjectContext:moc];
        chatwith2.name = [NSString stringWithFormat:@"groupchat|%@",theRoomJID.full];
        chatwith2.isactive =YES;
        [chatwith2 addMessagesObject:themessage];
        
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
                
        ////////////////////////////////
        
    }
}

- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitationDecline:(XMPPMessage *)message{

}
////////

@end
