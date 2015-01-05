//
//  CMGViewMapController.h
//  CMessenger
//
//  Created by Chandra Satriana on 5/16/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344


@interface CMGViewMapController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;
@property (assign,nonatomic) CLLocationDegrees theLat;
@property (assign,nonatomic) CLLocationDegrees theLongitude;


- (IBAction)cancel:(id)sender;

@end
