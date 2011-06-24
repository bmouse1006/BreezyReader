//
//  ItemViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemViewController.h"
#import "GRDownloadManager.h"

#define IMAGEWIDTH @"#BREEZYREADER_IMAGEWIDTH#"

#define	TOUCHENABLESCRIPT @"<script language=\"javascript\">document.ontouchstart=function(){          document.location=\"ItemWeb:touch:start\";  }; document.ontouchend=function(){          document.location=\"ItemWeb:touch:end\";  }; document.ontouchmove=function(){          document.location=\"ItemWeb:touch:move\";  }  </script>"

@implementation ItemViewController

@synthesize grItem = _grItem;
@synthesize itemList = _itemList;
@synthesize webView = _webView;
@synthesize buttomToolbar = _buttomToolbar;
@synthesize contentFormatter = _contentFormatter;
@synthesize indexPath = _indexPath;
@synthesize actionMenu = _actionMenu;
@synthesize starActionButton = _starActionButton;
@synthesize broadcastActionButton = _broadcastActionButton;
@synthesize keptUnreadActionButton = _keptUnreadActionButton;
@synthesize previousBarItem = _previousBarItem;
@synthesize nextBarItem = _nextBarItem;

@synthesize saveButton = _saveButton;
@synthesize onlineMode = _onlineMode;
@synthesize fullscreen = _fullscreen;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(void)itemDownloadFinished:(id)sender{
	NSDictionary* userInfo = [(NSNotification*)sender userInfo];
	
	GRItem* item = [userInfo objectForKey:@"item"];
	
	if ([item.ID isEqualToString:self.grItem.ID]){
		[self createNavigationBarButton:self.grItem];
	}
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked){
		WebViewController* webViewController = [[WebViewController alloc] initWithURLRequest:request];
		[self presentModalViewController:webViewController animated:YES];
		[webViewController release];
		DebugLog(@"clicked");
		return NO;
	}
	
	NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"ItemWeb"]){
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"]){
			NSString* event = [components objectAtIndex:2];
//          NSLog(@"%@", event);
			[self processTouchEvent:event];
        }
        return NO;
    }
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)mWebView{
	DebugLog(@"did start loading");
}

- (void)webViewDidFinishLoad:(UIWebView *)mWebView{
	DebugLog(@"did finish loading");

	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	DebugLog(@"Error happened");
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self composeActionMenu];
	[self createButtomToolbar];
	[self loadItemContentView:self.grItem atIndex:self.indexPath];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[UIView beginAnimations:@"toBlack" context:nil];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[UIView commitAnimations];
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (self.onlineMode){
//		[[GRDataManager shared] syncUnreadCount];
		[[GRDataManager shared] syncReaderStructure];
	}
}

-(void)loadItemContentView:(GRItem*)mItem atIndex:(NSIndexPath*)index{
	
	if(index.row == 0){
		self.previousBarItem.enabled = NO;
	}else {
		self.previousBarItem.enabled = YES;
	}
	
	if (index.row == [self.itemList count] -1){
		self.nextBarItem.enabled = NO;
	}else {
		self.nextBarItem.enabled = YES;
	}

	[self setItemToActionMenu:mItem];
	[self createNavigationBarButton:mItem];//create a new save button for current item, in case save state change
	
	NSString* selfURLString = mItem.selfLink;
	NSString* altURLString = mItem.alternateLink;
	if (!selfURLString || [@"" isEqualToString:selfURLString]){
		selfURLString = altURLString;
	}
	
	NSURL* baseURL = [NSURL URLWithString:selfURLString];
	
	NSMutableString* htmlContentString = [NSMutableString stringWithString:[self formatContentString:mItem]];
	
	if (!self.onlineMode){
		//replace image URL with local file path
		NSArray* imageURLList = [mItem imageURLList];
		
		for (NSString* urlString in imageURLList){
			NSString* filePath = [mItem encryptedImageFileName:urlString];
//			replaceOccurrencesOfString:withString:options:range:
			[htmlContentString replaceOccurrencesOfString:urlString 
											   withString:filePath
												  options:NSBackwardsSearch
													range:NSMakeRange(0, [htmlContentString length])];
		}
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		baseURL = [NSURL fileURLWithPath:documentsDirectory];
	}
	
	//add javascript to support touch event
	htmlContentString = [NSMutableString stringWithString:[htmlContentString stringByAppendingString:TOUCHENABLESCRIPT]];
	//
	
	[self.webView loadHTMLString:htmlContentString baseURL:baseURL];
	
	if (self.onlineMode){
		NSArray* items = [NSArray arrayWithObject:mItem];
		[[GRDataManager shared] markItemsAsRead:items];
	}
}

