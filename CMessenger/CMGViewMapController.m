//
//  CMGViewMapController.m
//  CMessenger
//
//  Created by Eueung Mulyana on 5/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGViewMapController.h"

@implementation CMGViewMapController
@synthesize mapView;
@synthesize theLat;
@synthesize theLongitude;

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

- (void)viewWillAppear:(BOOL)animated {  
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.theLat;
    zoomLocation.longitude= self.theLongitude;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];                
    // 4
    [self.mapView setRegion:adjustedRegion animated:YES];      
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
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
