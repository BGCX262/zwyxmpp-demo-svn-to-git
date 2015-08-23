//
//  ZWYDetailViewController.h
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class ZWYAppDelegate;

@interface ZWYDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    UITableView *_msgView;
    UITextField *_sendContent;
    UILabel *_chatPeer;
    UIImageView *_peerFace;
    UIButton *_sendButton;
}

//@property (strong, nonatomic) ZWYAppDelegate *appDelegate;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UILabel *chatPeer;
@property (strong, nonatomic) IBOutlet UIImageView *peerFace;

@property (strong, nonatomic) IBOutlet UITextField *sendContent;
@property (strong, nonatomic) IBOutlet UITableView *msgView;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property(nonatomic, strong) NSString *chatWithUser;

- (void)readFromDatabase;
- (void) chatTableScrollToBottom;

- (void) receivedMessage;
- (IBAction)resignKeyboard:(id)sender;
- (NSString *) substituteEmoticons;
@end
