//
//  MainTabBarController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainTabBarController.h"
#import "DownloaderHomeViewController.h"


@implementation MainTabBarController

@synthesize onlineReader = _onlineReader;
@synthesize offlineReader = _offlineReader;
@synthesize preferenceController = _preferenceController;

-(id)init{
	if (self = [super init]){
		
		//online reader 
		HomeViewController* homeVC = [[HomeViewController alloc] init];
		OnlineReaderNavigationController* online = [[OnlineReaderNavigationController alloc] initWithRootViewController:homeVC];
		self.onlineReader = online;
		[online release];
		[homeVC release];
		
		//offline reader
		DownloaderHomeViewController* downloaderVC = [[DownloaderHomeViewController alloc] init];
		OfflineReaderNavigationController* offline = [[OfflineReaderNavigationController alloc] initWithRootViewController:downloaderVC];
		self.offlineReader = offline;
		[downloaderVC release];
		[offline release];

		//preference
		UserPreferenceControllerForPhone* preference = [[UserPreferenceControllerForPhone alloc] init];
		self.preferenceController = preference;
		UINavigationController* prefNaviController = [[UINavigationController alloc] initWithRootViewController:preference];
		[preference release];
		
//		NSArray* readerControllers = [NSArray arrayWithObjects:self.onlineReader, disNav, self.offlineReader,  prefNaviController, nil];
		NSArray* readerControllers = [NSArray arrayWithObjects:self.onlineReader, self.offlineReader,  prefNaviController, nil];
		[prefNaviController release];
		
		//	[self setViewControllers:readerControllers animated:YES];
		self.viewControllers = readerControllers;
	}
	return self;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//	self.view.autoresizesSubviews = YES;
//	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];

}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self.onlineReader release];
	[self.offlineReader release];
	[self.preferenceController release];
    [super dealloc];
}


@end