-(NSString*)formatContentString:(GRItem*)mItem{
	NSString* summary = mItem.summary;
	NSString* content = mItem.content;
	if (!content || [@"" isEqualToString:content]){
		content = summary;
	}
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	
	[formatter setTimeZone:[NSTimeZone localTimeZone]];
	[formatter setDateFormat:NSLocalizedString(@"LongDateFormat", nil)];
	
	NSString* published = [formatter stringFromDate:mItem.published];
	
	[formatter release];

	NSString* formattedContent = [NSString stringWithFormat:self.contentFormatter, mItem.title, mItem.author, published, content];
//	NSString* link = self.grItem.selfLink;
//	if (!link){
//		link = self.grItem.alternateLink;
//	}
//	
	
	
	return formattedContent;
}

//create save button
-(void)createNavigationBarButton:(GRItem*)mItem{
	//create save button
	//need to add code to check if this item has been saved or not
	BOOL saved = [[GRDownloadManager shared] itemDownloaded:mItem];
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] init];
	
	if (!saved){
		rightButton.title = NSLocalizedString(@"Save", nil);
		rightButton.target = self;
		rightButton.action = @selector(saveItem:);
	}else {
		rightButton.title = NSLocalizedString(@"Saved", nil);
		rightButton.enabled = NO;
	}
	
	if (![self.saveButton.title isEqual:rightButton.title]){
		self.saveButton = rightButton;
		[self.navigationItem setRightBarButtonItem:rightButton animated:YES];
	}
	[rightButton release];
	
	if ([UserPreferenceDefine iPadMode]){
		UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] init];
		leftButton.title = NSLocalizedString(@"Done", nil);
		leftButton.target = self;
		leftButton.style = UIBarButtonItemStyleDone;
		leftButton.action = @selector(dismiss);
		[self.navigationItem setLeftBarButtonItem:leftButton];
		[leftButton release];
	}
}

-(void)dismiss{
	[self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

//create buttom tool bar
- (void)createButtomToolbar
{		
	// size up the toolbar and set its frame
	[self.buttomToolbar sizeToFit];
	CGFloat toolbarHeight = [self.buttomToolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[self.buttomToolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
									  CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - toolbarHeight,
									  CGRectGetWidth(mainViewBounds),
									  toolbarHeight)];
//	self.previousBarItem.image = [UIImage imageNamed:@"arrow_left.png"];
	[self.view bringSubviewToFront:self.buttomToolbar];
	
}

-(IBAction)loadOrigWebView{
	NSString* link = self.grItem.selfLink;
	if (!link || [@"" isEqualToString:link]){
		link = self.grItem.alternateLink;
	}
	NSURL* url = [NSURL URLWithString:link];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	WebViewController* webViewController = [[WebViewController alloc] initWithURLRequest:request];
	[self presentModalViewController:webViewController animated:YES];
	[webViewController release];
	
}

-(IBAction)readPreviousItem{
	NSIndexPath* previousIndexPath; 
	if (self.indexPath.row){
		previousIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row-1 inSection:self.indexPath.section];
	} else {
		return;
	}

	self.indexPath = previousIndexPath;
//	self.grItem = [self.grFeed getItemAtIndex:self.indexPath];
	self.grItem = [self.itemList objectAtIndex:self.indexPath.row];
	[self loadItemContentView:self.grItem atIndex:self.indexPath];
}

-(IBAction)readNextItem{
	NSIndexPath* nextIndexPath; 
//	if (self.indexPath.row < [self.grFeed itemCount] - 1){
	if (self.indexPath.row < [self.itemList count] -1){
		nextIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row+1 inSection:self.indexPath.section];
	} else {
		return;
	}
	
	self.indexPath = nextIndexPath;
//	self.grItem = [self.grFeed getItemAtIndex:self.indexPath];
	self.grItem = [self.itemList objectAtIndex:self.indexPath.row];
	[self loadItemContentView:self.grItem atIndex:self.indexPath];
}

