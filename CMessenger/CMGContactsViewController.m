//
//  CMGContactsViewController.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGContactsViewController.h"
#import "CMGLoginViewController.h"
#import "CMGUserDataController.h"
#import "CMGUser.h"
#import "CMGAppDelegate.h"
#import "Favorite.h"

#import "XMPPFramework.h"
#import "DDLog.h"

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation CMGContactsViewController

@synthesize tView;
@synthesize backgroundQueue;

//@synthesize addBuddyController;
//@synthesize addressBook;
@synthesize _statusChangeDelegate;
@synthesize addressBookArray;
@synthesize favoriteArray;

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[CMGContactsViewController sharedInstance] = self;
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

////////////////////////////////////////
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		//NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

-(NSString *)getStatusInUserCoreData:(NSString *)phoneNumber{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];  
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"jidStr contains[cd] %@", phoneNumber];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *hasil = [moc executeFetchRequest:fetchRequest error:&error];
    
    if ([hasil count]>0){
        XMPPUserCoreDataStorageObject *user = [hasil objectAtIndex:0];
       // if ([user.jidStr isEqualToString:phoneNumber]){
            NSString *show = user.primaryResource.show;
            NSString *status = user.primaryResource.status;
            NSString *type = user.primaryResource.presence.type ;
            
            //NSLog(@"type: %@",user.primaryResource.type);
            
            
            if ([show isEqualToString:@"chat"]){
                if (status != NULL){
                    return user.primaryResource.status;
                }else{
                    return @"Available";
                }
            }else if([show isEqualToString:@"xa"]){
                if (status != NULL){
                    return user.primaryResource.status;
                }else{
                    return @"Extended Away";
                }
            }else if([show isEqualToString:@"dnd"]){
                if (status != NULL){
                    return user.primaryResource.status;
                }else{
                    return @"Busy";
                }
            }else if([show isEqualToString:@"away"]){
                if (status != NULL){
                    return user.primaryResource.status;
                }else{
                    return @"Away";
                }
            }else if(![type isEqualToString:@"available"] ){
                return @"offline";
            }else if (status != NULL){
                return user.primaryResource.status;
            }else{
                return @"Available";
            }
       // }
    }
    
    
    /*
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"jidStr contains[cd] %@", phoneNumber];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        DDLogError(@"Error performing fetch: %@", error);
    }
    
    //NSError *error;
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    if ([fetchedObjects count]>0){
        XMPPUserCoreDataStorageObject *user = [fetchedObjects objectAtIndex:0];
        NSString *show = user.primaryResource.show;
        NSString *status = user.primaryResource.status;
        NSString *type = user.primaryResource.presence.type ;
        
        //NSLog(@"type: %@",user.primaryResource.type);
        
        
        if ([show isEqualToString:@"chat"]){
            if (status != NULL){
                return user.primaryResource.status;
            }else{
                return @"Available";
            }
        }else if([show isEqualToString:@"xa"]){
            if (status != NULL){
                return user.primaryResource.status;
            }else{
                return @"Extended Away";
            }
        }else if([show isEqualToString:@"dnd"]){
            if (status != NULL){
                return user.primaryResource.status;
            }else{
                return @"Busy";
            }
        }else if([show isEqualToString:@"away"]){
            if (status != NULL){
                return user.primaryResource.status;
            }else{
                return @"Away";
            }
        }else if(![type isEqualToString:@"available"] ){
            return @"offline";
        }else if (status != NULL){
            return user.primaryResource.status;
        }else{
            return @"Available";
        }
        
        
        
        
    }else{ //the user doesn't have cmessenger
        return nil;
    }
    */
    return nil;
}


/*
- (NSFetchedResultsController *)fetchedResultsControllerFav
{
	if (fetchedResultsControllerFav == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite"
		                                          inManagedObjectContext:moc];
		
		//NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		//[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsControllerFav = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:moc
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
		[fetchedResultsControllerFav setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsControllerFav performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsControllerFav;
}
 */



////////////////////////////////////////

