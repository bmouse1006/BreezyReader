//
//  MainTabBarController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineReaderNavigationController.h"
#import "OfflineReaderNavigationController.h"
#import "UserPreferenceControllerForPhone.h"
#import "UserPreferenceDefine.h"

@interface MainTabBarController : UITabBarController {

	OnlineReaderNavigationController* _onlineReader;
	OfflineReaderNavigationController* _offlineReader;
	UserPreferenceControllerForPhone* _preferenceController;
	
}

@property (nonatomic, retain) IBOutlet OnlineReaderNavigationController* onlineReader;
@property (nonatomic, retain) IBOutlet OfflineReaderNavigationController* offlineReader;
@property (nonatomic, retain) IBOutlet UserPreferenceControllerForPhone* preferenceController;

@end
