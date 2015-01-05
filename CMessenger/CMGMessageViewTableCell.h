//
//  CMGMessageViewTableCell.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/11/12.
//  Copyright (c) 2012 Chandra Satriana.
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
