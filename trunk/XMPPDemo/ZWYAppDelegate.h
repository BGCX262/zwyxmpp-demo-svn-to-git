//
//  ZWYAppDelegate.h
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "XMPPFramework.h"
#import "ZWYDetailViewController.h"

@class AppDatabase;

@interface ZWYAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
{
    XMPPStream *xmppStream;
    NSString *password;
    
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;

    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    
    BOOL isXmppConnected; 
    BOOL isConnected;
}

@property (nonatomic, strong) AppDatabase *database;
@property (nonatomic, strong) ZWYDetailViewController *detailViewController;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) BOOL isConnected;

@property (strong, nonatomic) UIWindow *window;

- (BOOL)connect;
- (void)disconnect;
- (NSManagedObjectContext *)managedObjectContext_roster;
@end
