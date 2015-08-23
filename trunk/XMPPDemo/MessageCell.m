//
//  MessageCell.m
//  XMPPDemo
//
//  Created by robin on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"



@implementation MessageCell
@synthesize senderAndTimeLabel;
@synthesize messageContentView;
@synthesize bgImageView;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //日期标签
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 637, 20)];
        //居中显示
        senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
       // senderAndTimeLabel.font = [UIFont fontWithName:@"AriaUnicodeMS" size:12.0];
       senderAndTimeLabel.font = [UIFont systemFontOfSize:12.0];
    //    senderAndTimeLabel.font.name = @"AriaUnicodeMS";
        //文字颜色
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:senderAndTimeLabel];
        
        //背景图
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        
        //聊天信息
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        //不可编辑
        messageContentView.editable = NO;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
       // messageContentView.autoresizingMask =UIViewAutoresizingFlexibleHeight;
        //messageContentView.font = [UIFont fontWithName:@"AriaUnicodeMS" size:14.0];
        [self.contentView addSubview:messageContentView];
        
    }
    
    return self;
    
}


/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
