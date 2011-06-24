//
//  AllSubscriptionViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AllSubscriptionViewController.h"
#import "AllSubscriptionDataSource.h"
#import "DownloadedItemsViewController.h"
#import "GRDataManager.h"
#import "GRSubscription.h"
#import "GRDownloadManager.h"


@implementation AllSubscriptionViewController

@synthesize dataSource = _dataSource;
@synthesize theTableView = _theTableView;
@synthesize theNavigationController = _theNavigationController;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	
	DebugLog(@"loading all subscription view");
	AllSubscriptionDataSource* source = [[AllSubscriptionDataSource alloc] init];
	self.dataSource = source;
	[source release];
	
	UITableView* tempTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[self.dataSource tableViewStyle]];
	tempTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tempTableView.dataSource = source;
	tempTableView.delegate = self;
	
	self.theTableView = tempTableView;
	self.view = tempTableView;
	
	[tempTableView release];
	
}

- (void)viewDidLoad {
	[self reloadSourceAndTable];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
//    self.theTableView  = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
	DebugLog(@"view will appear");
	[super viewWillAppear:animated];
	[self.theTableView deselectRowAtIndexPath:[self.theTableView indexPathForSelectedRow] animated:YES];
	[self reloadSourceAndTable];
}


- (void)viewDidAppear:(BOOL)animated {
	DebugLog(@"view did appear");
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	GRSubModel* subModel = [self.dataSource objectForIndexPath:indexPath];
	
	if ([UserPreferenceDefine iPadMode]){
		[self sendSelectNotification:[subModel GRSub]];
	}else {
		DownloadedItemsViewController *itemsViewController = [[DownloadedItemsViewController alloc] initWithObject:[subModel GRSub]];
		
		[self.theNavigationController pushViewController:itemsViewController animated:YES];
		[itemsViewController release];
	}


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
	self.view = nil;
	self.theTableView = nil;
	[super viewDidUnload];
}

-(id)initWithNavigationController:(UINavigationController*)controller{
	if (self = [super init]){
		self.theNavigationController = controller;		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(reloadSourceAndTable) 
													 name:DOWNLOADERQUEUECHANGED 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(reloadSourceAndTable) 
													 name:NOTIFICATION_DELETEDOWNLOADEDSUB
												   object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:DOWNLOADERQUEUECHANGED 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_DELETEDOWNLOADEDSUB 
												  object:nil];
	[self.dataSource release];
	[self.theTableView release];
	[self.theNavigationController release];
    [super dealloc];
}

@end

@implementation AllSubscriptionViewController (private)

-(void)reloadSourceAndTable{
	[self.dataSource refresh];
	[self.theTableView reloadData];
}


-(void)sendSelectNotification:(id)obj{
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"DownloadedItemsViewController", CLASSNAME, obj, INITOBJ, nil]; 
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_SELECTIONINMASTERVIEW
																 object:self
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end


