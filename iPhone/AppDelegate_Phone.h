//
//  AppDelegate_Phone.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAppLib.h"
#import "TestViewController.h"
#import "MainTabBarController.h"
#import "HomeDataSource.h"
#import "GRDataManager.h"

@interface AppDelegate_Phone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	TestViewController* _testView;
	
	MainTabBarController* _mainTabBarContoller;
	
	UINavigationController* _superNavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) TestViewController* testView;
@property (nonatomic, retain) MainTabBarController* mainTabBarContoller;
@property (nonatomic, retain) UINavigationController* superNavigationController;

-(void)setupEnvironmentAndLoadHomeView;
-(void)storeCurrentStatus;

@end

