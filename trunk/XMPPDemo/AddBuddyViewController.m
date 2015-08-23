//
//  AddBuddyViewController.m
//  XMPPDemo
//
//  Created by robin on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AddBuddyViewController.h"
#import "ZWYAppDelegate.h"

@implementation AddBuddyViewController
@synthesize userJid;
@synthesize appDelegate;
@synthesize nickName;
@synthesize group;

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
    [self setUserJid:nil];
    [self setAppDelegate:nil];
    [self setNickName:nil];
    [self setGroup:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addBuddy:(id)sender {
    if (userJid.text != nil)
    {
        if (nickName.text == nil)
            nickName.text = [[XMPPJID jidWithString:userJid.text] bare];
        [[[self appDelegate] xmppRoster] addUser:[XMPPJID jidWithString: userJid.text] withNickname:nickName.text];
        
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)cancellAdd:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
