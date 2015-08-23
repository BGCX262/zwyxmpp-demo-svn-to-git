//
//  RegisterViewController.h
//  XMPPDemo
//
//  Created by robin on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZWYAppDelegate;

@interface RegisterViewController : UIViewController {
    UITextField *user;
    UITextField *password;
    UITextField *rePassword;
    UITextField *server;
    UIButton *close;
    ZWYAppDelegate *delegate;
}

@property (strong, nonatomic) IBOutlet UITextField *user;

@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *rePassword;
@property (strong, nonatomic) IBOutlet UITextField *server;
@property (strong, nonatomic) ZWYAppDelegate *delegate;
- (IBAction)createUser:(id)sender;
- (IBAction)close:(id)sender;

@end
