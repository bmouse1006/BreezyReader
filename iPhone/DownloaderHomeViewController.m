//
//  DownloaderHomeViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloaderHomeViewController.h"
#import "GRDownloadManager.h"

@implementation DownloaderHomeViewController

@synthesize allSubscriptionViewController = _allSubscriptionViewController;
@synthesize downloaderViewController = _downloaderViewController;
@synthesize currentView = _currentView;
@synthesize viewSwitch = _viewSwitch;
@synthesize currentController = _currentController;
#pragma mark -
#pragma mark Initialization and dealloc

//
-(id)init{
	if (self = [super init]){
		DownloaderViewController* tempViewController1 = [[DownloaderViewController alloc] init];
		self.downloaderViewController = tempViewController1;
		[tempViewController1 release];
		
		AllSubscriptionViewController* tempViewController2 = [[AllSubscriptionViewController alloc] initWithNavigationController:self.navigationController];
		self.allSubscriptionViewController = tempViewController2;
		[tempViewController2 release];
		
		self.currentView = DownloaderCurrentViewAllSub;
		self.currentController = nil;
		
		UITabBarItem* barItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"DownloadReading", nil) 
															  image:[UIImage imageNamed:@"download.png"] 
																tag:0];
		self.tabBarItem = barItem;
		[barItem release];
		
		[self setBadgeValueForTabBarItem];
		
		//registe downloader queue changed notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(setBadgeValueForTabBarItem) 
													 name:DOWNLOADERQUEUECHANGED 
												   object:nil];	
	}
	
	return self;
}

- (void)dealloc {
	//unregister downloader queue changed notification
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:DOWNLOADERQUEUECHANGED 
												  object:nil];
	[self.allSubscriptionViewController release];
	[self.downloaderViewController release];
	[self.viewSwitch release];
	[self.currentController release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"AlreadyDownloaded", nil), NSLocalizedString(@"DownloadQueue", nil), nil]];
		
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	
	self.navigationItem.titleView = segmentedControl;
	
	self.viewSwitch = segmentedControl;
	
	[segmentedControl release];
	
	switch (self.currentView) {
		case DownloaderCurrentViewAllSub:
			[self.viewSwitch setEnabled:YES forSegmentAtIndex:DownloaderCurrentViewAllSub];
			self.allSubscriptionViewController.theNavigationController = self.navigationController;
			self.view = self.allSubscriptionViewController.view;
			self.currentController = self.allSubscriptionViewController;
			break;
		case DownloaderCurrentViewDownloader:
			[self.viewSwitch setEnabled:YES forSegmentAtIndex:DownloaderCurrentViewDownloader];
			self.view = self.downloaderViewController.view;
			self.currentController = self.downloaderViewController;
			break;
		default:
			break;
	}
	
	[self.viewSwitch addTarget:self
						 action:@selector(segmentValueChanged:) 
			   forControlEvents:UIControlEventValueChanged];
	
	
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.currentController viewWillAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[self.currentController didReceiveMemoryWarning];
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.viewSwitch = nil;
	self.view = nil;
	[self.currentController viewDidUnload];
	[super viewDidUnload];
}

#pragma mark actions
-(void)segmentValueChanged:(id)sender{
	DebugLog(@"segment value changed");
	
	self.currentView = [(UISegmentedControl*)sender selectedSegmentIndex];
	
	UIView* toView = nil;
	
	switch (self.currentView) {
		case DownloaderCurrentViewAllSub:
			toView = self.allSubscriptionViewController.view;
			break;
		case DownloaderCurrentViewDownloader:
			toView = self.downloaderViewController.view;
			break;
		default:
			break;
	}
	
	self.view = toView;
	
}


@end

@implementation DownloaderHomeViewController (private)

-(void)setBadgeValueForTabBarItem{
	NSUInteger queueNumber = [[GRDownloadManager shared] numberofDownloadersForStates:GRDownloaderStatesAll];
	if (queueNumber){
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", queueNumber];
	}else {
		self.tabBarItem.badgeValue = nil;
	}
}

@end

