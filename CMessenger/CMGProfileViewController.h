//
//  CMGProfileViewController.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/8/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMGAppDelegate.h"
#import "Status.h"
#import "CMGStatusDetailViewController.h"

@interface CMGProfileViewController : UITableViewController<NSFetchedResultsControllerDelegate>{
    
    NSFetchedResultsController *fetchedResultsController;
    
    
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tView;

@end
