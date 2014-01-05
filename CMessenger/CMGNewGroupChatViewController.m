//
//  CMGNewGroupChatViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 3/23/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGNewGroupChatViewController.h"
#import "CMGAppDelegate.h"
#import "ChatRoom.h"
#import "NSString+Utils.h"

@implementation CMGNewGroupChatViewController
@synthesize tView = _tView;
@synthesize subjectField = _subjectField;
@synthesize searchResults;
@synthesize contacts;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contacts = [[self appDelegate]favoritesViewController].contacts;
    if (self.contacts){
        NSLog(@"tidak nil");
    }else{
        NSLog(@"bernilai nil");
    }
    
    NSDictionary *tes = [self.contacts objectAtIndex:0];
    NSLog(@"nama[0],%@",[tes valueForKey:@"name"]);
    
    self.navigationItem.title = @"GroupChat Invitation";
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
	
    _toRecipients = [[NSMutableArray alloc]init];
    
    _toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, self.subjectField.frame.origin.y+self.subjectField.bounds.size.height+10, 320, 31)];
	[[_toField label] setText:@"   Invite:"];
	[_toField setDelegate:self];
	[self.view addSubview:_toField];
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, _toField.bounds.size.height-1, _toField.bounds.size.width, 1)];
    [separator1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toField addSubview:separator1];
    [separator1 setBackgroundColor:[UIColor lightGrayColor]];
	
    /*
	_ccField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 31, 320, 31)];
	[[_ccField label] setText:@"CC:"];
	[_ccField setDelegate:self];
	[self.view addSubview:_ccField];
    
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, _ccField.bounds.size.height-1, _ccField.bounds.size.width, 1)];
    [separator2 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_ccField addSubview:separator2];
    [separator2 setBackgroundColor:[UIColor lightGrayColor]];
    */
     
}

- (void)viewDidUnload
{
    [self setSubjectField:nil];
    [self setTView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//////////
///UITableView Delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSLog(@"count: %d",[self.searchResults count]);
    if ([self.searchResults count]<1){
        self.tView.hidden = YES;
    }else{
        self.tView.hidden = NO;
    }
    return [self.searchResults count];
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
	
    NSDictionary *s = nil;
    s =  [self.searchResults objectAtIndex:indexPath.row];
    NSString *name = [s objectForKey:@"name"];
    NSString *mobileStatus = [s objectForKey:@"mobileStatus"];
    NSString *iphoneStatus = [s objectForKey:@"iphoneStatus"];
    cell.textLabel.text = name;
    if ((!mobileStatus) || [mobileStatus isEqualToString:@""]){
        
    }else{
        cell.detailTextLabel.text = mobileStatus;
    }
    
    if ((!iphoneStatus)||[iphoneStatus isEqualToString:@""]){
        
    }else{
        cell.detailTextLabel.text = iphoneStatus;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *contactDictionary = [self.searchResults objectAtIndex:[indexPath row]];
    [_toField addTokenWithTitle:[contactDictionary valueForKey:@"name"] representedObject:contactDictionary];

}
//////////////



///////////
//searching
- (void)filterContact:(NSString*)searchText 
{
    NSLog(@"searchText: |%@|",searchText);
    for(int i=0;i<[searchText length];i++){
        NSLog(@"char %d: %c",i,[searchText characterAtIndex:i]);
    }
    
    NSPredicate *resultPredicate = [NSPredicate 
                                    predicateWithFormat:@"name contains[cd] %@",[searchText substringFromIndex:1]];
    
    NSArray *matchedDicts = [self.contacts filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"matchedDicts count: %d",[matchedDicts count]);
    self.searchResults = matchedDicts;
    [self.tView reloadData];
    //self.searchResults = [self.allItems filteredArrayUsingPredicate:resultPredicate];
}


///////////
//

#pragma mark -
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	//NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
	//[_toRecipients addObject:recipient];
    [_toRecipients addObject:obj];
	NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, _toRecipients);
    
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{	
	[_toRecipients removeObjectAtIndex:index];
	NSLog(@"Deleted token %d\n%@", index, _toRecipients);
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    
    /*
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length])
	{
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    */
    [tokenField.textField resignFirstResponder];
    return NO;
}

-(void)tokenFieldTextDidChange:(JSTokenField *)tokenField{
    NSLog(@"tokenFieldTextDidChange");
    [self filterContact:tokenField.textField.text];
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField{
    NSLog(@"tokenFieldDidEndEditing");
}


- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
	if ([[note object] isEqual:_toField])
	{
        /*
		[UIView animateWithDuration:0.0
						 animations:^{
							 [_ccField setFrame:CGRectMake(0, [_toField frame].size.height + [_toField frame].origin.y, [_ccField frame].size.width, [_ccField frame].size.height)];
						 }
						 completion:nil];
         */
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)newRoom:(id)sender {
    //joinRoomUsingNickname:(NSString *)desiredNickname history:(NSXMLElement *)history;
    NSString *theSubject = self.subjectField.text;
    NSLog(@"the subject: %@",theSubject);
    
    //save room data to entity ChatRoom
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
    ChatRoom *chatRoom = (ChatRoom *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatRoom" inManagedObjectContext:moc];
    chatRoom.subject = theSubject;
    
    //NSString *myNumber =  [self appDelegate ].xmppStream.myJID.user;
    double dateNow = [NSDate timeIntervalSinceReferenceDate];
    //NSString *chatRoomName = [NSString stringWithFormat:@"%@%@",myNumber,[NSString removeSpaces:[dateNow description]]]; 
    NSString *chatRoomName = [NSString stringWithFormat:@"%f",dateNow]; 
    chatRoom.name = chatRoomName;
    NSLog(@"chatroom name = %@",chatRoom.name);
    
    NSMutableString *invited = [[NSMutableString alloc]init ];
    for (NSDictionary *contactDicti in _toRecipients){
        NSLog(@"contactDicti: %@",[contactDicti description]);
        NSString *mobileNumber = [contactDicti objectForKey:@"mobileNumber"];
        NSString *iphoneNumber = [contactDicti objectForKey:@"iphoneNumber"];
        NSLog(@"mobileNumber newRoom:%@",mobileNumber);
        NSLog(@"iphoneNumber newRoom:%@",iphoneNumber);
        if (mobileNumber){
            [invited appendString:mobileNumber];
            [invited appendString:@"|"];
        }else if (iphoneNumber){
            [invited appendString:iphoneNumber];
            [invited appendString:@"|"];
        }
        
    }
    chatRoom.invited = (NSString *)invited;
    NSLog(@"invited: %@",chatRoom.invited);
    
    NSError *error;
    // here's where the actual save happens, and if it doesn't we print something out to the console
    if (![moc save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }

    
    
    
    [[self appDelegate]newRoomWithName:chatRoomName];
    
    [self dismissModalViewControllerAnimated:YES];
    
}




@end
