//
//  HomeViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "GRDiscover.h"
#import "SearchFeedsViewController.h"
#import "AddNewFeedViewController.h"

@implementation HomeViewController


#pragma mark -
#pragma mark View lifecycle

@synthesize theTableView = _theTableView;
@synthesize dataSource = _dataSource;
@synthesize loginButton = _loginButton;
@synthesize downloadButton = _downloadButton;
@synthesize structureChanged = _structureChanged;
@synthesize unreadCountChanged = _unreadCountChanged;

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 0:
			break;
		case 1:
			[self logoutAction];
			break;
		default:
			break;
	}
	
}

#pragma mark -
#pragma mark table actions

-(void)updateTableView{
	DebugLog(@"number of removeSecions:%i", [self.dataSource.removeSections count]);
	DebugLog(@"number of insertSections:%i", [self.dataSource.insertSections count]);
	DebugLog(@"number of removeIndexPath:%i", [self.dataSource.removeIndexs count]);
	DebugLog(@"number of insertIndexPath:%i", [self.dataSource.insertIndexs count]);
	if ([self.dataSource.removeSections count]||[self.dataSource.insertSections count]||[self.dataSource.removeIndexs count]||[self.dataSource.insertIndexs count]){
		[self.theTableView beginUpdates];
		
		if (self.dataSource.removeSections)
			[self.theTableView deleteSections:self.dataSource.removeSections 
							 withRowAnimation:UITableViewRowAnimationFade];
		if (self.dataSource.removeIndexs)
			[self.theTableView deleteRowsAtIndexPaths:self.dataSource.removeIndexs
									 withRowAnimation:UITableViewRowAnimationFade];
		if (self.dataSource.insertSections)
			[self.theTableView insertSections:self.dataSource.insertSections
							 withRowAnimation:UITableViewRowAnimationFade];
		if (self.dataSource.insertIndexs)
			[self.theTableView insertRowsAtIndexPaths:self.dataSource.insertIndexs
									 withRowAnimation:UITableViewRowAnimationFade];

		[self.theTableView endUpdates];
	}else {
//		[self.theTableView reloadData];
	}

	[self.dataSource eraseChangeDataForRowAndSections];

}

-(void)loginButtonActoin:(id)sender{
	DebugLog(@"button size is");
	
	UIBarButtonItem* button = (UIBarButtonItem*)sender;
	NSString* logoutStr = NSLocalizedString(@"Logout", nil);
	if ([button.title isEqualToString:logoutStr]){
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
															message:NSLocalizedString(@"logoutConfirm", nil)
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												  otherButtonTitles:NSLocalizedString(@"OK", nil),nil];

		[alertView show];
		[alertView release];
		
	}else {
		NSNotification* notification = [NSNotification notificationWithName:LOGINNEEDED object:self userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
	}
}

-(void)logoutAction{
		[[GoogleAuthManager shared] logout];
		[[GRDataManager shared] cleanAllData];
		[self.dataSource emptyData];
		[self updateTableView];
}

-(void)sendSelectNotification:(id)obj{
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"FeedViewControllerPad", CLASSNAME, obj, INITOBJ, nil]; 
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_SELECTIONINMASTERVIEW
																 object:self
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)sendSelectNotificationWithClass:(NSString*)className initObj:(id)obj{
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:className, CLASSNAME, obj, INITOBJ, nil]; 
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_SELECTIONINMASTERVIEW
																 object:self
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)enableDownloadMode:(id)sender{
	
	if (self.theTableView.editing){
		self.dataSource.editingStyle = UITableViewCellEditingStyleDelete;
		[self.theTableView setEditing:NO animated:YES]; 
		self.downloadButton.title = NSLocalizedString(@"Download", nil);
		self.downloadButton.style = UIBarButtonItemStyleBordered;
		[self.navigationItem setLeftBarButtonItem:self.loginButton animated:YES];
	}else {
		self.dataSource.editingStyle = UITableViewCellEditingStyleInsert;
		[self.theTableView setEditing:YES animated:YES];
//		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
//		[self.theTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
		self.downloadButton.title = NSLocalizedString(@"Done", nil);
		self.downloadButton.style = UIBarButtonItemStyleDone;
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	}
	[self.navigationItem setRightBarButtonItem:self.downloadButton animated:YES];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:LOGINSTATUS]){
		NSString* newStatus = [change objectForKey:NSKeyValueChangeNewKey];
		
		if([newStatus isEqualToString:LOGIN_SUCCESSFUL]){
			self.loginButton.title = NSLocalizedString(@"Logout", nil);
		}else {
			self.loginButton.title = NSLocalizedString(@"Login", nil);
		}
	}
}

