//
//  ZWYDetailViewController.m
//  XMPPDemo
//
//  Created by robin on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZWYDetailViewController.h"
#import "MessageCell.h"
#import "Statics.h"
#import "ZWYAppDelegate.h"
#import "ChatMessage.h"
#import "ChatTableViewCell.h"
#import "NSString+Utils.h"


#define padding 10

extern NSString *const XMPPmyJID;
extern NSString *const XMPPmyPassword;


@interface ZWYDetailViewController () 
{
    NSMutableArray *messages;
}
@property (strong) NSArray *allRecord;
@property (strong, nonatomic) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation ZWYDetailViewController

@synthesize detailItem = _detailItem;
@synthesize chatPeer = _chatPeer;
@synthesize peerFace = _peerFace;
@synthesize sendContent = _sendContent;
@synthesize msgView = _msgView;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize popoverController = _myPopoverController;
@synthesize sendButton = _sendButton;
@synthesize chatWithUser;
@synthesize allRecord;

- (ZWYAppDelegate *)appDelegate
{
	return (ZWYAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)readFromDatabase
{
    if (chatWithUser != nil)
    {
        self.allRecord = [[NSArray alloc] initWithArray: [ChatMessage findWithSqlWithParameters: [NSString stringWithFormat: @"SELECT * FROM ChatMessage WHERE (sender IN (?, ?)) AND (receiver IN (?, ?))"], [self appDelegate].xmppStream.myJID.bare, chatWithUser, [self appDelegate].xmppStream.myJID.bare, chatWithUser, nil]];
    }
}

- (void)chatTableScrollToBottom
{
    if (0 < self.allRecord.count)
    {
        [self.msgView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: self.allRecord.count - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (IBAction)resignKeyboard:(id)sender {
    [_sendContent resignFirstResponder]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.msgView.delegate = self;
    self.msgView.dataSource = self;
    [[self appDelegate] setDetailViewController:self];
    messages = [NSMutableArray array];
//    self.msgView.separatorStyle = UITableViewCellSeparatorStyleNone;
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    // add tap gesture recognizer
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] 
                                             initWithTarget:self 
                                             action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    // read chat data from database
    [self readFromDatabase];
}

- (void)viewDidUnload
{
    [self setMsgView:nil];
    [self setSendContent:nil];
    [self setChatPeer:nil];
    [self setPeerFace:nil];
    [self setAllRecord:nil];
    [self setSendButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self chatTableScrollToBottom];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self readFromDatabase];
    NSUInteger t = 
    self.allRecord.count;
    return t;
    //return [messages count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"ChatCell";
    
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[ChatTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    ChatMessage *chatMessage= [self.allRecord objectAtIndex: indexPath.row];
    Message *msg = [[Message alloc] init];
    
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    msg.isNew = true;
    if ([chatMessage.sender isEqualToString: [self appDelegate].xmppStream.myJID.bare])
    {
        msg.from = false;
        msg.peer = chatMessage.receiver;
    }
    else
    {
        msg.from = true;
        msg.peer = chatMessage.sender;
    }
    [cell setup:msg withWidth:tableView.frame.size.width];
    
    return cell;    
}

-(void) receivedMessage
{
    [self readFromDatabase];
    [[self msgView] reloadData];
    [self chatTableScrollToBottom];
   // [messages addObject:msg];
    //[[self msgView] reloadData];
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 44;
    ChatMessage *chatMessage= [self.allRecord objectAtIndex: indexPath.row];
    Message *msg = [[Message alloc] init];
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    if ([chatMessage.sender isEqualToString: [self appDelegate].xmppStream.myJID.bare])
    {
        msg.from = false;
        msg.peer = chatMessage.receiver;
    }
    else
    {
        msg.from = true;
        msg.peer = chatMessage.sender;
    }
    
    height = [ChatTableViewCell heightOfCellWithContent:msg withWidth:tableView.frame.size.width];

    return height;
   /* NSMutableDictionary *dict  = [messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];
    
    CGSize textSize = {260.0 , 10000.0};
    CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    size.height += padding*2;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    
    return height;*/
}  
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_sendContent resignFirstResponder];
    return indexPath;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    [_sendContent resignFirstResponder];    
}

- (IBAction)sendMessage:(id)sender {
    //本地输入框中的信息
    NSString *message = self.sendContent.text;
    
    if (chatWithUser.length<=0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请选择聊天对象" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (message.length > 0) 
    {
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:XMPPmyJID]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[[self appDelegate] xmppStream] sendElement:mes];
     //   [[self xmppStream] sendElement:mes];
        
        self.sendContent.text = @"";
        [self.sendContent resignFirstResponder];
        //save into database
        ChatMessage *msg = [[ChatMessage alloc] init];
        msg.direction = 1;
        msg.sender = [self appDelegate].xmppStream.myJID.bare;
        msg.receiver = self.chatWithUser;
        msg.content = [message substituteEmoticons];
        msg.time = [[NSDate date] timeIntervalSince1970];
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init ];
        
        [msg save];
        /*
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"I" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[Statics getCurrentTime] forKey:@"time"];
        
        [messages addObject:dictionary];
        */
        //重新刷新tableView
        [self readFromDatabase];
        [self.msgView reloadData];
        [self chatTableScrollToBottom];
        
    }

}
@end
