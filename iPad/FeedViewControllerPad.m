//
//  FeedViewControllerPad.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedViewControllerPad.h"

#define REFRESHOFFSET FEEDTABLEVIEWCELLHEIGHT

@implementation FeedViewControllerPad

@synthesize grSub = _grSub;
@synthesize theTableView = _theTableView;
@synthesize dataSource = _dataSource;
@synthesize normalRefreshButton = _normalRefreshButton;
@synthesize activityButton = _activityButton;
@synthesize unreadSegment = _unreadSegment;
@synthesize buttomToolbar = _buttomToolbar;
@synthesize updatedTimeLabel = _updatedTimeLabel;
@synthesize showSource = _showSource;
@synthesize actionSheet = _actionSheet;
@synthesize subscribeButton = _subscribeButton;
@synthesize dismissButton = _dismissButton;
@synthesize modalStyle = _modalStyle;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	//create table view
	DebugLog(@"loading feed view");
	[self createTableView];
	
	if (!self.modalStyle){
		[self createButtomToolbar];
	}
	
	[self createNavigationBarButton];
	
	[self refreshDatasource:nil];
}

-(void)disableControllers{
	if (self.modalStyle){
		return;
	}
	self.navigationItem.rightBarButtonItem = self.activityButton;
	for (UIBarButtonItem* item in self.toolbarItems){
		[item setEnabled:NO];
	}
}

-(void)enableControllers{
	if (self.modalStyle){
		return;
	}
	self.navigationItem.rightBarButtonItem = self.normalRefreshButton;
	[self formatUpdateTimeLabel:self.updatedTimeLabel];
	for (UIBarButtonItem* item in self.toolbarItems){
		[item setEnabled:YES];
	}
	
}

-(void)refreshDatasource:(id)sender{
	BOOL manually = (sender)?YES:NO;
	BOOL started = [[GRDataManager shared] refreshFeedWithSub:self.grSub manually:manually];
	if (started){
		[self disableControllers];
	}
}

-(void)feedUpdated:(NSNotification*)sender{
	
	DebugLog(@"in feed updated message");
	
	NSString* continuedKey = [sender.userInfo objectForKey:CONTINUEDFEEDKEY];
	
	DebugLog(@"continued key is %@", continuedKey);
	if (!continuedKey){
		//is being notified that my feed was updated
		[self.dataSource refresh];//refress dataSource
		[self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		if (!self.dataSource.feedBuffer){
			[self.dataSource loadBufferFeed];
		}
		[self performSelectorOnMainThread:@selector(enableControllers)
							   withObject:nil
							waitUntilDone:NO];
	}else {
		BOOL needReloadTable = NO;
		needReloadTable = [self.dataSource refreshBuffer];
		if (needReloadTable){
			[self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		}
	}
	
}

-(void)errorHappened:(NSNotification*)sender{
	//	self.navigationItem.rightBarButtonItem = self.normalRefreshButton;
	[self performSelectorOnMainThread:@selector(enableControllers)
						   withObject:nil
						waitUntilDone:NO];
//	[self enableControllers];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.theTableView reloadData];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(BOOL)selectedLastRow:(NSIndexPath*)indexPath{
	return (indexPath.row == [self.dataSource.grFeed itemCount]);
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self selectedLastRow:indexPath]){
		ItemViewController* itemViewController = [[ItemViewController alloc] initWithItems:self.dataSource.grFeed.items itemIndex:indexPath];

		if ([UserPreferenceDefine iPadMode]){
		UINavigationController* webContainer = [[UINavigationController alloc] initWithRootViewController:itemViewController];
		webContainer.modalPresentationStyle = UIModalPresentationPageSheet;
		webContainer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:webContainer 
								animated:YES];
		[webContainer release];
		}else {
			[self.navigationController pushViewController:itemViewController animated:YES];
		}
		
		[itemViewController release];
		
	}else {
		BOOL reloadTable = [self.dataSource loadingMoreCellIsSelected];
		if (reloadTable){
			[self.theTableView reloadData];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return FEEDTABLEVIEWCELLHEIGHT;
}

#pragma mark -
#pragma mark Scroll View Delegate
//trige refresh if content offset is bigger than NUMBER
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	DebugLog(@"content offset y is %f", scrollView.contentOffset.y);
	if (scrollView.contentOffset.y < 0-REFRESHOFFSET*1.2){
		[self refreshDatasource:self];
	}
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//	return UITableViewCellEditingStyleNone;
//}

//- (void)dismissModalViewControllerAnimated:(BOOL)animated{
//	DebugLog(@"you are dismissed");
//	[super dismissModalViewControllerAnimated:animated];
//	[self.theTableView reloadData];
//}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	//	DebugLog(@"view controller for Feed unloaded");
	//	[[GRDataManager shared] syncUnreadCount];
}