//
-(void)eraseFavorites
{
    NSManagedObjectContext *moc = [[self appDelegate]managedObjectContext];
    NSFetchRequest * allFav = [[NSFetchRequest alloc] init];
    [allFav setEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:moc]];
    [allFav setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * favs = [moc executeFetchRequest:allFav error:&error];
    
    //error handling goes here
    for (NSManagedObject * fav in favs) {
        [moc deleteObject:fav];
    }
    NSError *saveError = nil;
    [moc save:&saveError];
}
//


//add all roster contacts to favorites
-(void)fillFavorites
{
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
    //NSInteger i;
    for(NSInteger i=0;i< [[[self fetchedResultsController]fetchedObjects]count];i++ ){
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        
		Favorite *fav = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
        fav.number = user.jidStr;
        fav.name = [self getNameByNumber:[user.jid user]];
        fav.status = [self getStatusInUserCoreData:[user jidStr]];
        fav.photo = [self getPhotoByNumber:[user.jid user]];
        
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
        
        
        
        
    }
}

-(void)fillFavoriteArray{
    self.favoriteArray = [[NSMutableArray alloc]init];
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite"
                                              inManagedObjectContext:moc];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    for (Favorite *fav in fetchedObjects){
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:fav.number forKey:@"number"];
        [m setObject:fav.name forKey:@"name"];
        if (fav.status){
        [m setObject:fav.status forKey:@"status"];
        }
        if(fav.photo) {
            [m setObject:fav.photo forKey:@"photo"];
        }
        [self.favoriteArray addObject:m];
    }
    
}


-(void)updateFavorites
{
    //update status of every contact on Favorite
    //iterate everyone on Favorite then find the user's status on XMPPUserCoreDataStorageObject where favorite.number == user.jidstr
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSLog(@"update favorites dipanggil");
   // NSPredicate *predicate =[NSPredicate predicateWithFormat:@"jidStr == %@", chatwith.name];
    //[fetchRequest setPredicate:predicate];

    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:Nil];
    for (Favorite *favorite in fetchedObjects) {
        //set status taken from XMPPusercoredata
        favorite.status = [self getStatusInUserCoreData:favorite.number];
        
        NSLog(@"status getStatus2: %@",favorite.status);
    }
    
    NSError *error;
    if (![moc save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

-(void)favDidSaveContent:(NSNotification*)saveNotification {
    //[self fillFavoriteArray];
    [self fillFavoriteArray];
    [self.tView reloadData];
    NSLog(@"masuk favDidSaveContent");
}
/////////////////////////////
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setTitle:@"Favorites"];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    if (![self.appDelegate connect])
	{
		//dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
		//dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //show login page if not logged in
        CMGLoginViewController *lvc = [[CMGLoginViewController alloc] initWithNibName:@"CMGLoginViewController" bundle:nil];
        lvc.delegate = self.appDelegate;
        [self.appDelegate.rootController presentModalViewController:lvc animated:NO];
        
		//});
	}
    // Do any additional setup after loading the view from its nib.
    [self fillAddressBookArray];
    //self.addressBook = ABAddressBookCreate( );
    //ABAddressBookRegisterExternalChangeCallback (self.addressBook,
      //                                           MyAddressBookExternalChangeCallback,
        //                                         nil
         //                                        );
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favDidSaveContent:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[self appDelegate]managedObjectContext]];
    
    
    if(!(backgroundQueue)){
        backgroundQueue = dispatch_queue_create("com.chan.chatme.bgqueue2", NULL); 
    }
    dispatch_async(backgroundQueue, ^(void){
        [self sendPresenceSubscriptionToContacts];
    });
    
    //[self sendPresenceSubscriptionToContacts];
    //[[[self appDelegate]rootController]setSelectedIndex:1];
    	
    //NSString *num = [self getNameByNumber:[user.jid user]];
       
    ////
    /*
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite"
                                              inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
        
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] <1){
          [self fillFavorites];
    }
    */
    [self fillFavoriteArray];
    [self fetchedResultsController];
}





