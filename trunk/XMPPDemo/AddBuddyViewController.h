//
//  AddBuddyViewController.h
//  XMPPDemo
//
//  Created by robin on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ZWYAppDelegate;
@interface AddBuddyViewController : UIViewController {
    UITextField *userJid;
    UITextField *nickName;
    UITextField *group;
}

@property (strong, nonatomic) IBOutlet UITextField *userJid;
@property (strong, nonatomic) ZWYAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITextField *nickName;
@property (strong, nonatomic) IBOutlet UITextField *group;

- (IBAction)addBuddy:(id)sender;
- (IBAction)cancellAdd:(id)sender;
@end
