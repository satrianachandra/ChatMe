//
//  CMGStatusDetailViewController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 3/1/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGStatusDetailViewController.h"

@implementation CMGStatusDetailViewController
@synthesize textField;
@synthesize status;
@synthesize current;
@synthesize currentStatus;
@synthesize updateStatus;

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
    self.navigationItem.title = @"Status";
    self.textField.text = status.status;
    [self.textField becomeFirstResponder];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = saveButton;
	
    if ([status.status isEqualToString:currentStatus.status]){
        updateStatus.hidden = YES;
    }
    
    
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [self setUpdateStatus:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

-(void)sendStatusWithType:(NSString *)type theShow:(NSString *)show theStatus:(NSString *)thestatus{
    NSXMLElement *presence2 = [NSXMLElement 
                              elementWithName:@"presence"]; 
    NSXMLElement *show2 = [NSXMLElement elementWithName:@"show"]; 
    NSXMLElement *status2 = [NSXMLElement 
                            elementWithName:@"status"]; 
    
    //Query from core data, the user's current status
    
    [show2 setStringValue:show]; 
    [status2 setStringValue:thestatus]; 
    [presence2 addChild:show2]; 
    [presence2 addChild:status2]; 
    //[ [self xmppStream] sendElement:presence];
    
    [[[self appDelegate] xmppStream] sendElement:presence2];
    
} 

- (IBAction)save {
	//save data to Status Core Data
	// if editing current status, the old status's inuse is set to NO, and inserting the new status into core data
    
    if (!([textField.text isEqualToString:status.status])){
        
    
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];    
    
    if (self.current){
        Status *statusToSave = (Status *)[NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:moc];
        statusToSave.type = @"available";
        statusToSave.show = @"chat";
        statusToSave.status = textField.text;
        statusToSave.inuse = @"yes";
        
        self.status.inuse = @"no";
        
        [self sendStatusWithType:@"available" theShow:@"chat" theStatus:textField.text];
        
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }else{
        //if not editing the current status, just update it
        self.status.status = textField.text;
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
    }
    
    }
    
	//back to previous screen
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)updateStatus:(id)sender {
    //do sth only if there's change
    
    
    //if (!([textField.text isEqualToString:status.status])){
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext];    
        
        //save the status and set inuse
        self.status.type = @"available";
        self.status.show = @"chat";
        self.status.status = textField.text;
        self.status.inuse = @"yes";
        
        self.currentStatus.inuse = @"no";
        
        
        NSError *error;
        // here's where the actual save happens, and if it doesn't we print something out to the console
        if (![moc save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
        
    //}
    [self sendStatusWithType:@"available" theShow:@"chat" theStatus:textField.text];
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