- (void)viewDidUnload
{
    [self setTView:nil];
    
    
    [super viewDidUnload];
    //[[self appDelegate] disconnect];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.appDelegate connect];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[[self appDelegate] disconnect];
    
    //[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [super viewWillDisappear:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark XMPP related methods

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)addBuddy:(id)sender {
   
    //chatController.messag
	//[self presentModalViewController:addBuddyController animated:YES];
    //if (self.addBuddyController == nil) {
    //    self.addBuddyController = [[CMGAddBuddyViewController alloc]initWithNibName:@"CMGAddBuddyViewController" bundle:nil];
    //}
	//[self.navigationController  pushViewController:addBuddyController animated:YES]; 
}




///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark XMPP related methods
///////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






/*
- (NSFetchedResultsController *)fetchedResultsController
{
    return fetchedResultsController;

}
*/

/*
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSManagedObjectContext *moc;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            //a new user is added to the roster...
            //add this user to the Favorites
            
            //but first check the user exist or not yet
            
            moc = [[self appDelegate] managedObjectContext];
            XMPPUserCoreDataStorageObject *user = anObject;
            
            Favorite *fav = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
            fav.number = user.jidStr;
            fav.name = [self getNameByNumber:[user.jid user]];
            fav.status = [self getStatusInUserCoreData:[user jidStr]];
            fav.photo = [self getPhotoByNumber:[user.jid user]];
                
            NSError *error;
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }
                
            break;
            
        
    }
}
*/
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    NSLog(@"did change content");
    [self updateFavorites];
    [self fillFavoriteArray];
	[[self tView] reloadData];
    //[self._statusChangeDelegate statusChanged];
    [[[self appDelegate]favoritesViewController]contactListArray];
    [[[[self appDelegate]favoritesViewController]tView ]reloadData];
    

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	} 
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;//[[[self fetchedResultsControllerFav] sections] count];
}



 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.favoriteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
	}
	
	//XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSDictionary *m = [self.favoriteArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [m valueForKey:@"name"];    
    cell.detailTextLabel.text = [m valueForKey:@"status"];
   
   
    NSData *photo = [m valueForKey:@"photo"];
    if (photo){
        cell.imageView.image = [UIImage imageWithData:photo];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"DefaultPerson.jpeg"];
    }
   
	//[self configurePhotoForCell:cell user:user];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        //if (!(indexPath.section ==0)){
            // Delete the managed object.
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"Favorite" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"number contains[cd] %@", [[self.favoriteArray objectAtIndex:indexPath.row] valueForKey:@"number"]];
        [fetchRequest setPredicate:predicate];
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:Nil];

            [moc deleteObject:[fetchedObjects objectAtIndex:0]];
            
            NSError *error;
            if (![moc save:&error]) {
                // Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
        //}

    }   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *m = [self.favoriteArray objectAtIndex:indexPath.row];
    
    //XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    CMGChattingViewController *chatController = [[CMGChattingViewController alloc]  initWithUserName:[m valueForKey:@"number"] andNIB:@"CMGChattingViewController" bundle:nil];
    
    //
   // UINavigationController *chatControllerNav = [[UINavigationController alloc]initWithRootViewController:chatController]
    //
    [self presentModalViewController:chatController animated:YES];
    
    /*
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Favorites" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
     
     [self.navigationController pushViewController:chatControllerN animated:YES];
   */ 
     
   //UITabBarController *utc = [[self appDelegate] rootController];
    //sementara, disini langsung diset ke tab chats, sebaiknya pake delegate
   //utc.selectedIndex = 2;
}
 

