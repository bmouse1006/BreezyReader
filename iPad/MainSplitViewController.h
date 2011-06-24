//
//  MainSplitViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-9-5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJSplitViewController.h"

@interface MainSplitViewController : JJSplitViewController {
	UINavigationController* _theDetailViewController;
}

@property (nonatomic, retain) UINavigationController* theDetailViewController;

@end
