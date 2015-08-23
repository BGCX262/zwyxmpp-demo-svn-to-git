//
//  ZWYMasterViewController.h
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ZWYDetailViewController;

@interface ZWYMasterViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    UITableView *tView;
    UIBarButtonItem *addBuddy;
    UIBarButtonItem *addButton;
    UIBarButtonItem *loginButton;
}


@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) ZWYDetailViewController *detailViewController;
- (IBAction)loginPressed:(id)sender;
- (IBAction)settingPressed:(id)sender;

- (IBAction)addBuddy:(id)sender;
- (IBAction)registerNewUser:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