-(id)init{
	if (self = [super init]) {	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagOrSubChanged:) 
													 name:TAGORSUBCHANGED 
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(unreadCountChanged:) 
													 name:UNREADCOUNTCHANGED 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(dataSyncBegan:) 
													 name:BEGANSYNCDATA 
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(dataSyncEnded:) 
													 name:ENDSYNCDATA 
												   object:nil];	
		[[GoogleAuthManager shared] addObserver:self 
									 forKeyPath:LOGINSTATUS 
										options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
										context:nil];
		self.theTableView = nil;
		self.dataSource = nil;
		self.structureChanged = NO;
		self.unreadCountChanged = NO;
		//register self as observer of login needed event
	}
	return self;
}

//call back method for system notification

-(void)tagOrSubChanged:(NSNotification*)sender{
	DebugLog(@"Home View - OK, I know data changed");
	self.structureChanged = YES;
}

-(void)unreadCountChanged:(NSNotification*)sender{
	DebugLog(@"Home View - OK, I know unread count changed");
	self.unreadCountChanged = YES;
}

-(void)dataSyncBegan:(NSNotification*)sender{
	DebugLog(@"Home View - OK, I know unread count changed");
	self.structureChanged = NO;
	self.unreadCountChanged = NO;
}

-(void)dataSyncEnded:(NSNotification*)sender{
	DebugLog(@"Home View - data sync end");
	if (self.structureChanged || self.unreadCountChanged){
		@synchronized(self){
			[self.dataSource refresh];
			[self performSelectorOnMainThread:@selector(updateTableView)
								   withObject:nil
								waitUntilDone:NO];
		}
	}
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.dataSource refresh];
	[self updateTableView];
}

-(void)loadView{
	HomeDataSource* theDataSource = [[HomeDataSource alloc] init];
	// retain the data source
	self.dataSource = theDataSource;
	[theDataSource release];
	//create a config button in navigation bar
	UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] init];

	leftButton.title = NSLocalizedString(@"Logout", nil);
	leftButton.target = self;
	leftButton.action = @selector(loginButtonActoin:);
	
	self.navigationItem.leftBarButtonItem = leftButton;
	self.loginButton = leftButton;
	[leftButton release];
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] init];
	
	rightButton.title = NSLocalizedString(@"Download", nil);
	rightButton.target = self;
	rightButton.action = @selector(enableDownloadMode:);
	
	self.downloadButton = rightButton;
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	UITableView* tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[self.dataSource tableViewStyle]];
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
//	tableView.allowsSelectionDuringEditing = YES;
	self.navigationItem.title = [self.dataSource name];	
	tableView.delegate = self;
	tableView.dataSource = self.dataSource; 
	
	// set the tableview as the controller view
    self.theTableView = tableView;
	self.view = tableView;
	[tableView release];
}

