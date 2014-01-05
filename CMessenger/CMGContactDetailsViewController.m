//
//  CMGContactDetailsViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/29/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGContactDetailsViewController.h"


@implementation CMGContactDetailsViewController
@synthesize tView;
//@synthesize contactDictionary;
@synthesize name;
@synthesize mobileNumber;
@synthesize mobileStatus;
@synthesize iphoneNumber;
@synthesize iphoneStatus;
@synthesize photo;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int count=0;
    if (!([self mobileNumber] )){
        count++;
    }
    if (!([self iphoneNumber])){
        count++;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	if (!([self.mobileStatus isEqualToString:@""]) || ([self.iphoneStatus isEqualToString:@""])) {
        return 4; 
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
	}
	
    
    if(self.mobileNumber){
        if ([indexPath section] == 0){
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"mobile";
                    cell.detailTextLabel.text = self.mobileNumber;
                    break;
                case 1:
                    if ([self tableView:tableView numberOfRowsInSection:0]==4){
                        cell.textLabel.text=@"status";
                        cell.detailTextLabel.text =self.mobileStatus;
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Invite %@ to CMessenger",[[self.name componentsSeparatedByString:@" "]objectAtIndex:0]];
                        
                    }
                    break;
                case 2:
                    if ([self tableView:tableView numberOfRowsInSection:0]==4){
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"Chat with %@",self.name];
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Send SMS"];
                        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
                    }
                    break;
                case 3:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Add to Favorites"];
                    break;
                default:
                    break;
            }
        }
    }
    
    if(self.iphoneNumber){
        if ([indexPath section] == 0){
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"iphone";
                    cell.detailTextLabel.text = self.iphoneNumber;
                    break;
                case 1:
                    if ([self tableView:tableView numberOfRowsInSection:0]==4){
                        cell.textLabel.text=@"status";
                        cell.detailTextLabel.text =self.iphoneStatus;
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Invite %@ to CMessenger",[[self.name componentsSeparatedByString:@" "]objectAtIndex:0]];
                    }
                    break;
                case 2:
                    if ([self tableView:tableView numberOfRowsInSection:0]==4){
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"Chat with %@",self.name];
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Send SMS"];
                        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
                    }
                    break;
                case 3:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Add to Favorites"];
                    break;
                default:
                    break;
            }
        }
    }
    

    
    	
    
    
	return cell;
}

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

 if ([self tableView:tableView numberOfRowsInSection:0]==4){
 
 

    if (indexPath.row == 3){
        //add the user to Favorite entity
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];
        Favorite *fav = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
        if (self.mobileNumber){
            fav.number = [NSString stringWithFormat:@"%@@%@",self.mobileNumber,@"eueung-mulyanas-imac.local"];
            //fav.number = [NSString stringWithFormat:@"%@@%@",self.mobileNumber,@"wien.ee.itb.ac.id"];
            fav.status = self.mobileStatus;
        }else if (self.iphoneNumber){
            //fav.number = self.iphoneNumber;
            fav.number = [NSString stringWithFormat:@"%@@%@",self.iphoneNumber,@"eueung-mulyanas-imac.local"];
            fav.status = self.iphoneStatus;
        }
        fav.name = self.name;
        fav.photo = self.photo;
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
       
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"User added to Favorite" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }else if(indexPath.row == 2){
        NSLog(@"doing chat");
        if(self.mobileNumber){
            //XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController]objectAtIndexPath:indexPath];
            CMGChattingViewController *chatController = [[CMGChattingViewController alloc]  initWithUserName:[NSString stringWithFormat:@"%@@%@",self.mobileNumber,@"eueung-mulyanas-imac.local"] andNIB:@"CMGChattingViewController" bundle:nil];
            
            //CMGChattingViewController *chatController = [[CMGChattingViewController alloc]  initWithUserName:[NSString stringWithFormat:@"%@@%@",self.mobileNumber,@"wien.ee.itb.ac.id"] andNIB:@"CMGChattingViewController" bundle:nil];
            
            //
            // UINavigationController *chatControllerNav = [[UINavigationController alloc]initWithRootViewController:chatController]
            //
            [self presentModalViewController:chatController animated:YES];

        }else if(self.iphoneNumber){
            //XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController]objectAtIndexPath:indexPath];
            CMGChattingViewController *chatController = [[CMGChattingViewController alloc]  initWithUserName:[NSString stringWithFormat:@"%@@%@",self.iphoneNumber,@"eueung-mulyanas-imac.local"] andNIB:@"CMGChattingViewController" bundle:nil];
            
            //CMGChattingViewController *chatController = [[CMGChattingViewController alloc]  initWithUserName:[NSString stringWithFormat:@"%@@%@",self.iphoneNumber,@"wien.ee.itb.ac.id"] andNIB:@"CMGChattingViewController" bundle:nil];
            
            //
            // UINavigationController *chatControllerNav = [[UINavigationController alloc]initWithRootViewController:chatController]
            //
            [self presentModalViewController:chatController animated:YES];
        }

        
        
    }

    
 }else{
     if (indexPath.row==1){
         
         MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
         if([MFMessageComposeViewController canSendText])
         {
             controller.body = @"Bro, ada aplikasi baru bwt Chatting, keren banget, namanya ChatMe. Download di AppStore";
             if (self.mobileNumber){    
                 controller.recipients = [NSArray arrayWithObjects:self.mobileNumber, nil];
             }else if (self.iphoneNumber){
                 controller.recipients = [NSArray arrayWithObjects:self.iphoneNumber, nil];
             }else{
                 NSLog(@"nothing");
             }
             controller.messageComposeDelegate = self;
             [self presentModalViewController:controller animated:YES];
         }
         
     }else if (indexPath.row==2){
         MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
         if([MFMessageComposeViewController canSendText])
         {
             //controller.body = @"Hello from Mugunth";
             //controller.recipients = [NSArray arrayWithObjects:@"12345678", @"87654321", nil];
             if (self.mobileNumber){    
                 controller.recipients = [NSArray arrayWithObjects:self.mobileNumber, nil];
             }else if (self.iphoneNumber){
                 controller.recipients = [NSArray arrayWithObjects:self.iphoneNumber, nil];
             }else{
                 NSLog(@"nothing");
             }
             controller.messageComposeDelegate = self;
             [self presentModalViewController:controller animated:YES];
         }
     }
     
 }  
     
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultSent){
        [SVProgressHUD showSuccessWithStatus:@"Message sent"];
    }else if (result == MessageComposeResultFailed){
        [SVProgressHUD showErrorWithStatus:@"Error sending"];
    }
}



@end
