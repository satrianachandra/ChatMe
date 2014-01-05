//
//  CMGChattingViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGChattingViewController.h"
#import "CMGAppDelegate.h"
#import "NSString+Utils.h"
#import "CMGMessageViewTableCell.h"
#import "CMGViewImageController.h"
#import "CMGViewMapController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import "XMPPFramework.h"
#import "DDLog.h"

//#import <UIImagePickerController.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation CMGChattingViewController


@synthesize navItem;
@synthesize tView;
@synthesize messageField;
@synthesize chatwith;
@synthesize navigationItem;
@synthesize fetchedResultsController;
@synthesize chatwithJID;
@synthesize theItem;

NSData *theImageData;
CLLocationManager *locationManager;

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
}


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

-(NSString *)getUser:(NSString *)jidStr{
    return [[jidStr componentsSeparatedByString:@"@"] objectAtIndex:0];
    
}

////////////////

-(void)sendStreamInititationWithMime:(NSString *)theMime fileName:(NSString *)theFileName fileSize:(NSString *)theFileSize{
    /////////////////////////////////////////////////
    
    NSString *theID = [[[self appDelegate] xmppStream] generateUUID];
    
    NSXMLElement *si = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    [si addAttributeWithName:@"id" stringValue:theID];
    [si addAttributeWithName:@"mime-type" stringValue:theMime];
    [si addAttributeWithName:@"profile" stringValue:@"http://jabber.org/protocol/si/profile/file-transfer"];
    
    NSXMLElement *file = [NSXMLElement elementWithName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
    [file addAttributeWithName:@"name" stringValue:theFileName ];
    [file addAttributeWithName:@"size" stringValue:theFileSize];
    
    NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"form"];
    
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"stream-method"];
    [field addAttributeWithName:@"type" stringValue:@"list-single"];
    
    NSXMLElement *option1 = [NSXMLElement elementWithName:@"option"];
    NSXMLElement *value1 = [NSXMLElement elementWithName:@"value"];
    [value1 addChild:[DDXMLNode textWithStringValue:@"http://jabber.org/protocol/bytestreams"]];
    
    [option1 addChild:value1];
    [field addChild:option1];
    [x addChild:field];
    [feature addChild:x];
    
    [si addChild:file];
    [si addChild:feature];
    
    //for testing purpose, send item to self
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:self.chatwithJID elementID:theID child:si];
    //XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[self appDelegate].xmppStream.myJID elementID:theID child:si];
    [[[self appDelegate] xmppStream] sendElement:iq];
    
    
    
    
}

-(void)siAnsweredwithSID:(NSString *)theID{
    //XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@/wien",chatwith.name]];
    NSLog(@"Attempting TURN connection to %@", [self.chatwithJID bare] );
    [TURNSocket setProxyCandidates:[NSArray arrayWithObject:@"eueung-mulyanas-imac.local"]];
    // TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[self appDelegate] xmppStream] toJID:[[self appDelegate]xmppStream].myJID withID:theID];
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[self appDelegate] xmppStream] toJID:self.chatwithJID withID:theID];
	//TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[self appDelegate] xmppStream] toJID:jid];
    
    [[[self appDelegate]turnSockets]addObject:turnSocket];
	
	
	[turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    

}


