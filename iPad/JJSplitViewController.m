    //
//  JJSplitViewController.m
//  SmallReader
//
//  Created by Jin Jin on 10-9-5.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import "JJSplitViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JJSplitViewController

//@synthesize viewControllers = _viewControllers;

-(void)loadView{
	UIView* tempView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	tempView.backgroundColor = [UIColor blackColor];
	self.view = tempView;
	[tempView release];	
	for (UIViewController* vc in self.viewControllers){
		[self.view addSubview:vc.view];
	}

}
	
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutViews:interfaceOrientation];
}


-(void)viewDidAppear:(BOOL)animated{
	//a small trick to eliminate 20 pixal space in the top of UITabBarContoller
	[self layoutViews:self.interfaceOrientation];
	for (UIViewController* viewCon in self.viewControllers){
//		[viewCon viewDidAppear:animated];
		if ([viewCon isKindOfClass:[UITabBarController class]]){
			UITabBarController* tabBar = (UITabBarController*)viewCon;
			tabBar.selectedIndex = 0;
		}
	}
	[super viewDidAppear:animated];
}

-(void)layoutViews:(UIInterfaceOrientation)interfaceOrientation{
	
	UIViewController* masterView = [self.viewControllers objectAtIndex:0];
	UIViewController* detailView = [self.viewControllers objectAtIndex:1];
	
	NSInteger gap = 1;
	
	NSInteger SBHEIGHT = 20;
	
	NSInteger landscapeHeight = 768 - SBHEIGHT;
	NSInteger landscapeWidth = 1024;
	NSInteger portraitHeight = 1024 - SBHEIGHT;
	NSInteger portraitWidth = 768;
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		CGRect masterFrame = masterView.view.frame;
		masterFrame.size.width = 320;
		masterFrame.size.height = portraitHeight;
		masterFrame.origin.x = 0;
		masterFrame.origin.y = 0;
		
		[masterView.view setFrame:masterFrame];
		
		CGRect detailFrame = detailView.view.frame;
		detailFrame.size.width = portraitWidth-320-gap;
		detailFrame.size.height = portraitHeight;
		detailFrame.origin.x = 320+gap;
		detailFrame.origin.y = 0;
		
		[detailView.view setFrame:detailFrame];
	}else {
		CGRect masterFrame = masterView.view.frame;
		masterFrame.size.width = 320;
		masterFrame.size.height = landscapeHeight;
		masterFrame.origin.x = 0;
		masterFrame.origin.y = 0;
		
		[masterView.view setFrame:masterFrame];
		
		CGRect detailFrame = detailView.view.frame;
		detailFrame.size.width = landscapeWidth-320-gap;
		detailFrame.size.height = landscapeHeight;
		detailFrame.origin.x = 320+gap;
		detailFrame.origin.y = 0;
		
		[detailView.view setFrame:detailFrame];
	}
}

- (void)dealloc {
	self.viewControllers = nil;
    [super dealloc];
}


@end
