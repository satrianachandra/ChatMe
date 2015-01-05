//
//  CMGFavoritesViewController.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/22/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGFavoritesViewController.h"
#import "CMGAppDelegate.h"
#import "CMGNewGroupChatViewController.h"
#import "CMGBroadcastMessageViewController.h"

#import "XMPPFramework.h"
#import "DDLog.h"
#import "SVProgressHUD.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;f
#endif


@implementation CMGFavoritesViewController
@synthesize tView;
@synthesize contacts;
@synthesize fetchedResultsController;
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize searchResults;
@synthesize queue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *addContactButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact)];
    
    self.navigationItem.rightBarButtonItem = addContactButton;
    //self.navigationController.navigationItem.rightBarButtonItem = addContactButton;
    
    
    //UIViewController *contactsView = [[[[self appDelegate] rootController] viewControllers] objectAtIndex:1];
    //[contactsView view];
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    //NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[fetchRequest setFetchBatchSize:10];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:moc
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    //[self.fetchedResultsController setDelegate:self];

    if(!(backgroundQueue)){
        backgroundQueue = dispatch_queue_create("com.chan.chatme.bgqueue", NULL); 
    }
    dispatch_async(backgroundQueue, ^(void){
        [self contactListArray];
    });
    if ([[self.fetchedResultsController fetchedObjects]count]<1){
        [SVProgressHUD showWithStatus:@"Processing Contacts.."];
    }
    
    //[self contactListArray];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setSearchDisplayController:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
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
		
		
		
        
	}
	
	return fetchedResultsController;
}
*/
 
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[self contactListArray];
    //[[self tView] reloadData];
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//return [[[self fetchedResultsController] sections] count];
    return 1;
   
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    /*
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	*/
    NSInteger rows = 0;
    
    if([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        rows = [self.searchResults count];
    }else{
        rows = [self.contacts count];
    }
    
    return rows;  //[self.contacts count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    
    NSDictionary *s = nil;
    
	if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        //cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row]
        //NSDictionary *s =  [self.searchResults objectAtIndex:indexPath.row];
        s =  [self.searchResults objectAtIndex:indexPath.row];
        
    }else{
        s =  [self.contacts objectAtIndex:indexPath.row];
    }

	NSString *name = [s objectForKey:@"name"];
    NSString *mobileStatus = [s objectForKey:@"mobileStatus"];
    NSString *iphoneStatus = [s objectForKey:@"iphoneStatus"];
    
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        if ((!iphoneStatus)|| (!iphoneStatus)) {
            cell.detailTextLabel.text = @"";
        }
        

        
	}
	
	//XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
       
    cell.textLabel.text = name;
    if ( (mobileStatus) && ![mobileStatus isEqualToString:@""]) {
        
        cell.detailTextLabel.text = mobileStatus;
    }else{
    
    if ( (iphoneStatus) && ![iphoneStatus isEqualToString:@""]) {
        cell.detailTextLabel.text = iphoneStatus;
    }
    }
	return cell;
}