-(void)viewDidUnload{
	self.theTableView = nil;
	self.view = nil;
	self.dataSource = nil;
	[super viewDidUnload];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	if ([UserPreferenceDefine iPadMode]){//if in iPad mode, need to reload left navigation button item, in order to avoid display issue
		if (self.navigationItem.leftBarButtonItem != nil){
			[self.navigationItem setLeftBarButtonItem:nil 
											 animated:NO];
			[self.navigationItem setLeftBarButtonItem:self.loginButton 
											 animated:NO];
		}
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString* sectionType = [self.dataSource.sectionKeys objectAtIndex:[indexPath section]];
	
	id targetObj = [self.dataSource objectForIndexPath:indexPath];
	
	UITableViewController* nextViewController = nil;
	
	if ([sectionType isEqualToString:SUBLISTSECTIONNAME]){
		if ([UserPreferenceDefine iPadMode]){
			[self sendSelectNotification:targetObj];
		}else{
			nextViewController = [[FeedViewController alloc] initWithObject:targetObj];
		}
	}else if ([sectionType isEqualToString:TAGLISTSECTIONNAME]){
		nextViewController = [[TagViewController alloc] initWithGRTag:targetObj];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}else if ([sectionType isEqualToString:STATESLISTSECTIONNAME]){
		if ([UserPreferenceDefine iPadMode]){
			[self sendSelectNotification:targetObj];
		}else {
			nextViewController = [[FeedViewController alloc] initWithObject:targetObj];
		}

	}else if ([sectionType isEqualToString:DISCOVERSECTION]) {
//		if ([UserPreferenceDefine iPadMode]){
//			[self sendSelectNotificationWithClass:@"RecommendedFeedsViewController" 
//										  initObj:targetObj];
//		}else {
		switch (((GRDiscover*)targetObj).type) {
			case GRDiscoverTypeRecFeeds:
				if ([UserPreferenceDefine iPadMode]){
					[self sendSelectNotificationWithClass:@"RecommendedFeedsViewController" 
												  initObj:targetObj];
				}else {
				nextViewController = [[RecommendedFeedsViewController alloc] initWithGRDiscover:(GRDiscover*)targetObj];
				}
				break;
			case GRDiscoverTypeRecItems:
				
				break;
			case GRDiscoverTypeAddNewFeed:
				nextViewController = [[AddNewFeedViewController alloc] initWithNibName:@"AddNewFeedViewController" bundle:nil];
				UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:nextViewController];
				[nextViewController release];
				nextViewController = nil;
				if ([UserPreferenceDefine iPadMode]){
					nv.modalPresentationStyle = UIModalPresentationFormSheet;
					nv.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				}
				[self presentModalViewController:nv animated:YES];
				[nv release];
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			case GRDiscoverTypeSearchFeeds:
//				nextViewController = [[SearchFeedsViewController alloc] initWithNibName:@"SearchFeedsViewController" bundle:nil];
				break;
			default:
				break;
		}
//		}

	}
	
	if (nextViewController){
		[self.navigationController pushViewController:nextViewController animated:YES];
	}
	
	[nextViewController release];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return [self.dataSource editingStyleForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString* sectionType = [self.dataSource.sectionKeys objectAtIndex:[indexPath section]];
	
	NSString* deleteConfirmTitle = nil;
	if ([sectionType isEqualToString:SUBLISTSECTIONNAME]){
		deleteConfirmTitle = NSLocalizedString(@"Unsubscribe", nil);
	}else if ([sectionType isEqualToString:TAGLISTSECTIONNAME]){
		deleteConfirmTitle = NSLocalizedString(@"DeleteTag", nil);
	}
	
    return deleteConfirmTitle;
}
/*
#pragma mark -
#pragma mark Memory management
*/
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
*/

-(void)viewDidLoad{
	DebugLog(@"did load home view");
	[super viewDidLoad];
	if ([UserPreferenceDefine iPadMode]){
		DebugLog(@"select row at 0,1");
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		[self tableView:self.theTableView didSelectRowAtIndexPath:indexPath];
		[self.theTableView selectRowAtIndexPath:indexPath
									   animated:YES 
								 scrollPosition:UITableViewScrollPositionNone];
	}
}


- (void)dealloc {
	//unregister event
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:TAGORSUBCHANGED 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UNREADCOUNTCHANGED 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:BEGANSYNCDATA 
												  object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:ENDSYNCDATA 
												  object:nil];		
	[[GoogleAuthManager shared] removeObserver:self forKeyPath:LOGINSTATUS];
	
	[self.dataSource release];
	[self.theTableView release];
	[self.loginButton release];
	[self.downloadButton release];
    [super dealloc];
}


@end