-(void)fillAddressBookArray{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
     ABAddressBookRegisterExternalChangeCallback (addressBook,
     MyAddressBookExternalChangeCallback,
     ((__bridge void *)self)
     );
     
    
    //empty the roster first
    //[[[self appDelegate]xmppRosterStorage] clearAllUsersAndResourcesForXMPPStream:[self.appDelegate xmppStream]];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    
    //get phone property of every contact, add it to the contacts array
    //NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    self.addressBookArray = [[NSMutableArray alloc]init];
    
   
    for ( int i = 0; i < nPeople; i++ )
    {
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        if (ABRecordGetRecordType(ref)==kABPersonType){
            //one record:
            
            
            //get phone number
            ABMutableMultiValueRef multi ;//= ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            //ABRecordRef aRecord = ABPersonCreate();
            
            CFStringRef phoneNumber, phoneNumberLabel;
            multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            
           
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
                phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
                
                /* ... Do something with phoneNumberLabel and phoneNumber. ... */
                if ( CFStringCompare(phoneNumberLabel,kABPersonPhoneMobileLabel,1)==0 ){
                    
                    if (CFStringGetCharacterAtIndex(phoneNumber,0)=='0'){
                        
                        
                        //need to handle if the phonenumber got no country code, e.g:starting with 0
                        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
                        CTCarrier *carrier = info.subscriberCellularProvider;
                        
                        NSString *numberCF = (__bridge NSString *)phoneNumber;
                        NSString *numberTrimmed = [[numberCF componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
                        NSString *number = [[NSString stringWithFormat:@"%@%@", carrier.mobileCountryCode,numberTrimmed ] substringFromIndex:1];
                        //NSString *numberTrimmed = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        

                        //fist check if the user is using CMessenger, by using user search service to the server
                        //[self addUser:number];
                        [m setObject:number forKey:@"phoneNumber"];
                    }else{

                        NSString *number = (__bridge NSString *)phoneNumber;
                        NSString *numberTrimmed = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
                        [m setObject:numberTrimmed forKey:@"phoneNumber"];
                    
                    }
                }else if (CFStringCompare(phoneNumberLabel,kABPersonPhoneIPhoneLabel,1)==0){
                    if (CFStringGetCharacterAtIndex(phoneNumber,0)=='0'){
                        
                        
                        //need to handle if the phonenumber got no country code, e.g:starting with 0
                        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
                        CTCarrier *carrier = info.subscriberCellularProvider;
                        
                        NSString *numberCF = (__bridge NSString *)phoneNumber;
                        NSString *numberTrimmed = [[numberCF componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
                        NSString *number = [[NSString stringWithFormat:@"%@%@", carrier.mobileCountryCode,numberTrimmed ] substringFromIndex:1];
                        //[self addUser:number];
                        [m setObject:number forKey:@"phoneNumber"];
                        
                    }else{
                        //[self addUser:((__bridge NSString *)phoneNumber)];
                        NSString *number = (__bridge NSString *)phoneNumber;
                        NSString *numberTrimmed = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
                        [m setObject:numberTrimmed forKey:@"phoneNumber"];
                        
                    }
                }
                
                
                CFRelease(phoneNumberLabel);
                CFRelease(phoneNumber);
            }
            
            //CFRelease(aRecord);
            CFRelease(multi);
            
            
            // get contact picture
            if (ABPersonHasImageData(ref)) {
                if ( &ABPersonCopyImageDataWithFormat != nil ) {
                    // iOS >= 4.1
                    //return [UIImage imageWithData:(NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
                    CFDataRef dataRef= ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                    NSData *photoData = [((__bridge NSData*)dataRef)copy];
                    [m setObject:photoData forKey:@"userPhoto"];
                    CFRelease(dataRef);
                }else{
                    // 
                }
            } 
            
            
            //get firstname&lastname
            
            
            CFStringRef firstName, lastName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            NSString *name = [NSString stringWithFormat:@"%@ %@",((__bridge NSString *)firstName),((__bridge NSString *)lastName)];
            [m setObject:name forKey:@"name"];
            
            [self.addressBookArray addObject:m];
            
            
            //CFRelease(aRecord);
            CFRelease(firstName);
            //CFRelease(lastName);
            
            
            
        }
    }
    
    
    CFRelease(allPeople);
    CFRelease(addressBook);
    
}

-(void)sendPresenceSubscriptionToContacts{
    //send presenc subscription to every contacts
    for (int i=0;i<[self.addressBookArray count];i++){
        NSDictionary *m = [self.addressBookArray objectAtIndex:i];
        [self addUser:[m valueForKey:@"phoneNumber"]];
    }
}

/*
-(void)sendPresenceSubscriptionToContacts{
    
    //iterate each contact
    NSLog(@"chandra");
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    
    //empty the roster first
    //[[[self appDelegate]xmppRosterStorage] clearAllUsersAndResourcesForXMPPStream:[self.appDelegate xmppStream]];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    
    //get phone property of every contact, add it to the contacts array
    //NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    self.addressBookArray = [[NSMutableArray alloc]init];
    
    NSLog(@"jumlah people: %ld",nPeople);
    for ( int i = 0; i < nPeople; i++ )
    {
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        if (ABRecordGetRecordType(ref)==kABPersonType){
            //one record:
            
                        
            //get phone number
            ABMutableMultiValueRef multi ;//= ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            //ABRecordRef aRecord = ABPersonCreate();
            
            CFStringRef phoneNumber, phoneNumberLabel;
            multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            
            NSLog(@"testes");
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
                phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
                
                
                if ( CFStringCompare(phoneNumberLabel,kABPersonPhoneMobileLabel,1)==0 ){
                    
                    if (CFStringGetCharacterAtIndex(phoneNumber,0)=='0'){
                    
                    
                        //need to handle if the phonenumber got no country code, e.g:starting with 0
                        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
                        CTCarrier *carrier = info.subscriberCellularProvider;
                    
                        NSString *number = [NSString stringWithFormat:@"%@%@", carrier.mobileCountryCode,[((__bridge NSString *)phoneNumber) substringFromIndex:1]];
                        //fist check if the user is using CMessenger, by using user search service to the server
                        [self addUser:number];
                         [m setObject:number forKey:@"phoneNumber"];
                    }else{
                        [self addUser:((__bridge NSString *)phoneNumber)];
                        [m setObject:((__bridge NSString *)phoneNumber) forKey:@"phoneNumber"];
                    }
                }else if (CFStringCompare(phoneNumberLabel,kABPersonPhoneIPhoneLabel,1)==0){
                    if (CFStringGetCharacterAtIndex(phoneNumber,0)=='0'){
                        
                        
                        //need to handle if the phonenumber got no country code, e.g:starting with 0
                        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
                        CTCarrier *carrier = info.subscriberCellularProvider;
                        
                        NSString *number = [NSString stringWithFormat:@"%@%@", carrier.mobileCountryCode,[((__bridge NSString *)phoneNumber) substringFromIndex:1]];
                        [self addUser:number];
                        [m setObject:number forKey:@"phoneNumber"];

                    }else{
                        [self addUser:((__bridge NSString *)phoneNumber)];
                        [m setObject:((__bridge NSString *)phoneNumber) forKey:@"phoneNumber"];

                    }
                }
                
                
                CFRelease(phoneNumberLabel);
                CFRelease(phoneNumber);
            }
            
            //CFRelease(aRecord);
            CFRelease(multi);
            
            
            // get contact picture
            if (ABPersonHasImageData(ref)) {
                if ( &ABPersonCopyImageDataWithFormat != nil ) {
                    // iOS >= 4.1
                    //return [UIImage imageWithData:(NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
                    CFDataRef dataRef= ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                    [m setObject:((__bridge NSData*)dataRef) forKey:@"userPhoto"];
                    CFRelease(dataRef);
                }else{
                    // 
                }
            } 

            
            //get firstname&lastname
            
             
            CFStringRef firstName, lastName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            NSString *name = [NSString stringWithFormat:@"%@ %@",((__bridge NSString *)firstName),((__bridge NSString *)lastName)];
            [m setObject:name forKey:@"name"];
            
            [self.addressBookArray addObject:m];
            
            
            //CFRelease(aRecord);
            CFRelease(firstName);
            CFRelease(lastName);
            
            
                        
        }
    }
    
    
    CFRelease(allPeople);
    CFRelease(addressBook);
    
}
*/
-(void)addUser:(NSString *)theNumber{
    
    //2. search if user with username == thenumber exist?
    NSXMLElement *query2 = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"type" stringValue:@"hidden"];
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    [value addChild:[DDXMLNode textWithStringValue:@"jabber:iq:search"]];
    [field addChild:value];
    
    NSXMLElement *field2 = [NSXMLElement elementWithName:@"field"];
    [field2 addAttributeWithName:@"var" stringValue:@"search"];
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value"];
    [value2 addChild:[DDXMLNode textWithStringValue:theNumber]];
    [field2 addChild:value2];
    
    
    NSXMLElement *field3 = [NSXMLElement elementWithName:@"field"];
    [field3 addAttributeWithName:@"var" stringValue:@"Username"];
    NSXMLElement *value3 = [NSXMLElement elementWithName:@"value"];
    [value3 addChild:[DDXMLNode textWithStringValue:@"1"]];
    [field3 addChild:value3];
    
    
    [x addChild:field];
    [x addChild:field2];
    [x addChild:field3];
    [query2 addChild:x];
    
    
    XMPPJID *userSearch = [XMPPJID jidWithString:@"search.eueung-mulyanas-imac.local"];
    //XMPPJID *userSearch = [XMPPJID jidWithString:@"167,205.64.96"];
    
    XMPPIQ *iq2 = [XMPPIQ iqWithType:@"set" to:userSearch elementID:@"search2" child:query2];
    [[[self appDelegate] xmppStream] sendElement:iq2];   
    
    
}

+ (CMGContactsViewController *)sharedInstance{
    static CMGContactsViewController *sharedInstance = nil;
    
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[CMGContactsViewController alloc] init];
        }
    }
    return sharedInstance;
}

