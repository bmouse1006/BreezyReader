//
//  RecommendedFeedsViewController.m
//  SmallReader
//
//  Created by Jin Jin on 10-10-28.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "RecommendedFeedsViewController.h"
#import "ChooseLabelForSubController.h"
#import "FeedViewControllerPad.h"
#import "GRSubscription.h"

#define RECFEEDSROWHEIGHT 66
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@implementation RecommendedFeedsViewController

@synthesize discoverObj = _discoverObj;
@synthesize theTableView = _theTableView;
@synthesize activityIndicator = _activityIndicator;
@synthesize dataSource = _dataSource;
@synthesize lastSubscribedStreamID = _lastSubscribedStreamID;

#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	UITableView* tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
														  style:UITableViewStylePlain];
	tableView.rowHeight = RECFEEDSROWHEIGHT;
    tableView.backgroundColor = DARK_BACKGROUND;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.theTableView = tableView;
	[tableView release];
	
	RecFeedsDataSource* ds = [[RecFeedsDataSource alloc] init];
	self.dataSource = ds;
	[ds release];
	
	self.theTableView.delegate = self;
	self.theTableView.dataSource = self.dataSource;
	
	UIActivityIndicatorView* ind = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	ind.hidesWhenStopped = YES;
	self.activityIndicator = ind;
	[ind release];
	
	UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	
	self.navigationItem.rightBarButtonItem = item;
	[item release];
	
	self.view = self.theTableView;
	
	[self.dataSource refresh];
	[self.activityIndicator startAnimating];
	[self.dataSource.readerDM refreshRecFeedsList];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = self.dataSource.name;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidUnload{
	[super viewDidUnload];
	
	self.view = nil;
	self.theTableView = nil;
	self.dataSource = nil;
	self.activityIndicator = nil;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = YES;
}

#pragma mark -
#pragma mark call back methods
-(void)recFeedsRefreshed{
	@synchronized(self){
		[self.activityIndicator stopAnimating];
		[self.dataSource refresh];
		[self performSelectorOnMainThread:@selector(updateTableView) 
							   withObject:nil
							waitUntilDone:NO];
	}
}

-(void)receiveSubscribeRequest:(NSNotification*)notification{
	GRRecFeed* feed = [notification.userInfo objectForKey:NOTIFICATION_SUBSCRIBEFEED_FEEDOBJ];

	ChooseLabelForSubController* chooseLabel = [[ChooseLabelForSubController alloc] initWithSubTitle:feed.title andStreamID:feed.streamID];
	chooseLabel.delegate = self;
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:chooseLabel];
	[chooseLabel release];
	
	if ([UserPreferenceDefine iPadMode]){
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
		nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	[self presentModalViewController:nav 
							animated:YES];

	[nav release];
	
	//register notification observer for this stream
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tagSelectedForStream:)
												 name:[NOTIFICATION_SUBSCRIBEFEED_TAGSELECTED stringByAppendingString:feed.streamID]
											   object:nil];
}

//-(void)tagSelectedForStream:(NSNotification*)notification{
//	
//	NSString* streamID = [notification.userInfo objectForKey:NOTIFICATION_SUBSCRIBEFEED_STREAMID];
//	NSString* title = [notification.userInfo objectForKey:NOTIFICATION_SUBSCRIBEFEED_TITLE];
//	NSSet* selectedTags = [notification.userInfo objectForKey:NOTIFICATION_SUBSCRIBEFEED_SELECTEDTAGS];
//	
//	//send out subscribe request for every selected tag
//	for (GRTag* tag in [selectedTags allObjects]){
//		NSString* label = nil;
//		if (![tag.label isEqualToString:NOLABEL]){
//			label = tag.ID;
//		}
//		[[GRDataManager shared] subscribeFeed:streamID 
//									withTitle:title 
//									  withTag:label];
//	}
//	//remove notification observer for this stream
//	[[NSNotificationCenter defaultCenter] removeObserver:self 
//													name:[NOTIFICATION_SUBSCRIBEFEED_TAGSELECTED stringByAppendingString:streamID] 
//												  object:nil];
//}