////////////////
////////////////

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //self.view.backgroundColor = [UIColor clearColor];
	
    ////custom background
    //UIView *bgView = [[UIView alloc]init];
    //bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"orange2.png"]];
    //bgView.opaque = YES;
    //self.tView.backgroundView=bgView;
    ////
    
    
    
    
	CMGAppDelegate *del = [self appDelegate];
	del._messageDelegate = self;
	//[self.messageField becomeFirstResponder];
    if (moc == nil){
        moc = [[self appDelegate] managedObjectContext];
    }
    
    [self appDelegate].chattingViewController = self;
    //moc = [[self appDelegate] managedObjectContext];
    
    navItem.title = [[[self appDelegate]contactsViewController]getNameByNumber:[self getUser:self.chatwith.name]];
    //NSLog(@"title: %@",self.title);
    
    //register as _itemReceivedDelegate
    [[self appDelegate]addDelegate:self];
    
    //[self sendStreamInititation];
          
    /*
    //XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@/wien",chatwith.name]];
    NSLog(@"Attempting TURN connection to %@", [self.chatwithJID bare] );
    [TURNSocket setProxyCandidates:[NSArray arrayWithObject:@"eueung-mulyanas-imac.local"]];
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[self appDelegate] xmppStream] toJID:self.chatwithJID];
	//TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[self appDelegate] xmppStream] toJID:jid];
    
    [[[self appDelegate]turnSockets]addObject:turnSocket];
	
	
	[turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    */
    NSManagedObjectContext *moc2 = [[self appDelegate] managedObjectContext_roster];
    
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                               inManagedObjectContext:moc2];
    
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
    [fetchRequest2 setEntity:entity2];
    
    NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"jidStr == %@", chatwith.name];
    [fetchRequest2 setPredicate:predicate2];
    NSLog(@"chatwith.name = %@",chatwith.name);
    NSArray *fetchedObjects2 = [moc2 executeFetchRequest:fetchRequest2 error:nil];
    if ([fetchedObjects2 count]>0){
        self.chatwithJID = [[[fetchedObjects2 objectAtIndex:0]primaryResource]jid];
    }
    
    [self appDelegate].turnSockets = [[NSMutableArray alloc] init];
    
    ChatWith *cw = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:0];
    
    if ([[[cw messages]allObjects]count]>=1){
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[cw messages]allObjects]count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
}

- (void)itemReceived:(NSData *)theItem{
    NSLog(@"the item is received");
}

- (void)viewDidUnload
{
    [self setNavigationItem:nil];
    
    [self setNavItem:nil];
    [self setNavItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window]; 
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    
    
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 210.0;
        rect.size.height += 210.0;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += 210.0;
        rect.size.height -= 210.0;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    
    if (([messageField isFirstResponder]) && self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    /*
     else if ((![countryCode isFirstResponder] || ![phoneNumberField isFirstResponder]) && self.view.frame.origin.y < 0)
     {
     [self setViewMovedUp:NO];
     }
     */
}

-(void)keyboardWillHide:(NSNotification *)notif
{
    [self setViewMovedUp:NO];
    ChatWith *cw = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:0];
    
    if ([[[cw messages]allObjects]count]>=1){
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[cw messages]allObjects]count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//////////////////////////////////////////////
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
	
	NSLog(@"TURN Connection as a sender, succeeded!");
	NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    
    if (self.theItem){

        //NSString *headerStr = [NSString stringWithFormat:@"%d\r\n",self.theItem.length];
        //NSData *header = [headerStr dataUsingEncoding:NSUTF8StringEncoding];

        //tag 0 = header
        //[socket writeData:header withTimeout:-1 tag:0];
    
        //tag 1 = the item to send
        [socket writeData:theItem withTimeout:-1 tag:1];
     
        MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
        themessage.message = @"";
        themessage.from = @"me";
        themessage.to = chatwith.name;
        themessage.date = [NSDate date];
        themessage.chatwith = chatwith;
        themessage.item = self.theItem;
        
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }

        
    }
    
    self.theItem = nil;
    [[[self appDelegate ]turnSockets] removeObject:sender];
    
    //
    
    
    
    
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
	
	NSLog(@"TURN Connection failed!");
	//[turnSockets removeObject:sender];
	[[[self appDelegate ]turnSockets] removeObject:sender];
}



/////////////////////////////////////////////


- (XMPPStream *)xmppStream {
	return [[self appDelegate] xmppStream];
}

- (id) initWithUser:(ChatWith *) chatwithto {

	if (self = [super init]) {
		
		self.chatwith = chatwithto;
        [self appDelegate].turnSockets = [[NSMutableArray alloc] init];
        
        //find jid of chatwith.name
        /*
		NSManagedObjectContext *moc2 = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                   inManagedObjectContext:moc2];
        
		NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
		[fetchRequest2 setEntity:entity2];
        
        NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"jidStr == %@", chatwith.name];
        [fetchRequest2 setPredicate:predicate2];
        NSError *error;
        NSArray *fetchedObjects2 = [moc2 executeFetchRequest:fetchRequest2 error:&error];
        if ([fetchedObjects2 count]>0){
            self.chatwithJID = [[fetchedObjects2 objectAtIndex:0]jid];
        }
         */

	}
	return self;
    
}

