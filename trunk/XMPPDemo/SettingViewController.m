//
//  SettingViewController.m
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "RegisterViewController.h"
#import "ZWYMasterViewController.h"

@implementation SettingViewController
@synthesize jidField;
@synthesize passwordField;
@synthesize masterViewController;


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
    [self setJidField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    jidField.text = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPmyJID];
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPmyPassword];
}

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)settingDone:(id)sender {
    
    if (jidField.text.length>0 && passwordField.text.length>0)
    {
        [self setField:jidField forKey:XMPPmyJID];
        [self setField:passwordField forKey:XMPPmyPassword];
        
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入JID和密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil   , nil];
        [alert show];
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [jidField resignFirstResponder];
    [passwordField resignFirstResponder];
    //TODO:
    /*if (jidField.text != nil && passwordField != nil)
    {
        [self settingDone:sender];
    }*/
}

@end
