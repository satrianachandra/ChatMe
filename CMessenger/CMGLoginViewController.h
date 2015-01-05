//
//  CMGLoginViewController.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/8/12.
//  Copyright (c) 2012 Chandra Satriana.
//


#import <UIKit/UIKit.h>
#import "NSString+Utils.h"
#import "NSString+MD5Addition.m"
#import "UIDevice+IdentifierAddition.h"
#import "XMPPJID.h"
#import "CMGAppDelegate.h"
#import "CMGLoginViewControllerDelegate.h"

#import "ASIFormDataRequest.h"
#import "CountryPicker.h"

@class CMGAppDelegate;

@protocol LoginViewControllerDelegate;


@interface CMGLoginViewController : UIViewController<UITextFieldDelegate,CountryPickerDelegate>
{
    UITextField *activeField;
   
}

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordField;
@property (unsafe_unretained,nonatomic) id <CMGLoginViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *countryCode;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *loginField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *pickerView;





@property (copy,nonatomic) NSString * username;
@property (copy,nonatomic) NSString * password;


@property (assign,nonatomic) CGFloat offset_x;
@property (assign,nonatomic) CGFloat offset_y;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)login:(id)sender;
-(IBAction)backgroundTap:(id)sender;

- (IBAction)textEditingDidDone:(id)sender;
//- (void)registerForKeyboardNotifications;

- (CMGAppDelegate *)appDelegate;

@end

