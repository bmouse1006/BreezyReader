//
//  AppDelegate_Phone.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_Phone.h"
#import "GRObjectsManager.h"
#import "GRDownloadManager.h"
#import "DefaultScreenPhone.h"

@implementation AppDelegate_Phone

@synthesize window;
@synthesize testView = _testView;
@synthesize mainTabBarContoller = _mainTabBarContoller;
@synthesize superNavigationController = _superNavigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	BOOL testMode = NO;
	
	if (testMode){
		TestViewController* temp = [[TestViewController alloc] init];
		self.testView = temp;
		[temp release];
		[window addSubview:self.testView.view];
	}
	
	if (!testMode){
		[self setupEnvironmentAndLoadHomeView];
	}
	
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application{
	[self storeCurrentStatus];
}

-(void)applicationWillResignActive:(UIApplication *)application{
	[self storeCurrentStatus];
}

-(void)setupEnvironmentAndLoadHomeView{
	
	//created navigation controller and added to subview of current window
//	
	MainTabBarController* tabbar = [[MainTabBarController alloc] init];
	self.mainTabBarContoller = tabbar;
	[tabbar release];
//	
//	DefaultScreenPhone* defaultScreen = [[DefaultScreenPhone alloc] init];
	[window addSubview:self.mainTabBarContoller.view];
//	[window addSubview:defaultScreen.view];
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
	[self.testView release];
	[self.mainTabBarContoller release];
	[self.superNavigationController release];
    [window release];
    [super dealloc];
}

@end