-(id) initWithUserName:(NSString *)uname andNIB:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        
        moc = [[self appDelegate] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatWith" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        
        NSLog(@"uname: %@",uname);
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name contains[cd] %@", uname];
        [fetchRequest setPredicate:predicate];

        NSError *error;
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count]>0){
            self.chatwith = [fetchedObjects objectAtIndex:0];
        }else{ //berarti belum pernah chat sebelumnya
            chatwith = (ChatWith *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatWith" inManagedObjectContext:moc];
            chatwith.name = uname;
            //chatwith.isactive =YES;
            
        }
        
        
        //find jid of chatwith.name
        /*..moved to didLoad()*/
		
    }
    return self;
}

- (IBAction) closeChat {
	[self dismissModalViewControllerAnimated:YES];
    
}


/////////////////////////////////////////////////////////////////////////////
- (IBAction)sendMessage {
    
    NSString *messageStr = self.messageField.text;
    
    if(!([[self xmppStream] isConnected]) ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"No Internet Connection" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
    }else{
    if([messageStr length] > 0) {
        
        NSDate *dateNow = [NSDate date];
        //NSString *idForConfirmation = [dateNow description];
        NSString *idForConfirmation= [NSString stringWithFormat:@"%f",[dateNow timeIntervalSince1970]];
        NSLog(@"idForConfirmation: %@",idForConfirmation);
        
        // send message through XMPP
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:[messageStr substituteEmoticons]];
		
        NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatwith.name];
        NSLog(@"chatwith.name: %@",chatwith.name);
        [message addAttributeWithName:@"id" stringValue:idForConfirmation];
        [message addChild:body];
        [message addChild:request];
		
        [self.xmppStream sendElement:message];
		
        
        self.messageField.text = @"";
        //[self.messageField resignFirstResponder];
        
        //save the message
        //prepare the message to save:
        
        MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
        themessage.message = [messageStr substituteEmoticons];
        themessage.from = @"me";
        themessage.to = chatwith.name;
        themessage.date = dateNow;
        themessage.chatwith = chatwith;
        //themessage.delivered = YES;
        [themessage setDeliveredScalar:YES];
        themessage.idMess = idForConfirmation;
        
        if (self.theItem){
            themessage.item = self.theItem;
        }
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }
    }
}

//////Using Core data

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"macmac");
	if (fetchedResultsController == nil)
	{
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatWith"
		                                          inManagedObjectContext:moc];
		
		//NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
		
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		//[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name == %@", chatwith.name];
        NSLog(@"name = %@",chatwith.name);
        [fetchedResultsController.fetchRequest setPredicate:predicate];
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [[self tView] reloadData];
    [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self tableView:self.tView numberOfRowsInSection:0]-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ChatWith *cw = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:0];
    return [[[cw messages]allObjects]count];
    //NSLog(@"sdf");
	
    //return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


-(NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:date];
}


