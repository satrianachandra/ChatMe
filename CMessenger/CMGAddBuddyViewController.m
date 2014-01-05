//
//  CMGAddBuddyViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/20/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGAddBuddyViewController.h"

@implementation CMGAddBuddyViewController
@synthesize navBar;
@synthesize buddyName;
@synthesize alertView;

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
    self.title = @"Add Buddy";
    [self appDelegate]._addBuddyProcessDelegate = self;
}

- (void)viewDidUnload
{
    [self setBuddyName:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addBuddy:(id)sender {
    XMPPJID *userjid = [XMPPJID jidWithString:[buddyName text]];
    [[[self appDelegate] xmppRoster]  addUser:userjid withNickname:nil];
    //[self appDelegate]
    
    
    XMPPUserCoreDataStorageObject *user = [[[self appDelegate] xmppRosterStorage] userForJID:userjid
                                                             xmppStream:[[self appDelegate]xmppStream]
                                                   managedObjectContext:[[self appDelegate] managedObjectContext_roster]];
    
    //if (user != nil){
    if (user.isPendingApproval){
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Succesful"
                                                    message:[NSString stringWithFormat:@"Buddy request sent to %@",buddyName.text]
                                                   delegate:nil 
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
        [self.alertView show];
    }else{
        NSLog(@"user not pending");
    }
    //}
    //[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)textFieldDoneEditing:(id)sender{
    [sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender{
    [[self buddyName] resignFirstResponder];
}

- (void)addBuddyProcessWithJID:(XMPPJID *)thejid success:(BOOL)isSuccess{
    if ( [buddyName.text isEqualToString:[thejid bare]] ){
        //if (isSuccess == NO){
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Error"
		                                                    message:[NSString stringWithFormat:@"%@ doesn't exist",buddyName.text]
		                                                   delegate:nil 
		                                          cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK",nil];
            [self.alertView show];
        self.alertView = nil;
            //self.buddyName.text=@"";
        //}else{ //berhasil
            
        //}
    }
}

@end