-(IBAction)showHideActionMenu:(id)sender{
	
	if (self.actionMenu.alpha == 0) {
		[self showActionMenu];
	}else {
		[self hideActionMenu];
	}
}

-(void)showActionMenu{
	[UIView beginAnimations:@"showActionMenu" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
//	CGAffineTransform moveUp = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -44);
//	self.actionMenu.transform = moveUp;
	self.actionMenu.alpha = 1;
	
	[UIView commitAnimations];
}

-(void)composeActionMenu{
	self.actionMenu.layer.cornerRadius = 6;
	self.actionMenu.layer.masksToBounds = YES;
	//	self.actionMenu.layer.borderWidth = 1;
	////	self.actionMenu.layer.borderColor = CGColorGetConstantColor("white");
	self.actionMenu.alpha = 0;
	[self.starActionButton setTitle:NSLocalizedString(@"icontitle_star", nil) forState:UIControlStateNormal];
	
	[self.broadcastActionButton setTitle:NSLocalizedString(@"icontitle_broadcast", nil) forState:UIControlStateNormal];
	
	[self setItemToActionMenu:self.grItem];
}

-(void)setItemToActionMenu:(GRItem*)mItem{
	//more setup for other buttons;
	if ([self.grItem isStarred]){
		[self.starActionButton setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
	}else {
		[self.starActionButton setImage:[UIImage imageNamed:@"star_white.png"] forState:UIControlStateNormal];
	}
	
	if ([self.grItem containsState:ATOM_STATE_BROADCAST]){
		[self.broadcastActionButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
	}else {
		[self.broadcastActionButton setImage:[UIImage imageNamed:@"share_empty.png"] forState:UIControlStateNormal];
	}
}

-(void)hideActionMenu{
	[UIView beginAnimations:@"showActionMenu" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
//	self.actionMenu.transform = CGAffineTransformIdentity;
	self.actionMenu.alpha = 0;
	
	[UIView commitAnimations];
}

-(IBAction)changeStarStatesOfCurrentItem{
//	if (self.onlineMode){
	[[GRDataManager shared] reverseStateForItem:self.grItem state:ATOM_STATE_STARRED];
	[self setItemToActionMenu:self.grItem];
}

-(IBAction)changeBroadcastStatesOfCurrentItem{
//	if (self.onlineMode){
	[[GRDataManager shared] reverseStateForItem:self.grItem state:ATOM_STATE_BROADCAST];
	[self setItemToActionMenu:self.grItem];
}

-(IBAction)changeKeptUnreadStatesOfCurrentItem{
//	if (self.onlineMode){
	[[GRDataManager shared] reverseStateForItem:self.grItem state:ATOM_STATE_UNREAD];	
//	}
	
}

-(IBAction)emailCurrentItem{
	
	if ([MFMailComposeViewController canSendMail])
	{
		[self displayComposerSheet];
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
//	message.hidden = NO;
//	// Notifies users about errors associated with the interface
//	switch (result)
//	{
//		case MFMailComposeResultCancelled:
//			message.text = @"Result: canceled";
//			break;
//		case MFMailComposeResultSaved:
//			message.text = @"Result: saved";
//			break;
//		case MFMailComposeResultSent:
//			message.text = @"Result: sent";
//			break;
//		case MFMailComposeResultFailed:
//			message.text = @"Result: failed";
//			break;
//		default:
//			message.text = @"Result: not sent";
//			break;
//	}
	[self dismissModalViewControllerAnimated:YES];
}

-(void)displayComposerSheet{
	MFMailComposeViewController* mailPicker = [[MFMailComposeViewController alloc] init];
	
	mailPicker.navigationBar.barStyle = UIBarStyleBlackOpaque;
	mailPicker.mailComposeDelegate = self;
	
	[mailPicker setSubject:self.grItem.title];
	
	// Fill out the email body text
	NSString *emailBody = [self formatContentString:self.grItem];
	[mailPicker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:mailPicker animated:YES];
	
	[mailPicker release];
}

-(void)launchMailAppOnDevice
{
	NSString *body = @"&body=%@";
	body = [NSString stringWithFormat:body, [self formatContentString:self.grItem]];
	
	NSString *email = [NSString stringWithFormat:@"%@", body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(void)saveItem:(id)sender{
	DebugLog(@"saving item");
	[[GRDownloadManager shared] saveSingleItem:self.grItem];
}

//process touch event
-(void)processTouchEvent:(NSString*)event{
	DebugLog(event);
	static BOOL moved = NO;
//	static BOOL startMoving = NO;
//	static BOOL 
	if ([event isEqualToString:@"start"]){
		moved = NO;
	}else if ([event isEqualToString:@"end"]){
		if (!moved){//enable/disable full screen only when not moved
			if ([UserPreferenceDefine shouldTapToFullscreen]){
				//only enable for iPhone mode
				[self switchFullScreenModeAnimated:YES];
			}
		}
	}else if ([event isEqualToString:@"move"]){
		moved = YES;
	}
}

//full screen
-(void)switchFullScreenModeAnimated:(BOOL)animated{
	
	DebugLog(@"self.fullscreen = %d", self.fullscreen);
	
	if (self.fullscreen){
		//un-fullscreen
		//
//		[self fullscreenWebView:NO animated:YES];
		[self.navigationController setNavigationBarHidden:NO 
												 animated:YES];
		[self hideToolBar:NO animated:YES];
	}else{
		//fullscreen
		//1. webview full screen
//		[self fullscreenWebView:YES animated:YES];
		//2. hide navigation bar
		[self.navigationController setNavigationBarHidden:YES
												 animated:YES];
		//3. hide tool bar
		[self hideToolBar:YES animated:YES];
		//4. if for iPhone hide status bar
	}
	
	self.fullscreen = !self.fullscreen;
}
		 
 -(void)hideToolBar:(BOOL)hide animated:(BOOL)animated{
	 CGRect rect = self.buttomToolbar.frame;
	 
	 if (animated){
		 [UIView beginAnimations:@"movingToolbar" context:nil];
		 [UIView setAnimationDelegate:self];
		 [UIView setAnimationDidStopSelector:@selector(fullscreenWebView)];
	 }
	 CGAffineTransform transform;
	 
	 if (hide){
		 transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, rect.size.height);
	 }else {
		 transform = CGAffineTransformIdentity;
	 }

	 //[self.buttomToolbar setFrame:rect];
	 self.buttomToolbar.transform = transform;
	 self.actionMenu.transform = transform;
	 if (animated){
		 [UIView commitAnimations];
	 }
 }

-(void)fullscreenWebView{
	CGRect rectWeb = self.webView.frame;
	CGRect rectBar = self.buttomToolbar.frame;
	
	if (self.fullscreen){
		rectWeb.size.height += rectBar.size.height;
	}else{
		rectWeb.size.height -= rectBar.size.height;
	}
	
	[self.webView setFrame:rectWeb];
}

-(id)initWithItems:(NSArray*)mItemList itemIndex:(NSIndexPath*)mIndexPath{
	if (self = [super init]){
		self.itemList = mItemList;
		self.indexPath = mIndexPath;
		self.grItem = [self.itemList objectAtIndex:[self.indexPath row]];
		NSString* path = [[NSBundle mainBundle] pathForResource:@"contentformatter" ofType:@"html"];
		NSString* formatter = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		
		NSString* width = [NSString stringWithFormat:@"%d", [UserPreferenceDefine imageWidth]];
		
		self.contentFormatter = [formatter stringByReplacingOccurrencesOfString:IMAGEWIDTH 
																	 withString:width];
		
//		DebugLog(@"formatter is %@", self.contentFormatter);
		
		self.hidesBottomBarWhenPushed = YES;
		self.onlineMode = YES;
		self.fullscreen = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemDownloadFinished:) 
													 name:ITEMDOWNLOADFINISHED 
												   object:nil];	
	}
	return self;
}

- (void)dealloc {
//	[self.grFeed release];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:ITEMDOWNLOADFINISHED 
												  object:nil];
	[self.itemList release];
	[self.grItem release];
	[self.contentFormatter release];
	[self.webView release];
	[self.buttomToolbar release];
	[self.indexPath release];
	[self.actionMenu release];
	[self.starActionButton release];
	[self.keptUnreadActionButton release];
	[self.broadcastActionButton release];
	[self.previousBarItem release];
	[self.nextBarItem release];
	[self.saveButton release];
    [super dealloc];
}


@end
