//
//  AppDelegate_Pad.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"
#import "MainTabBarController_pad.h"
#import "HomeViewController.h"
#import "MainSplitViewController.h"
#import "GRDownloadManager.h"
#import "DefaultScreenPad.h"

@implementation AppDelegate_Pad

@synthesize window;
@synthesize mainSplitController = _mainSplitController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	[self setupEnvironmentAndLoadHomeView];
	
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
	DebugLog(@"applicatoin is resigning");
	[self storeCurrentStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application{
	DebugLog(@"application will terminate");
	[self storeCurrentStatus];
}

-(void)setupEnvironmentAndLoadHomeView{
	
	//created navigation controller and added to subview of current window
	//	
	MainSplitViewController* splitViewController = [[MainSplitViewController alloc] init];
	
	self.mainSplitController = splitViewController;
	
	[splitViewController release];
	
	MainTabBarControllerPad* tabBarController = [[MainTabBarControllerPad alloc] init];

	UINavigationController* detailController = [[UINavigationController alloc] init];
	
	self.mainSplitController.theDetailViewController = detailController;
	self.mainSplitController.viewControllers = [NSArray arrayWithObjects:tabBarController, detailController, nil];

	[detailController release];
	[tabBarController release];
	
//	DefaultScreenPad* pad = [[DefaultScreenPad alloc] init];
	
	[window addSubview:self.mainSplitController.view];
//	[window addSubview:pad.view];
//	[pad release];
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
	DebugLog(@"Application did receive memory warning");
	[GRDataManager didReceiveMemoryWarning];
	[GRObjectsManager didReceiveMemoryWarning];
	[GRDownloadManager didReceiveMemoryWarning];
	[GRItem didReceiveMemoryWarning];
}

-(void)applicationDidBecomeActive:(UIApplication*)application{
	DebugLog(@"Application did become active");
	if ([[GoogleAuthManager shared] hasLogin]){
		[[GRDataManager shared] syncReaderStructure];
	}
}

-(void)storeCurrentStatus{
	[[GRDataManager shared] writeListToFile];
	[[GoogleAuthManager shared] writeAuthInfoToFile];
	[[GRDownloadManager shared] stopAllDownloaders];
}

- (void)dealloc {
    [window release];
	[self.mainSplitController release];
    [super dealloc];
}


@end