-(void)createTableView{
	FeedDataSource* theDataSource = [[FeedDataSource alloc] initWithGRSub:self.grSub];
	theDataSource.showSource = self.showSource;
	// retain the data source
	self.dataSource = theDataSource;
	[theDataSource release];
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	
	UITableView* mTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														   style:[self.dataSource tableViewStyle]];
	
	// set the autoresizing mask so that the table will always fill the view
	mTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.title = [self.dataSource name];
	mTableView.delegate = self;
	mTableView.dataSource = self.dataSource;
	//	mTableView.backgroundColor = [UIColor clearColor];
	mTableView.scrollsToTop = YES;
	if (self.showSource){
		mTableView.rowHeight = 60.0;
	}
	[mTableView sizeToFit];
	
	// set the tableview as the controller view
    self.theTableView = mTableView;
	self.tableView = mTableView;
	self.view = mTableView;
	[mTableView release];
}

-(void)createButtomToolbar{
	self.navigationController.toolbar.barStyle = UIBarStyleDefault;
	self.navigationController.toolbarHidden = NO;
	
	//create segment controller for unread/all
	NSArray* segmentTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Seg_All", nil), NSLocalizedString(@"Seg_Unread", nil), nil];
	UISegmentedControl* unreadSwitch = [[UISegmentedControl alloc] initWithItems:segmentTitles];
	unreadSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
	
	//setup default read mode
	if (self.grSub.isUnreadOnly){
		unreadSwitch.selectedSegmentIndex = 1;
	}else {
		unreadSwitch.selectedSegmentIndex = 0;
	}
	//add call back message
	[unreadSwitch addTarget:self action:@selector(handleSegmentControllerEvent) forControlEvents:UIControlEventValueChanged];
	
	self.unreadSegment = unreadSwitch;
	UIBarButtonItem* unreadSwitchButton = [[UIBarButtonItem alloc] initWithCustomView:self.unreadSegment];
	[unreadSwitch release];
	
	//create updated time stamp
	
	UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
	self.updatedTimeLabel = timeLabel;
	[timeLabel release];
	
	[self formatUpdateTimeLabel:self.updatedTimeLabel];
	
	UIBarButtonItem* timeItem = [[UIBarButtonItem alloc] initWithCustomView:self.updatedTimeLabel];
	
	//create check box to mark all item as read
	UIBarButtonItem* checkButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self 
																				 action:@selector(handleActionButtonEvent:)];
	
	UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																				   target:nil 
																				   action:nil];
	
	NSArray* barItems = [NSArray arrayWithObjects:checkButton, flexibleSpace, timeItem, flexibleSpace, unreadSwitchButton, nil];
	
	[flexibleSpace release];
	
	[self setToolbarItems:barItems animated:YES];
	
	[unreadSwitchButton release];
	[timeItem release];
	[checkButton release];
}

-(void)formatUpdateTimeLabel:(UILabel*)label{
	
	NSDate* updatedTime = [self.dataSource latestUpdateTime];
	NSString* timeString = nil;
	if (!updatedTime){
		timeString = NSLocalizedString(@"Label_Unknown", nil);
	}else {
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		[formatter setDateFormat:@"MM/dd HH:mm"];
		timeString = [formatter stringFromDate:updatedTime];
		[formatter release];
	}
	
	label.text = [[NSLocalizedString(@"Label_Updated", nil) stringByAppendingString:@" "] stringByAppendingString:timeString];
	label.font = [UIFont systemFontOfSize:12];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
}

-(void)createNavigationBarButton{

	if (!self.modalStyle){
		UIBarButtonItem* temporaryBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDatasource:)];
		self.normalRefreshButton = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
		
		UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		[activityView startAnimating];
		[activityView sizeToFit];
		activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
		
		UIBarButtonItem* activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];

		self.activityButton = activityItem;
		[activityView release];
		[activityItem release];
		
		[self enableControllers];
	}else {
		UIBarButtonItem* tempSub = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Subscribe", nil) 
																	style:UIBarButtonSystemItemDone
																   target:self
																   action:@selector(subscribeCurrentFeed)];
		
		UIBarButtonItem* tempDismiss = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) 
																		style:UIBarButtonSystemItemDone
																	   target:self  
																	   action:@selector(dismissSelf)];
		self.navigationItem.leftBarButtonItem = tempDismiss;
		self.navigationItem.rightBarButtonItem = tempSub;
		
		[tempSub release];
		[tempDismiss release];
	}

}

