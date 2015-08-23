//
//  RegisterViewController.m
//  XMPPDemo
//
//  Created by robin on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "ZWYAppDelegate.h"

@implementation RegisterViewController
@synthesize user;
@synthesize password;
@synthesize rePassword;
@synthesize server;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setUser:nil];
    [self setPassword:nil];
    [self setRePassword:nil];
    [self setServer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)createUser:(id)sender {
    if (user.text == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不合法" 
		                                                    message:@"用户名不能为空" 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
        return;
    }
    if (![password.text isEqualToString:rePassword.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不合法" 
		                                                    message:@"密码输入不一致" 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
        return;
    }
    NSString *jid = [[NSString alloc] initWithFormat:@"%@@%@", user.text, server.text];
    [[delegate xmppStream] setMyJID:[XMPPJID jidWithString:jid]];
    NSError *error=nil;
    if (![[delegate xmppStream] registerWithPassword:password.text error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败" 
		                                                    message:[error localizedDescription]
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
        [alertView show];
    }
    [self dismissModalViewControllerAnimated:YES];
 
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
