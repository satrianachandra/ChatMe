//
//  CMGChatsViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGChatsViewController.h"
#import "CMGChattingViewGroupChatController.h"
#import "ChatRoom.h"
#import "XMPPFramework.h"
#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif



@implementation CMGChatsViewController

@synthesize tView;
@synthesize _chatsToChattingDelegate;
@synthesize isAppearing;
//@synthesize fetchedResultsController;

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
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Chats";

    
	CMGAppDelegate *del = [self appDelegate];
	del._activeChatDelegate = self;
    moc = [[self appDelegate] managedObjectContext];
    
 
    //fill the room array
    if ([[self appDelegate ].roomArray count]<1){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"ChatRoom" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
                
        NSError *error;
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count]>0){
            for (ChatRoom *cr in fetchedObjects){
                NSString *roomName = cr.name;
                [self.appDelegate newRoomWithName:roomName];
            }
        }
        //
    }
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //if ([self isBeingPresented]){
        self.isAppearing=YES;
    //}
    NSInteger badgeVal = [self.navigationController.tabBarItem.badgeValue integerValue];
    if (badgeVal >0){
        self.navigationController.tabBarItem.badgeValue = nil;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isAppearing = NO;
}

- (void)viewDidUnload
{
    //save chats do core data
    
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//table stuffs
///////////////////////////////////////////
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
        moc = [[self appDelegate] managedObjectContext];
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
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

-(NSString *)getUser:(NSString *)jidStr{
    return [[jidStr componentsSeparatedByString:@"@"] objectAtIndex:0];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellChats";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //ChatWith *chatwith = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //ChatWith *chatwith= [[[self fetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    NSArray *cwArray = [[self fetchedResultsController]fetchedObjects];
    if ([cwArray count]>0){
    ChatWith *chatwith= [cwArray objectAtIndex:[indexPath row]];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
    
    
    NSSet* chatwithSet = chatwith.messages;
    chatwithArray = [chatwithSet sortedArrayUsingDescriptors:sortDescriptors];
    if ([chatwithArray count] >0){
        MessagesInfo *messagesinfo = [chatwithArray objectAtIndex:([chatwithArray count]-1)]; 
        cell.textLabel.text = messagesinfo.message;
        if ([messagesinfo.to isEqualToString:@"groupchat"]){
            cell.detailTextLabel.text = @"Groupchat";
            return cell;
        }
        
    }
    
    NSString *num = [[[self appDelegate]contactsViewController]getNameByNumber:[self getUser:chatwith.name]];
    if (num){
        cell.detailTextLabel.text = num;
    }
    }
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self fetchedResultsController] fetchedObjects] count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
/////////////////////////////////////////////

/////////////////////////////////////////////

