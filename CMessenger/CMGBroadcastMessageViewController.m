//
//  CMGBroadcastMessageViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 5/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGBroadcastMessageViewController.h"
#import "CMGAppDelegate.h"
#import "SVProgressHUD.h"

@implementation CMGBroadcastMessageViewController
@synthesize messageField;
@synthesize tView = _tView;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
	
    _toRecipients = [[NSMutableArray alloc]init];
    
    _toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, self.messageField.frame.origin.y+self.messageField.bounds.size.height+10, 320, 31)];
	[[_toField label] setText:@"   To:"];
	[_toField setDelegate:self];
	[self.view addSubview:_toField];
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, _toField.bounds.size.height-1, _toField.bounds.size.width, 1)];
    [separator1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toField addSubview:separator1];
    [separator1 setBackgroundColor:[UIColor lightGrayColor]];

}

- (void)viewDidUnload
{
    [self setMessageField:nil];
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


-(void)sendMessageFinish{
    [SVProgressHUD dismissWithSuccess:@"Message sent" afterDelay:2];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender {
    if ([_toRecipients count] >0){
        
        [SVProgressHUD showWithStatus:@"Sending message.."];
        NSString *theMessage = [self.messageField.text copy];

        //send the message to recipients
        for (NSDictionary *contactDicti in _toRecipients){
            NSLog(@"contactDicti: %@",[contactDicti description]);
            NSString *mobileNumber = [contactDicti objectForKey:@"mobileNumber"];
            NSString *iphoneNumber = [contactDicti objectForKey:@"iphoneNumber"];
            NSLog(@"mobileNumber newRoom:%@",mobileNumber);
            NSLog(@"iphoneNumber newRoom:%@",iphoneNumber);
            if (mobileNumber){
                // send message through XMPP
                NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
                [body setStringValue:theMessage];
                NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                [message addAttributeWithName:@"type" stringValue:@"chat"];
                [message addChild:body];
                NSString *to = [NSString stringWithFormat:@"%@@eueung-mulyanas-imac.local",mobileNumber];
                [message addAttributeWithName:@"to" stringValue:to];
                
                [[self appDelegate].xmppStream sendElement:message];
                
            }else if (iphoneNumber){
                // send message through XMPP
                NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
                [body setStringValue:theMessage];
                NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                [message addAttributeWithName:@"type" stringValue:@"chat"];
                [message addChild:body];

                NSString *to = [NSString stringWithFormat:@"%@@eueung-mulyanas-imac.local",iphoneNumber];
                [message addAttributeWithName:@"to" stringValue:to];
                [[self appDelegate].xmppStream sendElement:message];
            }
            
        }
        [self sendMessageFinish];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