void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          )
{
    //[[CMGContactsViewController sharedInstance]sendPresenceSubscriptionToContacts];
    CMGContactsViewController *contactsView = (__bridge CMGContactsViewController *)context;
    [contactsView fillAddressBookArray];
    
    NSLog(@"address book changecallback called");
    
}


-(NSString *)getNameByNumber:(NSString *)number{
    
    for (NSDictionary* d in self.addressBookArray){
        if ([[d objectForKey:@"phoneNumber"]isEqualToString:number]){
            return [d objectForKey:@"name"];
            break;
        }
    }
    return nil;
}

-(NSData *)getPhotoByNumber:(NSString *)number{
    for (NSDictionary* d in self.addressBookArray){
        if ([[d objectForKey:@"phoneNumber"]isEqualToString:number]){
            NSLog(@"getphoto called");
            return [d objectForKey:@"userPhoto"];
            break;
        }
    }
    return nil;

}

-(BOOL)doesExistOnAddressBook:(NSString *)phoneNumber{
    for (int i=0;i<[self.addressBookArray count];i++){
        NSDictionary *m = [self.addressBookArray objectAtIndex:i];
        if ([[m valueForKey:@"phoneNumber"]isEqualToString:phoneNumber]){
            return YES;
        }
    }
    return NO;
}