static CGFloat padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    //NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    ChatWith *cw = [[self.fetchedResultsController  fetchedObjects] objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    NSArray *messages1= [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
    
    MessagesInfo *messageToShow = [messages1 objectAtIndex:indexPath.row];   
    NSData *item = messageToShow.item;
    BOOL isLocation = [messageToShow isLocationScalar];
     
    //double longitude = messageToShow.longitude;
    
    ///////
    CMGMessageViewTableCell *cell = (CMGMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    
	if (cell == nil) {
		cell = [[CMGMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
        if (item){
            cell.userInteractionEnabled = YES;
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x -30, 
                                                  cell.messageContentView.frame.origin.y - padding/5, 
                                                  35, 
                                                  35)];
            cell.bgImageView.image = [UIImage imageWithData:item];
            [cell.viewItem setFrame:CGRectMake(cell.bgImageView.frame.origin.x, cell.bgImageView.frame.origin.y+35, 40, 16)];
            [cell.viewItem setTag:indexPath.row];
            [cell.viewItem addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        
    }
    
	
    NSString *sender = messageToShow.from;
    BOOL isDelivered = [messageToShow deliveredScalar];
     
	NSString *message = messageToShow.message;
    
    
	NSString *tim = [self stringFromDate:messageToShow.date] ;
	NSString *time = [NSString stringWithFormat:@"%@ %@", @"", tim];
    //NSString *time = [[tim2 componentsSeparatedByString:@" "]objectAtIndex:2];
    //NSLog(@"tim2: %@",tim2);
    NSLog(@"time: %@",time);
    
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize 
						  lineBreakMode:UILineBreakModeWordWrap];
    
	
	size.width += (padding/2);
	
	cell.messageContentView.text = message;
    cell.senderAndTimeLabel.text = time;
    cell.senderAndTimeLabel.font = [UIFont systemFontOfSize:9.5]; 
    
    //time & delivery notif
    CGSize timeSize = {200.0,1000.0};
    CGSize timeSize2 = [time sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:timeSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
	
    
	UIImage *bgImage = nil;
	UIImage *bgImage2 = nil;
    UIImage *bgImage3 = nil;
    
	if ([sender isEqualToString:@"me"]) { // left aligned
        
		bgImage = [[UIImage imageNamed:@"orange2.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(padding-3, padding*1.3, size.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2, 
											  cell.messageContentView.frame.origin.y - padding/5, 
											  size.width+padding, 
											  size.height+padding)];
        
        [cell.senderAndTimeLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x+size.width, cell.messageContentView.frame.origin.y+size.height, timeSize2.width, timeSize2.height)];
        if (isDelivered){
            bgImage2 = [[UIImage imageNamed:@"time.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            [cell.bgImageView2 setFrame:CGRectMake(cell.messageContentView.frame.origin.x+size.width, cell.messageContentView.frame.origin.y+5, timeSize2.width+7, 45)];
            
            bgImage3 = [UIImage imageNamed:@"CheckMark2.png"];
            [cell.bgImageView3 setFrame:CGRectMake(cell.bgImageView2.frame.origin.x+timeSize2.width, cell.bgImageView2.frame.origin.y+timeSize2.height, 10.0, 10.0)];
            
        }else{
            bgImage2 = [[UIImage imageNamed:@"time.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
            [cell.bgImageView2 setFrame:CGRectMake(cell.messageContentView.frame.origin.x+size.width, cell.messageContentView.frame.origin.y+5, timeSize2.width+2, 45)];
            //cell.senderAndTimeLabel.textAlignment=UITextAlignmentLeft;
        }
        
	} else {
        
		bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(300 - size.width - padding, 
													 padding*1.3, 
													 size.width+padding, 
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x , 
											  cell.messageContentView.frame.origin.y - padding/5, 
											  size.width+padding, 
											  size.height+padding)];
		//cell.senderAndTimeLabel.textAlignment=UITextAlignmentRight;
        
        
        [cell.senderAndTimeLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x-timeSize2.width+7, cell.messageContentView.frame.origin.y+size.height, timeSize2.width, timeSize2.height)];
        bgImage2 = [[UIImage imageNamed:@"time.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        [cell.bgImageView2 setFrame:CGRectMake(cell.messageContentView.frame.origin.x-timeSize2.width+7, cell.messageContentView.frame.origin.y+5, timeSize2.width+2, 45)];
        
        
	}
	
   
    
    NSLog(@"item length :%d",item.length);
	cell.bgImageView.image = bgImage;
    cell.bgImageView2.image = bgImage2;
    cell.bgImageView3.image  =bgImage3;
    
    if (item){
        [cell.bgImageView2 setHidden:YES];
        [cell.viewItem setTitle:@"View" forState:UIControlStateNormal];
        //[cell.senderAndTimeLabel setHidden:YES];
        if ([sender isEqualToString:@"me"]){
            
       
            cell.userInteractionEnabled = YES;
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x +10, 
                                             cell.messageContentView.frame.origin.y - padding/5, 
                                             50, 
                                             40)];
    
            cell.bgImageView.image = [UIImage imageWithData:item];
            [cell.viewItem setFrame:CGRectMake(cell.bgImageView.frame.origin.x, cell.bgImageView.frame.origin.y+40, 40, 16)];
            [cell.viewItem setTag:indexPath.row];
            
            
            [cell.viewItem addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
        
        }else{
            cell.userInteractionEnabled = YES;
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x -20, 
                                                  cell.messageContentView.frame.origin.y - padding/5, 
                                                  50, 
                                                  40)];
            
            cell.bgImageView.image = [UIImage imageWithData:item];
            [cell.viewItem setFrame:CGRectMake(cell.bgImageView.frame.origin.x, cell.bgImageView.frame.origin.y+40, 40, 16)];
            [cell.viewItem setTag:indexPath.row];
            
            [cell.viewItem addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
        
        }

    }
    
    if (isLocation){
        [cell.bgImageView2 setHidden:YES];
        [cell.viewItem setTitle:@"View" forState:UIControlStateNormal];
        if ([sender isEqualToString:@"me"]){
            [cell.senderAndTimeLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x+42, cell.messageContentView.frame.origin.y+42, timeSize2.width, timeSize2.height)];
            
            cell.userInteractionEnabled = YES;
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x +10, 
                                                  cell.messageContentView.frame.origin.y - padding/5, 
                                                  50, 
                                                  40)];
            
            cell.bgImageView.image = [UIImage imageNamed:@"defaultMap.jpg"];
            [cell.viewItem setFrame:CGRectMake(cell.bgImageView.frame.origin.x, cell.bgImageView.frame.origin.y+40, 40, 16)];
            [cell.viewItem setTag:indexPath.row];
            
            
            [cell.viewItem addTarget:self action:@selector(viewMap:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            cell.userInteractionEnabled = YES;
            [cell.senderAndTimeLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x-25, cell.messageContentView.frame.origin.y+40, timeSize2.width, timeSize2.height)];
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x -20, 
                                                  cell.messageContentView.frame.origin.y - padding/5, 
                                                  50, 
                                                  40)];
            
            cell.bgImageView.image = [UIImage imageNamed:@"defaultMap.jpg"];
            [cell.viewItem setFrame:CGRectMake(cell.bgImageView.frame.origin.x, cell.bgImageView.frame.origin.y+40, 40, 16)];
            [cell.viewItem setTag:indexPath.row];
            
            [cell.viewItem addTarget:self action:@selector(viewMap:) forControlEvents:UIControlEventTouchUpInside];
            
        }

    }
    
	//cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"", time];
    
	
    ///////
    
    
    
 	return cell;
}

