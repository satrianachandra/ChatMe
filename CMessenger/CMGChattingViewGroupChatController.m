//
//  CMGChattingViewGroupChatController.m
//  CMessenger
//
//  Created by Chandra Satriana on 4/18/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGChattingViewGroupChatController.h"
#import "CMGAppDelegate.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"

#import "XMPPFramework.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation CMGChattingViewGroupChatController

@synthesize chatwith;
@synthesize messageField;
@synthesize tView;
@synthesize theXMPPRoom;

NSString *myUserName;

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id) initWithUser:(ChatWith *) chatwithto {
    
	if (self = [super init]) {
		
		self.chatwith = chatwithto;
        //[self appDelegate].turnSockets = [[NSMutableArray alloc] init];
	}
	return self;
    
}

- (IBAction)sendMessage:(id)sender {
    NSString *messageStr = self.messageField.text;
    [self.theXMPPRoom sendMessage:messageStr];
}

- (IBAction)closeChat:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)textFieldShouldReturn:(id)sender {
    [sender resignFirstResponder];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    NSString *theRoomJIDstring = [[chatwith.name componentsSeparatedByString:@"|"] objectAtIndex:1];
    NSString *roomName = [[theRoomJIDstring componentsSeparatedByString:@"@"]objectAtIndex:0];
    
    //find among the array of xmpparray
    //NSPredicate *query = [NSPredicate predicateWithFormat:@"roomJID contains %@", theRoomJIDstring];
    //NSArray *theroom =  [[self appDelegate].roomArray filteredArrayUsingPredicate:query];
    NSMutableArray *roomArr = [self appDelegate].roomArray;
    for (XMPPRoom *room in roomArr){
        NSLog(@"roomjid: %@",[room roomJID].full);
        NSLog(@"roojid from chatwith.name: %@",theRoomJIDstring);
        if ([[room roomJID].user isEqualToString:roomName]){
            self.theXMPPRoom = room;
            NSLog(@"theXMPPRoom filled");
            break;
        }
    }
    
    myUserName= [[[self appDelegate]xmppStream].myJID user];
    
    
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setMessageField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/////////////
- (NSFetchedResultsController *)fetchedResultsController
{
    
	if (fetchedResultsController == nil)
	{
        
		NSManagedObjectContext *moc = [self appDelegate].managedObjectContext_muc;
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject" inManagedObjectContext:moc];
		
		//NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
		
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
		
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"roomJIDStr == %@", [self.theXMPPRoom.roomJID full]];
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
}

/////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"mes count: %d",[[self fetchedResultsController ].fetchedObjects count]);
    return [[self fetchedResultsController ].fetchedObjects count];
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
    
    /*
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    ChatWith *cw = [[self.fetchedResultsController  fetchedObjects] objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    NSArray *messages1= [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
    
    MessagesInfo *messageToShow = [messages1 objectAtIndex:indexPath.row];   
    */
    
    ///////
    CMGMessageViewTableCell *cell = (CMGMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[CMGMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
	}
    
    XMPPRoomMessageCoreDataStorageObject *themessage = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    
	
    NSString *sender = themessage.jidStr;
    NSString *realSender = [[sender componentsSeparatedByString:@"/"]objectAtIndex:1];
    NSString *realSenderName = [[self appDelegate].contactsViewController getNameByNumber:realSender];
    if (!(realSenderName)){
        realSenderName = @"name not found";
    }
    
    NSLog(@"sender: %@",sender);
    //BOOL isDelivered = [messageToShow isDelivered];
    BOOL isDelivered = NO;
    
	NSString *message = themessage.body;
	//NSString *tim = [self stringFromDate:messageToShow.date];
	NSString *time = [self stringFromDate:themessage.localTimestamp];
    //NSString *time = [[tim2 componentsSeparatedByString:@" "]objectAtIndex:2];
    //NSLog(@"tim2: %@",tim2);
    NSLog(@"time: %@",time);
    
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize 
						  lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGSize sizeSender = [realSenderName sizeWithFont:[UIFont italicSystemFontOfSize:11 ]constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
	
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
    
	if ([realSender isEqualToString:myUserName]) { // left aligned
        
		bgImage = [[UIImage imageNamed:@"orange2.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(padding, padding*1.3, size.width, size.height)];
		
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
        
        if(size.width < sizeSender.width){
            size.width = sizeSender.width+5;
        }
        size.height = size.height +4;
		bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(300 - size.width - padding, 
													 padding*1.3, 
													 size.width+padding, 
													 size.height)];
		
        cell.senderInGroup.text = realSenderName;
        [cell.senderInGroup setFrame:CGRectMake(cell.messageContentView.frame.origin.x+2, cell.messageContentView.frame.origin.y+size.height,sizeSender.width , sizeSender.height)];
        
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x , 
											  cell.messageContentView.frame.origin.y - padding/5, 
											  size.width+padding, 
											  size.height+padding)];
		//cell.senderAndTimeLabel.textAlignment=UITextAlignmentRight;
        
        
        [cell.senderAndTimeLabel setFrame:CGRectMake(cell.messageContentView.frame.origin.x-timeSize2.width+7, cell.messageContentView.frame.origin.y+size.height, timeSize2.width, timeSize2.height)];
        bgImage2 = [[UIImage imageNamed:@"time.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        [cell.bgImageView2 setFrame:CGRectMake(cell.messageContentView.frame.origin.x-timeSize2.width+7, cell.messageContentView.frame.origin.y+5, timeSize2.width+2, 45)];
        
        
	}
	
    //NSData *item = messageToShow.item;
    
    //NSLog(@"item length :%d",item.length);
	cell.bgImageView.image = bgImage;
    cell.bgImageView2.image = bgImage2;
    cell.bgImageView3.image  =bgImage3;
    
    //if (item){
    //    cell.bgImageView.image = [UIImage imageWithData:item];
    //}
    
	//cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"", time];
    
	
    ///////
    
    
    
 	return cell;
}





@end
