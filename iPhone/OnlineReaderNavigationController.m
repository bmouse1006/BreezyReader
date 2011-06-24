//
//  OnlineReaderNavigationController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OnlineReaderNavigationController.h"


@implementation OnlineReaderNavigationController

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	if ([viewController isKindOfClass:[FeedViewController class]]){
		[self setToolbarHidden:NO animated:YES];
	}else {
		[self setToolbarHidden:YES animated:YES];
	}

}

-(void)viewDidLoad{
	[super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}


-(void)errorHappened:(NSNotification*)sender{

//	if ([[GoogleAuthManager shared] hasLogin]){
	NSError* underLyingError = [sender.userInfo objectForKey:@"NSUnderlyingError"];
		
	NSString* localizedDescription = [underLyingError.userInfo objectForKey:@"NSLocalizedDescription"];
	
	if (!localizedDescription){
		localizedDescription = NSLocalizedString(@"UnknowNetworkError", nil);
	}
	
	if ([[GoogleAuthManager shared] hasLogin]){
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
														message:localizedDescription 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											  otherButtonTitles:nil];
		[alert performSelectorOnMainThread:@selector(show)
								withObject:nil 
							 waitUntilDone:NO];
		[alert release];
	}
//	}
}

-(void)needLogin:(NSNotification*)sender{
	if (![UserPreferenceDefine iPadMode]){
		DebugLog(@"I know, we need login_online reader");
		LoginViewController* loginViewController = [[LoginViewController alloc] init];
		[self presentModalViewController:loginViewController animated:YES];
		[loginViewController release];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:LOGINSTATUS]){
		NSString* newStatus = [change objectForKey:NSKeyValueChangeNewKey];

		if([newStatus isEqualToString:LOGIN_FAILED]){
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
															message:NSLocalizedString(@"Login Failed!", nil)
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
												  otherButtonTitles:nil];
			[alert performSelectorOnMainThread:@selector(show)
									withObject:nil 
								 waitUntilDone:NO];
			[alert release];
		}
	}
}

-(id)init{
	if (self = [super init]){
		UITabBarItem* barItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"OnlineReaderTitle", nil) 
															  image:[UIImage imageNamed:@"rss.png"] 
																tag:0];
		self.tabBarItem = barItem;
		[barItem release];
		
		self.delegate = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(errorHappened:) 
													 name:GRERRORHAPPENED 
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

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:GRERRORHAPPENED 
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:LOGINNEEDED 
												  object:nil];
	[[GoogleAuthManager shared] removeObserver:self forKeyPath:LOGINSTATUS];;
	[super dealloc];
}
@end
