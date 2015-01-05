//
//  CMGViewImageController.h
//  CMessenger
//
//  Created by Chandra Satriana on 5/16/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <UIKit/UIKit.h>

@interface CMGViewImageController : UIViewController
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) NSData* theImage;

- (IBAction)cancel:(id)sender;
@end
