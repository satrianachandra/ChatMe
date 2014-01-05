//
//  CMGViewImageController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 5/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGViewImageController.h"

@implementation CMGViewImageController
@synthesize imageView;
@synthesize theImage;

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
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self.imageView setImage:[UIImage imageWithData:self.theImage]];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