-(void)updateRosterAndFavoriteAfterABChange:(ABAddressBookRef)theAddressBook
{
    //iterate roster one by one, if it doesn't exist on addressBookarray, then ..
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];  
    
    NSError *error = nil;
    NSArray *hasil = [moc executeFetchRequest:fetchRequest error:&error];
    
    if ([hasil count]>0){
        for (int i=0;i<[hasil count];i++){
            XMPPUserCoreDataStorageObject *user = [hasil objectAtIndex:i];
            NSString *numberToSearch = [[user.jidStr componentsSeparatedByString:@"@"]objectAtIndex:0];
            if ([self doesExistOnAddressBook:numberToSearch]==NO){
                //stop subscription from him/her
                [[[self appDelegate]xmppRoster]unsubscribePresenceFromUser:user.jid];
            
            
                //also delete him/her from favorite, if before on favorite
                NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription 
                                               entityForName:@"Favorite" inManagedObjectContext:moc];
                [fetchRequest setEntity:entity];
                NSPredicate *predicate =[NSPredicate predicateWithFormat:@"number contains[cd] %@",user.jidStr];
                [fetchRequest setPredicate:predicate];
                
                NSError *error;
                NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
                if ([fetchedObjects count]>0){
                    [moc deleteObject:[fetchedObjects objectAtIndex:0]];
                    
                    // here's where the actual save happens, and if it doesn't we print something out to the console
                    if (![moc save:&error])
                    {
                        NSLog(@"Problem saving: %@", [error localizedDescription]);
                    }
                }

            
            }
        }
    }
        
}


@end