-(void)dismissSelf{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)subscribeCurrentFeed{
	ChooseLabelForSubController* chooseLabel = [[ChooseLabelForSubController alloc] initWithSubTitle:self.grSub.title andStreamID:self.grSub.ID];
	chooseLabel.delegate = self;
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:chooseLabel];
	[chooseLabel release];
	
	if ([UserPreferenceDefine iPadMode]){
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
		nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	[self presentModalViewController:nav 
							animated:YES];
	
	[nav release];
}

//handle action button event
-(void)handleActionButtonEvent:(id)sender{
	//create action sheet;
	if (!self.actionSheet){
		UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"MarkAllRead", nil),nil];
		self.actionSheet = as;
		[as release];
		[self.actionSheet showFromBarButtonItem:sender animated:YES];
	}else {
		[self.actionSheet dismissWithClickedButtonIndex:1 animated:YES];
		self.actionSheet = nil;
	}

}

#pragma mark -
#pragma mark delegate methods for actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	DebugLog(@"index is %d", buttonIndex);
	NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"MarkAllRead", nil)]){
		DebugLog(@"mark all as read");
		[[GRDataManager shared] markAllAsRead:self.grSub waitUtilDone:NO];
		[self.dataSource markAllAsRead];
	}
	self.actionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark delegate methods for ChooseLabelForSubDelegate
-(void)didChooseLabelForFeed:(NSString *)streamID labels:(NSArray *)labels withTitle:(NSString *)mTitle{
	for (GRTag* tag in labels){
		NSString* label = nil;
		if (![tag.label isEqualToString:NOLABEL]){
			label = tag.ID;
		}
		[[GRDataManager shared] subscribeFeed:streamID 
									withTitle:mTitle 
									  withTag:label];
	}
}

-(void)didCancelSubscribeForFeed:(NSString *)streamID{
	DebugLog(@"FeedViewControllerPad - didCancelSubscribeForFeed");
}

-(void)didFinishLabelChoose:(NSString *)streamID{
	DebugLog(@"dismiss modal view in feed view controller");
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

//handle the event that states of segment controller changed;
-(void)handleSegmentControllerEvent{
	
	NSString* selectedSegment = [self.unreadSegment titleForSegmentAtIndex:self.unreadSegment.selectedSegmentIndex];
	
	BOOL desiredUnreadOnly = NO;
	
	if ([selectedSegment isEqualToString:NSLocalizedString(@"Seg_Unread", nil)]){
		desiredUnreadOnly = YES;
	}
	
	if (self.grSub.isUnreadOnly != desiredUnreadOnly){
		
		//remove registered notification
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:[self.grSub keyString]
													  object:nil];
		
		self.grSub.isUnreadOnly = desiredUnreadOnly;
		//create a new datasource based on new sub
		FeedDataSource* newDataSource = [[FeedDataSource alloc] initWithGRSub:self.grSub];
		self.dataSource = newDataSource;
		self.tableView.dataSource = newDataSource;
		//register new notification event
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(feedUpdated:) 
													 name:[self.grSub keyString] 
												   object:nil];	
		//refresh data source and table
		[self.dataSource refresh];
		[self.tableView reloadData];
		[self refreshDatasource:nil];
	}
	
	[self formatUpdateTimeLabel:self.updatedTimeLabel];
}

-(id)initWithObject:(id<GRBaseProtocol>)mGRSub{
	if (self = [super init]){
		self.grSub = mGRSub;
		if (!self.grSub.unread){
			self.grSub.isUnreadOnly = NO;
		}else {
			self.grSub.isUnreadOnly = [UserPreferenceDefine shouldShowUnreadFirst];
		}
		
		if ([[GRDataManager shared] getUpdatedGRSub:self.grSub.ID]){
			self.showSource = NO;
		}else {
			self.showSource = YES;
		}
		
		self.delegate = nil;
		self.hidesBottomBarWhenPushed = YES;
		//register a notification named by feed ID
		//this notification will be sent if the feed is updated
		DebugLog(@"registered observer name is %@", [self.grSub keyString]);
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(feedUpdated:) 
													 name:[self.grSub keyString] 
												   object:nil];	
		//this notification will be sent when feed updating began
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(errorHappened:) 
													 name:GRERRORHAPPENED 
												   object:nil];	
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:[self.grSub keyString]
												  object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:GRERRORHAPPENED  
												  object:nil];	
	DebugLog(@"unregister observer name is %@", [self.grSub keyString]);
	[self.normalRefreshButton release];
	[self.activityButton release];
	[self.buttomToolbar release];
	[self.unreadSegment release];
	[self.grSub release];
	[self.theTableView release];
	[self.updatedTimeLabel release];
	[self.dataSource release];
	self.actionSheet = nil;
	self.dismissButton = nil;
	self.subscribeButton = nil;
	self.delegate = nil;
    [super dealloc];
}


@end