-(void)contactListArray{
    
    //self.contacts = nil;
    self.contacts = [[NSMutableArray alloc]init];
    //grab all the contacts list into array
    ABAddressBookRef addressBook = ABAddressBookCreate( );
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    
    NSLog(@"dipanggil");
    //get phone property of every contact, add it to the contacts array
    for ( int i = 0; i < nPeople; i++ )
    {
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        if (ABRecordGetRecordType(ref)==kABPersonType){
            //one record:
            
            //get phone number
            ABMutableMultiValueRef multi;// = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            //ABRecordRef aRecord = ABPersonCreate();
            
            CFStringRef phoneNumber, phoneNumberLabel;
            multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
           
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
                phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
                NSString *phoneNumberString= (__bridge NSString*)phoneNumber;
                NSString *phoneNumberStringTrimmed = [[phoneNumberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
                
                
                //asumsi nomor tiap kontak antara mobile dan iphone
                //asumsi tiap kontak ada nomornya
                
                /* ... Do something with phoneNumberLabel and phoneNumber. ... */
                if ( CFStringCompare(phoneNumberLabel,kABPersonPhoneMobileLabel,0)==0 ){
                    NSString* statusnya = [self getStatusInUserCoreData:phoneNumberStringTrimmed];
                    if (statusnya != nil){
                        [m setObject:statusnya forKey:@"mobileStatus"];
                    }else{
                        [m setObject:@"" forKey:@"mobileStatus"];
                    }
                    [m setObject:phoneNumberStringTrimmed forKey:@"mobileNumber"];
                    NSLog(@"phoneNumberStringTrimmed: %@",phoneNumberStringTrimmed);
                }
                else if (CFStringCompare(phoneNumberLabel,kABPersonPhoneIPhoneLabel,0)==0){
                    //do a search from user core data, to get the status
                    NSString* statusnya = [self getStatusInUserCoreData:phoneNumberStringTrimmed];
                    if (statusnya != nil){
                        [m setObject:statusnya forKey:@"iphoneStatus"];
                    }else{
                        [m setObject:@"" forKey:@"iphoneStatus"];
                    }
                    [m setObject:phoneNumberStringTrimmed forKey:@"iphoneNumber"];
                }
                
                
                CFRelease(phoneNumberLabel);
                CFRelease(phoneNumber);
            }
            
            /* set default value if no number is found
            if(ABMultiValueGetCount(multi)==0){
                [m setObject:@"" forKey:@"iphoneNumber"];
            }   
            */
             
            //CFRelease(aRecord);
            CFRelease(multi);
            //CFRelease(kABMultiStringPropertyType);
            //CFDataRef dataRef;
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
            //ABRecordRef aRecord = ABPersonCreate();
            
            CFStringRef firstName, lastName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            NSString *name = [NSString stringWithFormat:@"%@ %@",((__bridge NSString *)firstName),((__bridge NSString *)lastName)];
            [m setObject:name forKey:@"name"];
            NSLog(@"name: %@",name);
            [[self contacts] addObject:m];
            NSLog(@"contacts: %d",[self.contacts count]);
            
            //CFRelease(ref);
            CFRelease(firstName);
            //CFRelease(lastName);
           
        }
   
    }
    [[self tView]reloadData];
    [SVProgressHUD dismiss];
    
    CFRelease(addressBook);
    CFRelease(allPeople);
}


- (IBAction)broadcastMessage:(id)sender {
    //sending broadcast message
    CMGBroadcastMessageViewController *broadcastController = [[CMGBroadcastMessageViewController alloc]initWithNibName:@"CMGBroadcastMessageViewController" bundle:nil];
    [self presentModalViewController:broadcastController animated:YES];
    
}

- (IBAction)groupChat:(id)sender {
    CMGNewGroupChatViewController *groupChatController = [[CMGNewGroupChatViewController alloc]initWithNibName:@"CMGNewGroupChatViewController" bundle:nil];
    
    [self presentModalViewController:groupChatController animated:YES];
    //[self.navigationController pushViewController:groupChatController animated:YES]; 
}

-(NSString *)getStatusInUserCoreData:(NSString *)phoneNumber{
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc];
                                   
    //[self.fetchedResultsController.fetchRequest setEntity:entity];  
    
    //if (self.fetchedResultsController == nil)
	//{
		    
    
    //}
    
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
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMGContactDetailsViewController *controller = [[CMGContactDetailsViewController alloc] initWithNibName:@"CMGContactDetailsViewController" bundle:nil];
    NSDictionary *contactDictionary;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        //cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row]
        //NSDictionary *s =  [self.searchResults objectAtIndex:indexPath.row];
        contactDictionary =  [self.searchResults objectAtIndex:indexPath.row];
        
    }else{
        contactDictionary =  [self.contacts objectAtIndex:indexPath.row];
    }
    
    controller.name = [contactDictionary objectForKey:@"name"];
    controller.mobileStatus = [contactDictionary objectForKey:@"mobileStatus"];
    controller.mobileNumber = [contactDictionary objectForKey:@"mobileNumber"];
    controller.iphoneStatus = [contactDictionary objectForKey:@"iphoneStatus"];
    controller.iphoneNumber = [contactDictionary objectForKey:@"iphoneNumber"];
    controller.photo = [contactDictionary objectForKey:@"userPhoto"];
    
    [self.navigationController pushViewController:controller animated:YES]; 
    
}


-(void)addContact{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
    NSLog(@"addContact dipanggil");
}

#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
    [self contactListArray];
    [self.tView reloadData];
    //check if he has CMessenger, if yes then add to roster and Favorite
    
    
}


- (void)filterContentForSearchText:(NSString*)searchText 
                             scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate 
                                    predicateWithFormat:@"name contains[cd] %@",
                                    searchText];
    NSArray *matchedDicts = [self.contacts filteredArrayUsingPredicate:resultPredicate];
    self.searchResults = matchedDicts;
    
    //self.searchResults = [self.allItems filteredArrayUsingPredicate:resultPredicate];
}



#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:searchOption]];
    
    return YES;
}




@end
