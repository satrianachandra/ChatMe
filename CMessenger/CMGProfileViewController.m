//
//  CMGProfileViewController.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGProfileViewController.h"

#import "XMPPFramework.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@implementation CMGProfileViewController
@synthesize tView;



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

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Status";
    
    if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status"
		                                          inManagedObjectContext:moc];
		
		//NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"inuse" ascending:NO];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects: sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"inuse"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
        if ([[fetchedResultsController fetchedObjects]count]<1){
            //populate the status core data with default status
            
            //1.Available
            Status *status = (Status *)[NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:moc];
            status.type = @"available";
            status.show = @"chat";
            status.status = @"Available";
            status.inuse = @"yes";
            
            NSError *error;
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }
            
            
            //2. On CMessenger
            status = (Status *)[NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:moc];
            status.type = @"available";
            status.show = @"chat";
            status.status = @"On CMessenger";
            status.inuse = @"no";
            
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }
            
            //3. Coding til Death
            status = (Status *)[NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:moc];
            status.type = @"available";
            status.show = @"chat";
            status.status = @"Coding til Death";
            status.inuse = @"no";
            
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }

            //3. Coding til Death
            status = (Status *)[NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:moc];
            status.type = @"available";
            status.show = @"chat";
            status.status = @"walking down the stairs";
            status.inuse = @"no";
            
            // here's where the actual save happens, and if it doesn't we print something out to the console
            if (![moc save:&error])
            {
                NSLog(@"Problem saving: %@", [error localizedDescription]);
            }
 

            
        }
        
        
	}

    
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSFetchedResultsController *)fetchedResultsController
{
    
    
    return fetchedResultsController;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tView] reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	/*
    NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];

		NSString *section = sectionInfo.name;
		if ([section isEqualToString:@"yes"]){
            return @"Your current status is";
        }else{
            return @"Change your status to:";
        }
       
	}
	*/
    if (sectionIndex == 0){
        return @"Your current status is";
    }else{
        return @"Change your status to";
    }
    
	return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
	}
	
	Status *status = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = status.status;
	
    if (indexPath.section==0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
	
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMGStatusDetailViewController *controller = [[CMGStatusDetailViewController alloc] initWithNibName:@"CMGStatusDetailViewController" bundle:nil];

    Status *status = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    controller.status = status;
    if (indexPath.section ==0){
        controller.current = YES;
    }else{
        controller.current = NO;
    }
    controller.currentStatus= [[fetchedResultsController fetchedObjects]objectAtIndex:0];
    [self.navigationController pushViewController:controller animated:YES]; 

}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        if (!(indexPath.section ==0)){
		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        }
    }   
}


-(void)goOnline
{
    //called when app first launched
    Status *stat = [[fetchedResultsController fetchedObjects]objectAtIndex:0]; 
    NSXMLElement *presence2 = [NSXMLElement 
                               elementWithName:@"presence"]; 
    NSXMLElement *show2 = [NSXMLElement elementWithName:@"show"]; 
    NSXMLElement *status2 = [NSXMLElement 
                             elementWithName:@"status"]; 
    
    //Query from core data, the user's current status
    
    [show2 setStringValue:stat.show]; 
    [status2 setStringValue:stat.status]; 
    [presence2 addChild:show2]; 
    [presence2 addChild:status2]; 
    //[ [self xmppStream] sendElement:presence];
    
    [[[self appDelegate] xmppStream] sendElement:presence2];
    
}



@end
