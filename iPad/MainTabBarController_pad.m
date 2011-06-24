    //
//  MainViewController_pad.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainTabBarController_pad.h"
#import "OnlineReaderNavigationController.h"
#import "OfflineReaderNavigationController.h"
#import "DownloaderHomeViewController.h"
#import "UserPreferenceControllerForPhone.h"

@implementation MainTabBarControllerPad

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
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

-(id)init{
	if (self = [super init]){
		
		HomeViewController* homeVC = [[HomeViewController alloc] init];
		OnlineReaderNavigationController* online = [[OnlineReaderNavigationController alloc] initWithRootViewController:homeVC];
		[homeVC release];
		
		DownloaderHomeViewController* downloaderVC = [[DownloaderHomeViewController alloc] init];
		OfflineReaderNavigationController* offline = [[OfflineReaderNavigationController alloc] initWithRootViewController:downloaderVC];
		[downloaderVC release];
		
		UserPreferenceControllerForPhone* preference = [[UserPreferenceControllerForPhone alloc] init];
		UINavigationController* prefNaviController = [[UINavigationController alloc] initWithRootViewController:preference];
		[preference release];
		
		NSArray* readerControllers = [NSArray arrayWithObjects:online, offline, prefNaviController, nil];
		[offline release];
		[online release];
		[prefNaviController release];
		//	[self setViewControllers:readerControllers animated:YES];
		self.viewControllers = readerControllers;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
