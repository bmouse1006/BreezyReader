//
//  FeedViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedViewController.h"

#define REFRESHOFFSET FEEDTABLEVIEWCELLHEIGHT

@implementation FeedViewController

@synthesize grSub = _grSub;
@synthesize theTableView = _theTableView;
@synthesize dataSource = _dataSource;
@synthesize normalRefreshButton = _normalRefreshButton;
@synthesize activityButton = _activityButton;
@synthesize unreadSegment = _unreadSegment;
@synthesize selectedCell = _selectedCell;
@synthesize buttomToolbar = _buttomToolbar;
@synthesize updatedTimeLabel = _updatedTimeLabel;
@synthesize showSource = _showSource;
#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	//create table view
	[self createTableView];

	[self createButtomToolbar];

	[self createRefreshButton];
	
	[self refreshDatasource:nil];
}

-(void)disableControllers{
	self.navigationItem.rightBarButtonItem = self.activityButton;
	for (UIBarButtonItem* item in self.toolbarItems){
		[item setEnabled:NO];
	}
}

-(void)enableControllers{
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
			DebugLog(@"load buffer feed");
			[self.dataSource loadBufferFeed];
			DebugLog(@"started load buffer feed");
		}
		[self performSelectorOnMainThread:@selector(enableControllers) 
							   withObject:nil
							waitUntilDone:NO];
	}else {
		BOOL needReloadTable = NO;
		needReloadTable = [self.dataSource refreshBuffer];
		if (needReloadTable){
			[self.theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//			[self.theTableView reloadData];
		}
	}
	DebugLog(@"feed updated");

}

-(void)errorHappened:(NSNotification*)sender{
//	self.navigationItem.rightBarButtonItem = self.normalRefreshButton;
	[self enableControllers];
}


- (void)viewWillAppear:(BOOL)animated {
	DebugLog(@"view will appear");
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	NSArray* visibleCells = [self.theTableView visibleCells];
	for (UITableViewCell* cell in visibleCells){
		if (cell != self.selectedCell){
			[cell setNeedsLayout];
		}
		
	}
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
	self.selectedCell = [self.theTableView cellForRowAtIndexPath:indexPath];
	if (![self selectedLastRow:indexPath]){
		ItemViewController* itemViewController = [[ItemViewController alloc] initWithItems:self.dataSource.grFeed.items itemIndex:indexPath];
		[self.navigationController pushViewController:itemViewController animated:YES];
		[itemViewController release];
	}else {
		BOOL reloadTable = [self.dataSource loadingMoreCellIsSelected];
		if (reloadTable){
			[self.theTableView reloadData];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
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

//caculate content offset
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//	return FEEDTABLEVIEWCELLHEIGHT;
//}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
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
	if (self.showSource || [UserPreferenceDefine shouldShowPreviewOfArticle]){
		mTableView.rowHeight = 60.0;
	}
	[mTableView sizeToFit];
	
	//create search Bar
	UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 20, 320)];
	searchBar.delegate = self;
	//create search controller here
	UISearchDisplayController* searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	
	[searchDisplay release];
	[searchBar release];
								
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
																				 action:@selector(handleActionButtonEvent)];
	
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
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
}

-(void)createRefreshButton{
	UIBarButtonItem* temporaryBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDatasource:)];
	self.normalRefreshButton = temporaryBarButtonItem;
	[temporaryBarButtonItem release];
	
	UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityView startAnimating];
	UIBarButtonItem* activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.activityButton = activityItem;
	[activityView release];
	[activityItem release];
	
//	self.navigationItem.rightBarButtonItem = self.normalRefreshButton;
	[self enableControllers];
}

//handle action button event
-(void)handleActionButtonEvent{
//create action sheet;
	UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"MarkAllRead", nil),nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"MarkAllRead", nil)]){
		DebugLog(@"mark all as read");
		[[GRDataManager shared] markAllAsRead:self.grSub waitUtilDone:NO];
		[self.dataSource markAllAsRead];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	[self.tableView reloadData];
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
	[self.normalRefreshButton release];
	[self.activityButton release];
	[self.buttomToolbar release];
	[self.unreadSegment release];
	[self.grSub release];
	[self.theTableView release];
	[self.updatedTimeLabel release];
	[self.dataSource release];
    [super dealloc];
}


@end

