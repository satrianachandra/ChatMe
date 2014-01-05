//
//  CMGMessageViewTableCell.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMGMessageViewTableCell : UITableViewCell
{

}

@property (strong,nonatomic) UILabel *senderAndTimeLabel;
@property (strong,nonatomic) UITextView *messageContentView;

@property (strong,nonatomic)UITextView *senderInGroup;

@property (strong,nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *bgImageView2;
@property (strong, nonatomic) UIImageView *bgImageView3;
@property (strong, nonatomic) UIButton *viewItem;
//@property (strong,nonatomic) UIImageView *itemView;
@end
