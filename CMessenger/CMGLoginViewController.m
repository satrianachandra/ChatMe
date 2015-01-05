//
//  CMGLoginViewController.m
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import "CMGLoginViewController.h"
#import "SVProgressHUD.h"

@implementation CMGLoginViewController
@synthesize loginField;
@synthesize phoneNumberField;
@synthesize pickerView;
@synthesize scrollView;
@synthesize passwordField;
@synthesize delegate;
@synthesize countryCode;
@synthesize offset_x,offset_y;
@synthesize username,password;

- (void)awakeFromNib {
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
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
    //[self registerForKeyboardNotifications];
    
}

- (void)viewDidUnload
{
    [self setLoginField:nil];
    [self setPasswordField:nil];
    [self setPhoneNumberField:nil];
    [self setScrollView:nil];
    [self setPickerView:nil];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CMGAppDelegate *)appDelegate {
	return (CMGAppDelegate *)[[UIApplication sharedApplication] delegate];
}


// method for registering the phonenumber
- (IBAction)login:(id)sender {
    
    self.username = [NSString stringWithFormat:@"%@%@",[NSString removeLeadingZeros:[self.countryCode text]],[NSString removeLeadingZeros:[self.phoneNumberField text]]];
    
    
    self.password = [[UIDevice currentDevice]uniqueDeviceIdentifier];
    
    
    //send this user&pass to the server, for adding the user
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://wien.ee.itb.ac.id/openfire/adduser.php"]];
    //ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.102/openfire/adduser.php"]];
    [request setPostValue:self.username forKey:@"username"];
    [request setPostValue:self.password forKey:@"password"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
    
    
    [SVProgressHUD showWithStatus:@"Registering.."];
    
    
    
    /*
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@",username,serverDomain] forKey:@"kXMPPmyJID"];
    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:@"kXMPPmyPassword"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //register user
    [[[self appDelegate] xmppStream ]setMyJID:[XMPPJID jidWithString:username]];
    [[[self appDelegate]xmppStream] registerWithPassword:pass error:nil];
     
     */
    
    
   /*
    [[NSUserDefaults standardUserDefaults] setObject:@"chandra5@eueung-mulyanas-imac.local" forKey:@"kXMPPmyJID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"chandra5" forKey:@"kXMPPmyPassword"];
    
     [self.delegate loginViewControllerDidFinish:self];
    NSLog(@"username: %@ \n pass: %@",username,pass);
    */
      
}


- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSLog(@"response: |%@|",response);
    // response contains the HTML response from the form.
    
    
    //NSString *serverDomain = @"@eueung-mulyanas-imac.local";
    NSString *serverDomain = @"@167.205.64.96";
    
    if([response isEqualToString:@"<result>ok</result>\n"]){
        //registrasi user berhasil
        serverDomain = @"@eueung-mulyanas-imac.local";
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@",self.username,serverDomain] forKey:@"kXMPPmyJID"];
        [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:@"kXMPPmyPassword"];
        [SVProgressHUD dismissWithSuccess:@"Registration Success" afterDelay:2];
        
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showMain:) userInfo:nil repeats:NO];
        
        
        
    }
    else {//if ([response isEqualToString:@"<error>UserAlreadyExistsException</error>"]){
        NSLog(@"the username already exist, same sim card used in different device?");
        [SVProgressHUD dismissWithError:@"This account already registered" afterDelay:2];
        
    }
    
}

-(void)showMain:(NSTimer *)theTimer{
    [self.delegate loginViewControllerDidFinish:self];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"failed. connection problem");
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
      //                                                  message:@"Please check your internet connection" 
        //                                               delegate:nil 
        //                                      cancelButtonTitle:@"Ok" 
        //                                      otherButtonTitles:nil];
    //[alertView show];
    [SVProgressHUD dismissWithError:@"Connection Problem" afterDelay:2];
}

-(IBAction)backgroundTap:(id)sender{
    [self.phoneNumberField resignFirstResponder];
    [self.countryCode resignFirstResponder];
}

- (IBAction)textEditingDidDone:(id)sender {
    [sender resignFirstResponder];
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
    
       
    if (([countryCode isFirstResponder] || [phoneNumberField isFirstResponder]) && self.view.frame.origin.y >= 0)
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
}

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    countryCode.text = code;
}


@end
