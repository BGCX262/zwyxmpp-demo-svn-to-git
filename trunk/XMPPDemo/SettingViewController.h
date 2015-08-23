//
//  SettingViewController.h
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const XMPPmyJID;
extern NSString *const XMPPmyPassword;
@class ZWYMasterViewController;

@interface SettingViewController : UIViewController {
    UITextField *jidField;
    UITextField *passwordField;
}

@property (strong, nonatomic) IBOutlet UITextField *jidField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) ZWYMasterViewController *masterViewController;

- (IBAction)settingDone:(id)sender;
- (IBAction)hideKeyboard:(id)sender;


@end
