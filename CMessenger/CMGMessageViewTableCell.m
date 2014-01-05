//
//  CMGMessageViewTableCell.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "CMGMessageViewTableCell.h"

@implementation CMGMessageViewTableCell

@synthesize senderAndTimeLabel, messageContentView, bgImageView, bgImageView2,bgImageView3;
@synthesize viewItem;
@synthesize senderInGroup;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
		senderAndTimeLabel = [[UILabel alloc] init];//]WithFrame:CGRectMake(10, 5, 300, 20)];
		senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
		senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
		senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        senderAndTimeLabel.backgroundColor= [UIColor clearColor];
        [senderAndTimeLabel sizeToFit];
		//[self.contentView addSubview:senderAndTimeLabel];
		
		bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:bgImageView];
		
		messageContentView = [[UITextView alloc] init];
		messageContentView.backgroundColor = [UIColor clearColor];
		messageContentView.editable = NO;
		messageContentView.scrollEnabled = NO;
		[messageContentView sizeToFit];
		[self.contentView addSubview:messageContentView];
        
        //
        senderInGroup = [[UITextView alloc]init];
        senderInGroup.backgroundColor = [UIColor clearColor];
        senderInGroup.editable = NO;
        senderInGroup.scrollEnabled = NO;
        [senderInGroup sizeToFit];
        [self.contentView addSubview:senderInGroup];
        //
        
        bgImageView2 = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView2];
        [self.contentView addSubview:senderAndTimeLabel];
        
        bgImageView3 = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView3];
        
        viewItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[viewItem setTitle:@"View" forState:UIControlStateNormal];
        [viewItem setFrame:CGRectZero];
        [self.contentView addSubview:viewItem];
    }
	
    return self;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