-(NSIndexPath* )tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    ChatWith *cw = [[self.fetchedResultsController  fetchedObjects] objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    NSArray *messages1= [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
    
    MessagesInfo *messageToShow = [messages1 objectAtIndex:indexPath.row];   
    NSData *item = messageToShow.item;
    BOOL isLoc= [messageToShow isLocationScalar];
    if (item){
        return 70;
    }else if(isLoc){
        return 80;
    }else{
        NSString *message = messageToShow.message;
        
        CGSize  textSize = { 260.0, 10000.0 };
        CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
                          constrainedToSize:textSize 
                              lineBreakMode:UILineBreakModeWordWrap];
        
        
        return size.height+padding+5;
    }

}

-(void)viewImage:(UIButton*)sender{
    //
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    NSLog(@"image row: %d",row);
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
        
    ChatWith *cw = [[self.fetchedResultsController  fetchedObjects] objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    NSArray *messages1= [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
        
    MessagesInfo *messageToShow = [messages1 objectAtIndex:row];
    CMGViewImageController *vic = [[CMGViewImageController alloc]initWithNibName:@"CMGViewImageController" bundle:nil];
    if (messageToShow.item){
        vic.theImage= messageToShow.item;
        [self presentModalViewController:vic animated:YES];
    }
    
    //
    
}

-(void)viewMap:(UIButton*)sender{
    //
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    NSLog(@"image row: %d",row);
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    ChatWith *cw = [[self.fetchedResultsController  fetchedObjects] objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    NSArray *messages1= [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
    
    MessagesInfo *messageToShow = [messages1 objectAtIndex:row];
    CMGViewMapController *vmc = [[CMGViewMapController alloc]initWithNibName:@"CMGViewMapController" bundle:nil];
    vmc.theLat = [messageToShow latitudeScalar];
    vmc.theLongitude = [messageToShow longitudeScalar];
    [self presentModalViewController:vmc animated:YES];
}


- (IBAction)textFieldShouldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender{
    [self.messageField resignFirstResponder];
}

               
- (IBAction) textFieldDidBeginEditing:(id)sender {
    //UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    //[tView scrollToRowAtIndexPath:[tView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[[chatwith messages]allObjects]count]-1) inSection:0];
    //[self.tView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    //[self.tView ]
    
}

- (IBAction)sendItems:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Items"
                                                        message:nil 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Take Photo",@"Open Gallery",@"Share Location",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        //[self startCameraControllerFromViewController:self usingDelegate:self];
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = NO;
        
        cameraUI.delegate = self;
        [self presentModalViewController: cameraUI animated: YES];
        
    }else if (buttonIndex==2) {
            //open Photos
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypePhotoLibrary]) 
        {
            // Set source to the Photo Library
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [imagePicker setDelegate:self];
            [self presentModalViewController:imagePicker animated:YES];
            
        }
    }else if (buttonIndex ==3){
        //show CMGMapItemViewController
        NSLog(@"tes 3");
        //CMGMapItemViewController *controller = [[CMGMapItemViewController alloc] initWithNibName:@"CMGMapItemViewController" bundle:nil];
        //[self presentModalViewController:controller animated:YES]; 
        
        //send my current location using CLLocationManager
        // Create the location manager if this object does not
        // already have one.
        //CLLocationManager *locationManager;
        if (nil == locationManager)
            locationManager = [[CLLocationManager alloc] init];
        
        locationManager.delegate = self;
        //[locationManager startMonitoringSignificantLocationChanges];
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 500;
        
        [locationManager startUpdatingLocation];
    }
        
        
  
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSLog(@"called");
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        
    }
    //send the location using the message form using customized Message
    // send message through XMPP
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    NSString *messageStr = [NSString stringWithFormat:@"%f|%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
    [body setStringValue:messageStr];
    
    //NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"LocationInfo"];
    [message addAttributeWithName:@"to" stringValue:chatwith.name];
    [message addChild:body];
    //[message addChild:request];
    
    [[self xmppStream]sendElement:message];
    
    //save it to messages
    MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
    themessage.message = @"";
    //themessage.isLocation = YES;
    [themessage setIsLocationScalar:YES];
    themessage.from = @"me";
    themessage.to = chatwith.name;
    themessage.date = [NSDate date];
    themessage.chatwith = chatwith;
    [themessage setLatitudeScalar:newLocation.coordinate.latitude];
    [themessage setLongitudeScalar:newLocation.coordinate.longitude];
    //themessage.item = self.theItem;
    
    
    NSError *error;
    // here's where the actual save happens, and if it doesn't we print something out to the console
    if (![moc save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
    
    
    

    [locationManager stopUpdatingLocation];
    // else skip the event and process the next one.
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    /*
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)== kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        
        self.theItem = UIImageJPEGRepresentation(imageToSave,0.9f);
        [self sendStreamInititationWithMime:@"image/jpeg" fileName:@"image.jpg" fileSize:[NSString stringWithFormat:@"%d",[self.theItem length] ]];
        
    }else{
     */
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        //NSURL *theUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
        //NSError *attributesError = nil;
        //NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[theUrl path] error:&attributesError];
        //NSLog(@"abs: %@",[fileAttributes absoluteString]);
        //int fileSize = [fileAttributes fileSize];
        //[theUrl de
        NSLog(@"dipanggil");
        self.theItem = UIImageJPEGRepresentation(image,0.9f);
        [self sendStreamInititationWithMime:@"image/jpeg" fileName:@"image.jpg" fileSize:[NSString stringWithFormat:@"%d",[self.theItem length] ]];
        //NSLog(@"file size %d ",[self.theItem length]);
   // }
    [picker dismissModalViewControllerAnimated:YES];
   
    
    
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}





@end
