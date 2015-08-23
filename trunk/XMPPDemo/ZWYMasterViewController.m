//
//  ZWYMasterViewController.m
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZWYMasterViewController.h"

#import "ZWYDetailViewController.h"
#import "ZWYAppDelegate.h"
#import "SettingViewController.h"
#import "AddBuddyViewController.h"
#import "RegisterViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ZWYMasterViewController()
{
@private
    NSMutableArray *onlineUsers;
    UILabel *titleLabel;
}
-(void) setTitleLabel:(NSString *)title;
@end

@implementation ZWYMasterViewController
@synthesize addButton;



@synthesize loginButton;
@synthesize tView;
@synthesize detailViewController = _detailViewController;


- (ZWYAppDelegate *)appDelegate
{
	return (ZWYAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    [[self detailViewController].sendContent resignFirstResponder];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    onlineUsers = [NSMutableArray array];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (ZWYDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
   // [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    // add tap gesture recognizer
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] 
                                             initWithTarget:self 
                                             action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setAddButton:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    titleLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setTitleLabel:(NSString *)title
{
    titleLabel.text = title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (titleLabel == nil)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.numberOfLines = 1;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleLabel.textAlignment = UITextAlignmentCenter;
    }
    
	if ([[self appDelegate] connect]) 
	{
		titleLabel.text = [[[[self appDelegate] xmppStream] myJID] bare];
	} else
	{
		titleLabel.text = @"No JID";
	}
	
	[titleLabel sizeToFit];
    
	self.navigationItem.titleView = titleLabel;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[self appDelegate] isConnected])
        [loginButton setTitle:@"登出"];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	[super viewWillDisappear:animated];
    [[self   appDelegate] disconnect];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
}

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	} 
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
		{
            //NSString *name = user.sectionName;
           // NSLog(@"%@", name);
            switch (user.section) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"online"];
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"away"];
                    break;                    
                default:
                    cell.imageView.image = [UIImage imageNamed:@"offline"];
                    break;
            }
            
        }
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

#pragma mark UITableViewDataSource
/*
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [onlineUsers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
	}
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	cell.textLabel.text = user.displayName;
   // NSLog(@"************%@ -- %d", user.displayName, user.section);
   // NSUInteger index;
   // [indexPath getIndexes:&index];
	[self configurePhotoForCell:cell user:user];
	
	return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   // NSString *charUserName = user.displayName;
    [[self detailViewController] setChatWithUser:user.jidStr];
    [self detailViewController].chatPeer.text = user.displayName;
    NSString *name = [[NSString alloc] initWithFormat:@"face%d", user.section+1];
    [self detailViewController].peerFace.image = [UIImage imageNamed:name];
    [[self detailViewController] readFromDatabase];
    [[self detailViewController].msgView reloadData];
    [[self detailViewController] chatTableScrollToBottom];
}

- (IBAction)loginPressed:(id)sender {
    if (loginButton.title == @"登录")
    {
        if ([[self appDelegate] connect]) 
        {
            [self setTitleLabel:[[[[self appDelegate] xmppStream] myJID] bare]];
            [loginButton setTitle:@"登出"];
        }
    }
    else
    {
        [[self appDelegate] disconnect];
        [loginButton setTitle:@"登录"];
        [self setTitleLabel:@""];
    }
}

- (IBAction)settingPressed:(id)sender {
    [[self appDelegate] disconnect];
    [self setTitleLabel:@""];
    [loginButton setTitle:@"登录"];
    SettingViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"SettingView"];
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [controller setModalPresentationStyle:UIModalPresentationFormSheet];
    [controller setMasterViewController:self];
    [self presentModalViewController:controller animated:YES];
    
    controller.view.superview.frame = CGRectMake(0, 0, 354, 302);
    controller.view.superview.center = CGPointMake(512, 374);
}

- (IBAction)addBuddy:(id)sender {    
   
   AddBuddyViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"AddBuddyView"];

    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [controller setModalPresentationStyle:UIModalPresentationFormSheet];
       controller.appDelegate = [self appDelegate];
    [self presentModalViewController:controller animated:YES];
    controller.view.superview.frame = CGRectMake(0, 0, 372, 336);
    controller.view.superview.center = CGPointMake(512, 374);
}

- (IBAction)registerNewUser:(id)sender {
    RegisterViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"RegisterView"];
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [controller setModalPresentationStyle:UIModalPresentationFormSheet];
    [controller setDelegate:[self appDelegate]];
    [self presentModalViewController:controller animated:YES];
    controller.view.superview.frame = CGRectMake(0, 0, 377, 354);
    controller.view.superview.center = CGPointMake(512, 374);
}

@end
