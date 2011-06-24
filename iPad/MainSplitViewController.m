    //
//  MainSplitViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-9-5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainSplitViewController.h"
#import "FeedViewControllerPad.h"
#import "LoginViewControllerPad.h"

@implementation MainSplitViewController

@synthesize theDetailViewController = _theDetailViewController;

#pragma mark -
#pragma mark call backs

-(void)selectionInMasterView:(NSNotification*)notification{
	@synchronized(self){
		NSString* className = [notification.userInfo objectForKey:CLASSNAME];
		id initObj = [notification.userInfo objectForKey:INITOBJ];
//		UIViewController* detailViewController = [notification.userInfo objectForKey:DETAILVIEWCONTROLLER];
//		
//		if (detailViewController){
//			NSArray* controllerArray = [NSArray arrayWithObject:detailViewController];
//			[self.theDetailViewController setViewControllers:controllerArray 
//													animated:NO];
//			return;
//		}
		
		if (className && ![className isEqualToString:@""]){
			id detailController = [[NSClassFromString(className) alloc] initWithObject:initObj];
			if ([detailController respondsToSelector:@selector(setInitObject:)]){
				[detailController performSelector:@selector(setInitObject:) withObject:initObj];
			}
			
			NSArray* controllerArray = [NSArray arrayWithObject:detailController];
			[self.theDetailViewController setViewControllers:controllerArray 
													animated:NO];
			[detailController release];
	//		[self layoutViews:self.interfaceOrientation];
		}
	}
}

-(void)selectionInDetailView:(NSNotification*)notification{
}

-(void)needLogin:(NSNotification*)notification{
	DebugLog(@"I know, we need login_main split");
	LoginViewControllerPad* loginViewController = [[LoginViewControllerPad alloc] init];
	loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:loginViewController animated:YES];
	[loginViewController release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:LOGINSTATUS]){
		NSString* newStatus = [change objectForKey:NSKeyValueChangeNewKey];
		NSString* oldStatus = [change objectForKey:NSKeyValueChangeOldKey];
		if([newStatus isEqualToString:LOGIN_SUCCESSFUL] && ![oldStatus isEqualToString:LOGIN_SUCCESSFUL]){
			UIViewController* controller = self.theDetailViewController.topViewController;
			if ([controller respondsToSelector:@selector(refreshDatasource:)]){
				[controller performSelector:@selector(refreshDatasource:) withObject:nil];
			}
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
//    return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	return YES;
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

-(void)viewDidLoad{
	[super viewDidLoad];
	[self layoutViews:self.interfaceOrientation];
	
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

-(id)init{
	if (self == [super init]){
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(selectionInMasterView:) 
													 name:NOTIFICATION_SELECTIONINMASTERVIEW 
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(selectionInDetailView:) 
													 name:NOTIFICATION_SELECTIONINDETAILVIEW 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(needLogin:) 
													 name:LOGINNEEDED 
												   object:nil];
		
		[[GoogleAuthManager shared] addObserver:self 
									 forKeyPath:LOGINSTATUS 
										options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
										context:nil];
	}
	
	return self;
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_SELECTIONINMASTERVIEW 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_SELECTIONINDETAILVIEW 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:LOGINNEEDED
												  object:nil];
	[[GoogleAuthManager shared] removeObserver:self 
									forKeyPath:LOGINSTATUS];
	
	[self.theDetailViewController release];
    [super dealloc];
}


@end
