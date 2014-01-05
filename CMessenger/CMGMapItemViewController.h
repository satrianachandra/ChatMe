//
//  CMGMapItemViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 3/12/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CMGMapItemViewController : UIViewController<MKMapViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)cancel:(id)sender;
- (IBAction)textFieldShouldReturn:(id)sender;

@end