-(void)updateTableView{
	DebugLog(@"number of removeSecions:%i", [self.dataSource.removeSections count]);
	DebugLog(@"number of insertSections:%i", [self.dataSource.insertSections count]);
	DebugLog(@"number of removeIndexPath:%i", [self.dataSource.removeIndexs count]);
	DebugLog(@"number of insertIndexPath:%i", [self.dataSource.insertIndexs count]);
	[self.theTableView beginUpdates];
	if (self.dataSource.removeSections)
		[self.theTableView deleteSections:self.dataSource.removeSections 
						 withRowAnimation:UITableViewRowAnimationFade];
	if (self.dataSource.removeIndexs)
		[self.theTableView deleteRowsAtIndexPaths:self.dataSource.removeIndexs
								 withRowAnimation:UITableViewRowAnimationFade];
	if (self.dataSource.insertSections)
		[self.theTableView insertSections:self.dataSource.insertSections
						 withRowAnimation:UITableViewRowAnimationFade];
	if (self.dataSource.insertIndexs)
		[self.theTableView insertRowsAtIndexPaths:self.dataSource.insertIndexs
								 withRowAnimation:UITableViewRowAnimationFade];
	
	[self.theTableView endUpdates];
	
	[self.dataSource eraseChangeDataForRowAndSections];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	id targetObj = [self.dataSource objectForIndexPath:indexPath];

	//create a view controller and pop up as modal view 
	
	FeedViewControllerPad* nextViewController = [[FeedViewControllerPad alloc] initWithObject:[GRSubscription subscriptionForGRRecFeed:targetObj]];
	
	nextViewController.showSource = NO;
	nextViewController.modalStyle = YES;
	
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:nextViewController];
	
	[nextViewController release];
	
	if ([UserPreferenceDefine iPadMode]){
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
		nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	[self presentModalViewController:nav
							animated:YES];
	[nav release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return RECFEEDSROWHEIGHT;
}

#pragma mark -
#pragma mark delegate methods for ChooseLabelForSubDelegate
-(void)didCancelSubscribeForFeed:(NSString*)streamID{
	//do nothing now
	DebugLog(@"do nothing for subscribe cancel so far");
}

-(void)didChooseLabelForFeed:(NSString*)streamID labels:(NSArray*)labels withTitle:(NSString*)mTitle{
	for (GRTag* tag in labels){
		NSString* label = nil;
		if (![tag.label isEqualToString:NOLABEL]){
			label = tag.ID;
		}
		[[GRDataManager shared] subscribeFeed:streamID 
									withTitle:mTitle 
									  withTag:label];
	}
}

-(void)didFinishLabelChoose:(NSString *)streamID{
	//do nothing
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


-(id)initWithGRDiscover:(GRDiscover*)discover{
	if (self = [super init]){
		self.discoverObj = discover;
		self.hidesBottomBarWhenPushed = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(recFeedsRefreshed) 
													 name:NOTIFICATION_ALLRECOMMENDATIONS 
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(receiveSubscribeRequest:) 
													 name:NOTIFICATION_SUBSCRIBEFEED 
												   object:nil];	

	}
	
	return self;
}

-(id)initWithObject:(id)initObj{
	
	id ret = nil;
	
	if ([initObj isKindOfClass:[GRDiscover class]]){
		ret = [self initWithGRDiscover:initObj];
	}
	
	return ret;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_ALLRECOMMENDATIONS
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_SUBSCRIBEFEED
												  object:nil];
	self.discoverObj = nil;
	self.activityIndicator = nil;
	self.theTableView = nil;
	self.dataSource = nil;
	self.lastSubscribedStreamID = nil;
    [super dealloc];
}


@end

