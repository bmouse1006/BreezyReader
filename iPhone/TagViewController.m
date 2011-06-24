//
//  TagViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TagViewController.h"


@implementation TagViewController

@synthesize grTag = _grTag;
@synthesize dataSource = _dataSource;
@synthesize theTableView = _theTableView;
@synthesize downloadButton = _downloadButton;
@synthesize structureChanged = _structureChanged;
@synthesize unreadCountChanged = _unreadCountChanged;

-(void)updateTableView{
	DebugLog(@"number of removeSecions:%i", [self.dataSource.removeSections count]);
	DebugLog(@"number of insertSections:%i", [self.dataSource.insertSections count]);
	DebugLog(@"number of removeIndexPath:%i", [self.dataSource.removeIndexs count]);
	DebugLog(@"number of insertIndexPath:%i", [self.dataSource.insertIndexs count]);
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
	
	[self.dataSource eraseChangeDataForRowAndSections];
}

#pragma mark callback action

-(void)tagOrSubChanged:(NSNotification*)sender{
	self.structureChanged = YES;
}

-(void)unreadCountChanged:(NSNotification*)sender{
	self.unreadCountChanged = YES;
}

-(void)dataSyncBegan:(NSNotification*)sender{
	self.unreadCountChanged = NO;
	self.structureChanged = NO;
	
}

-(void)dataSyncEnded:(NSNotification*)sender{
	if (self.unreadCountChanged || self.structureChanged){
		@synchronized(self){
			[self.dataSource refresh];
			[self performSelectorOnMainThread:@selector(updateTableView)
								   withObject:nil
								waitUntilDone:NO];
		}
	}
}

-(void)enableDownloadMode:(id)sender{
	if (self.theTableView.editing){
		self.dataSource.editingStyle = UITableViewCellEditingStyleDelete;
		[self.theTableView setEditing:NO animated:YES]; 
		self.downloadButton.title = NSLocalizedString(@"Download", nil);
		self.downloadButton.style = UIBarButtonItemStyleBordered;
	}else {
		self.dataSource.editingStyle = UITableViewCellEditingStyleInsert;
		[self.theTableView setEditing:YES animated:YES];
		self.downloadButton.title = NSLocalizedString(@"Done", nil);
		self.downloadButton.style = UIBarButtonItemStyleDone;
	}
}

#pragma mark init and dealloc

-(id)initWithGRTag:(GRTag*)mTag{
	if (self = [super init]){
		self.grTag = mTag;
		self.downloadButton = nil;
		self.structureChanged = NO;
		self.unreadCountChanged = NO;
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
	}
	return self;
}

- (void)dealloc {
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
	[self.grTag release];
	[self.downloadButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	TagDataSource* theDataSource = [[TagDataSource alloc] initWithGRTag:self.grTag];
	// retain the data source
	self.dataSource = theDataSource;
	[theDataSource release];
	//create download button
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] init];
	
	rightButton.title = NSLocalizedString(@"Download", nil);
	rightButton.target = self;
	rightButton.action = @selector(enableDownloadMode:);
	
	self.downloadButton = rightButton;
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	//create table view
	UITableView* tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[self.dataSource tableViewStyle]];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
//	tableView.allowsSelectionDuringEditing = YES;
	self.title = [self.dataSource name];
	tableView.delegate = self;
	tableView.dataSource = self.dataSource;

    self.theTableView = tableView;
	self.view = tableView;
	[tableView release];
	DebugLog(@"view loaded");
}
/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (self.dataSource){
		[self.dataSource refresh];
		[self updateTableView];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	GRSubscription* sub = (GRSubscription*)[self.dataSource objectForIndexPath:indexPath];
	FeedViewController *detailViewController = nil;
	if (![UserPreferenceDefine iPadMode]){
		detailViewController = [[FeedViewController alloc] initWithObject:sub];
		[self.navigationController pushViewController:detailViewController animated:YES];	
	}else {
		[self sendSelectNotification:sub];
	}
	[detailViewController release];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
	return NSLocalizedString(@"Unsubscribe", nil);
}

-(void)sendSelectNotification:(id)obj{
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"FeedViewControllerPad", CLASSNAME, obj, INITOBJ, nil]; 
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_SELECTIONINMASTERVIEW
																 object:self
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return [self.dataSource editingStyleForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.dataSource = nil;
	self.theTableView = nil;
	self.downloadButton = nil;
	self.view = nil;
}

@end