- (void)newMessageReceived:(NSDictionary *)messageContent{
    NSString *m = [messageContent objectForKey:@"msg"];
    NSString *sender = [messageContent objectForKey:@"sender"];
    NSString *isLocInfo = [messageContent objectForKey:@"isLocationInfo"];
    
    NSData *item = [messageContent objectForKey:@"item"];	
	//[messageContent setObject:[m substituteEmoticons] forKey:@"msg"];
	//[messageContent setObject:[NSString getCurrentTime] forKey:@"time"];

    //prepare the message to save:
    
    MessagesInfo *themessage = (MessagesInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MessagesInfo" inManagedObjectContext:moc];
    themessage.message = m;
    themessage.from = sender;
    themessage.to = @"me";
    themessage.date = [NSDate date];
    
    if (item){
        themessage.item = item;
        NSLog(@"item lengthnya: %d",[item length]);
    }
    
    if (isLocInfo){
        NSArray *LatLong = [m componentsSeparatedByString:@"|"];
        [themessage setLatitudeScalar:[[LatLong objectAtIndex:0]doubleValue]];
        //themessage.isLocation = YES;
        [themessage setIsLocationScalar:YES];
        [themessage setLongitudeScalar:[[LatLong objectAtIndex:1]doubleValue]];
        themessage.message = @"";
        NSLog(@"theMess longitude: %f",[themessage longitudeScalar]);
    }
    
    NSArray *fetched= [self fetchedResultsController].fetchedObjects;
    
    //traverse the array, see if chatwith with name=sender already exist?
    BOOL found=NO;
    int i=0;
    ChatWith *chatwith;
    
    if  ([fetched count]>0){
        while(!found && i< [fetched count]){
            chatwith = [fetched objectAtIndex:i];
            if ([chatwith.name isEqualToString:sender] ){
                found = YES;
            }
            i++;
        }
    }
    
    if (!found){
        //kalau belum ada yang sama, berarti ditambahin baru
        ChatWith *chatwith2 = (ChatWith *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatWith" inManagedObjectContext:moc];
        chatwith2.name = sender;
        chatwith2.isactive =YES;
        
        [chatwith2 addMessagesObject:themessage];
    
    }else{
    //berarti udah ada, langsung ditambahin ke messagenya;
        themessage.chatwith = chatwith;
    }
    
    NSError *error;
        
    // here's where the actual save happens, and if it doesn't we print something out to the console
    if (![moc save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
        
    //[[self tView] reloadData];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ChatWith *chatwith = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSArray *comp = [chatwith.name componentsSeparatedByString:@"|"];
    if ([comp count]>1){
        //this is a groupchat entry
        CMGChattingViewGroupChatController *groupChatController = [[CMGChattingViewGroupChatController alloc]initWithUser:chatwith];
        [self presentModalViewController:groupChatController animated:YES];
    }else{
    
        //call another delegate to supply the buddyJIDStr
        //[self._chatsToChattingDelegate selectedUser:buddyJIDStr];
    
        CMGChattingViewController *chatController = [[CMGChattingViewController alloc] initWithUser:chatwith ];
        //chatController.messag
        [self presentModalViewController:chatController animated:YES];
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tView] reloadData];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
       
        // Delete the managed object.
        NSManagedObjectContext *context = [[self fetchedResultsController] managedObjectContext];
        //ChatWith *chatWithToDelete = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        //ChatWith *chatWithToDelete = [self fetchedResultsController]objectAtIndexPath:
        ChatWith *chatWithToDelete;
        
         NSArray *cwArray = [[self fetchedResultsController]fetchedObjects];
         if ([cwArray count]>1){
             chatWithToDelete= [cwArray objectAtIndex:[indexPath row]];
         }else if ([cwArray count]==1){
             chatWithToDelete = [cwArray objectAtIndex:0];
         }
         
        NSArray *comp = [chatWithToDelete.name componentsSeparatedByString:@"|"];
        if ([comp count]>1){
            //this is a groupchat entry
            
            //leave the room & deactivate
            for (XMPPRoom *xr in [self appDelegate].roomArray){
                if ([[xr.roomJID user]isEqualToString:chatWithToDelete.name]){
                    [xr leaveRoom];
                    [xr removeDelegate:[self appDelegate]];
                    [xr deactivate];
                    [[self appDelegate].roomArray removeObject:xr];
                    break;
                }
            }
            
            //delete from ChatRoom entity
            NSString *roomName = [[[comp objectAtIndex:1]componentsSeparatedByString:@"@"]objectAtIndex:0];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription 
                                           entityForName:@"ChatRoom" inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            [NSPredicate predicateWithFormat:@"name contains[cd] %@", roomName];
            
            NSError *error;
            NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
            if ([fetchedObjects count]>0){
                for (ChatRoom *cr in fetchedObjects){
                    [context deleteObject:cr];
                }
            }

            //
        }
        [context deleteObject:chatWithToDelete ];
            
        NSError *error;
        if (![context save:&error]) {
                // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
      
    }   
}

- (void)messageDelivered:(NSDictionary *)response{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatWith" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name contains[cd] %@", [response valueForKey:@"sender"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count]>0){  
    ChatWith *cw = [fetchedObjects objectAtIndex:0];
    NSSet* chatwithSet = cw.messages;
    
    NSString *idNotif = [response valueForKey:@"id"];
    
    NSArray *chatArray = [chatwithSet allObjects];
    for(MessagesInfo *theMess in chatArray){
        //double interval = [theMess.date timeIntervalSince1970];
        if ( [idNotif isEqualToString:theMess.idMess] ){
            [theMess setDeliveredScalar:YES];
            NSError *error;
            
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }
            break;
        }
    }
    }
}


@end
