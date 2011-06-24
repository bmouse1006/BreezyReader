//
//  DownloaderHomeViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllSubscriptionViewController.h"
#import "DownloaderViewController.h"

typedef enum {
	DownloaderCurrentViewAllSub = 0,
	DownloaderCurrentViewDownloader
} DownloaderCurrentHomeView;

@interface DownloaderHomeViewController : UIViewController{
	
	AllSubscriptionViewController* _allSubscriptionViewController;
	DownloaderViewController* _downloaderViewController;
	
	DownloaderCurrentHomeView _currentView;
	
	UIViewController* _currentController;
	
	UISegmentedControl* _viewSwitch;

}

@property (nonatomic, retain) AllSubscriptionViewController* allSubscriptionViewController;
@property (nonatomic, retain) DownloaderViewController* downloaderViewController;
@property (nonatomic, assign) DownloaderCurrentHomeView currentView;
@property (nonatomic, retain) UISegmentedControl* viewSwitch;
@property (nonatomic, retain) UIViewController* currentController;

@end

@interface DownloaderHomeViewController (private)

-(void)setBadgeValueForTabBarItem;

@end

