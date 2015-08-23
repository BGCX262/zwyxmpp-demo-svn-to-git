//
//  ZWYAppDelegate.m
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZWYAppDelegate.h"
#import "SettingViewController.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Statics.h"
#import "ChatMessage.h"
#import "AppDatabase.h"


NSString *const XMPPmyJID = @"zwyxmppjid";
NSString *const XMPPmyPassword = @"zwyxmpppassword";

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface ZWYAppDelegate()
{
    @private
    NSString *fromstr;
}

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
@property (strong, nonatomic) NSString *fromstr;
@end

@implementation ZWYAppDelegate

@synthesize xmppStream;
@synthesize window = _window;
@synthesize xmppRosterStorage;
@synthesize xmppRoster;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize detailViewController;
@synthesize database;
@synthesize fromstr;
@synthesize isConnected;


- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // setup database
    self.database = [[AppDatabase alloc] initWithMigrations];
    // create table Message when not exist in database
    if (![[self database] checkTableWithName: @"ChatMessage"])
    {
        [[self database] createMyTable];
    }

    // Setup the XMPP stream
    
	[self setupStream];
    
    if (![self connect])
	{
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
           
            SettingViewController *controller = [[[_window rootViewController] storyboard] instantiateViewControllerWithIdentifier:@"SettingView"];
            [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [controller setModalPresentationStyle:UIModalPresentationFormSheet];
            [[_window rootViewController] presentModalViewController:controller animated:YES];
            controller.view.superview.frame = CGRectMake(0, 0, 400, 400);
            controller.view.superview.center = CGPointMake(512, 374);
			
		});
	}

    
    return YES;
}

- (void)dealloc
{
    [self teardownStream]; 
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 - (NSManagedObjectContext *)managedObjectContext_roster
 {
 return [xmppRosterStorage mainThreadManagedObjectContext];
 }
 
 - (NSManagedObjectContext *)managedObjectContext_capabilities
 {
 return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
 }
 
 */

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    xmppStream = [[XMPPStream alloc] init];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
	
    [xmppRoster activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities activate:xmppStream];
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   // [xmppStream setHostName:@"125.216.241.179"];
}

- (void)teardownStream
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);    
    
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    //TODO [self disconnect]
    
    [xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
    [xmppCapabilities deactivate];
    
    [xmppStream disconnect];
    xmppRoster = nil;
    xmppRosterStorage = nil;

	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppStream = nil;
    
}

- (void)disconnect
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	[self goOffline];
	[xmppStream disconnect];
    isConnected = NO;
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPmyPassword];
   // NSString *myJID = [[NSString alloc] initWithFormat:@"robin@scutlab.com"];
   // NSString *myPassword = [[NSString alloc] initWithFormat:@"1234"];
	//
	// If you don't want to use the Settings view to set the JID, 
	// uncomment the section below to hard code a JID and password.
	// 
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting" 
		                                                    message:@"See console for error details." 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    isConnected = YES;
	return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self teardownStream];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self teardownStream];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
    /*	if (allowSelfSignedCertificates)
     {
     [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
     }
     
     if (allowSSLHostNameMismatch)
     {
     [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
     }
     else
     {
     */		// Google does things incorrectly (does not conform to RFC).
    // Because so many people ask questions about this (assume xmpp framework is broken),
    // I've explicitly added code that shows how other xmpp clients "do the right thing"
    // when connecting to a google server (gmail, or google apps for domains).
    
    NSString *expectedCertName = nil;
    
    NSString *serverDomain = xmppStream.hostName;
    NSString *virtualDomain = [xmppStream.myJID domain];
    
    if ([serverDomain isEqualToString:@"talk.google.com"])
    {
        if ([virtualDomain isEqualToString:@"gmail.com"])
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
    }
    else if (serverDomain == nil)
    {
        expectedCertName = virtualDomain;
    }
    else
    {
        expectedCertName = serverDomain;
    }
    
    if (expectedCertName)
    {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
	//}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //删除不存在的用户名
    if ([iq isErrorIQ])
    {
        NSString *str = [[iq elementForName:@"error"] attributeStringValueForName:@"code"];
        if ([str isEqualToString:@"404"])
            [xmppRoster removeUser:[XMPPJID jidWithString:[iq fromStr]]];
    }
	
	return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
   
    if ([message isChatMessageWithBody])   
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                  xmppStream:xmppStream
                                                        managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *jidStr = [user jidStr];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            // save into database
            ChatMessage *msg = [[ChatMessage alloc] init];
            msg.direction = 0;
            msg.receiver = xmppStream.myJID.bare;
            msg.sender = jidStr;
            msg.content = body;
            msg.time = [[NSDate date] timeIntervalSince1970];
            [msg save];
            [detailViewController receivedMessage];
           
        }
       /* NSString *msg = [[message elementForName:@"body"] stringValue];
        NSString *from = [[message attributeForName:@"from"] stringValue];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:msg forKey:@"msg"];
            [dict setObject:from forKey:@"sender"];
            //消息接收到的时间
            [dict setObject:[Statics getCurrentTime] forKey:@"time"];
            [detailViewController receivedMessage:dict];
        }   */
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",jidStr,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }

    //消息委托(这个后面讲)
//    [messageDelegate newMessageReceived:dict];
    
 /*   if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Ok" 
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }*/
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    if ([[presence type] isEqualToString:@"subscribe"])
    {
        fromstr = [presence fromStr];
        NSString *msg = [[NSString alloc] initWithFormat:@"准许%@添加你到他的联系人名单?", [presence fromStr]];
        UIAlertView *subscribeAlert = [[UIAlertView alloc] initWithTitle:@"添加好友请求" message:msg
    delegate:self cancelButtonTitle:@"接受" otherButtonTitles:@"不同意", nil];
        [subscribeAlert show];
        
    }
    else if ([presence isErrorPresence])
    {
        NSString *str = [[presence elementForName:@"error"] attributeStringValueForName:@"code"];
        if ([str isEqualToString:@"404"])
            [xmppRoster removeUser:[XMPPJID jidWithString:[presence fromStr]]];
        //NSString *str = [presence attributeStringValueForName:@"/error:code"];
        //NSLog(@"-------------------------------%@", str);            
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex] )
    {
        [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:fromstr] andAddToRoster:YES];
    }
    else
        [xmppRoster rejectPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:fromstr]];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

@end
