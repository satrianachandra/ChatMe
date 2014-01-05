//
//  CMGViewImageController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 5/16/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMGViewImageController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) NSData* theImage;

- (IBAction)cancel:(id)sender;
@end
