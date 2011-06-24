//
//  AppDelegate_Pad.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainSplitViewController.h"

@interface AppDelegate_Pad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	MainSplitViewController* _mainSplitController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainSplitViewController* mainSplitController;

-(void)setupEnvironmentAndLoadHomeView;
-(void)storeCurrentStatus;

@end

