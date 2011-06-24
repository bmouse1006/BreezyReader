//
//  DownloadedItemsViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadedItemsViewController.h"
#import "ItemViewController.h"

@implementation DownloadedItemsViewController

@synthesize theTableView = _theTableView;
@synthesize dataSource = _dataSource;
@synthesize sub = _sub;
@synthesize clearButton = _clearButton;
@synthesize actionSheet = _actionSheet;

#pragma mark -
#pragma mark Initialization

-(id)initWithSubscription:(GRSubscription*)sub{
	if (self = [super init]){
		self.sub = sub;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemDownloadFinished:) 
													 name:ITEMDOWNLOADFINISHED 
												   object:nil];	
	}
	
	return self;
}

-(id)initWithObject:(id)sub{
	if (self = [super init]){
		self.sub = sub;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemDownloadFinished:) 
													 name:ITEMDOWNLOADFINISHED 
												   object:nil];	
	}
	
	return self;
}



#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
																	style:UIBarButtonItemStyleBordered 
																   target:self
																   action:@selector(clearButtonAction:)];
	
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	DownloadedItemsDataSource* mDataSource = [[DownloadedItemsDataSource alloc] initWithSubscription:self.sub];
	self.dataSource = mDataSource;
	UITableView* tempTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
															  style:[mDataSource tableViewStyle]];
	tempTableView.delegate = self;
	tempTableView.dataSource = mDataSource;
	tempTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	self.theTableView = tempTableView;
	self.view = self.theTableView;
	self.dataSource = mDataSource;
	self.dataSource.tableView = self.theTableView;
	self.title = [mDataSource name];
	
	[tempTableView release];
	[mDataSource release];
	
	[self.dataSource refresh];
	[self.theTableView reloadData];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[self.navigationController setToolbarHidden:YES 
									   animated:YES];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark actions for button and action sheet

-(void)clearButtonAction:(id)sender{
	if (!self.actionSheet){
		UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:NSLocalizedString(@"ClearAllArticle", nil)
														otherButtonTitles:nil];
		self.actionSheet = as;
		[as release];
		if ([UserPreferenceDefine iPadMode]){
			[self.actionSheet showFromBarButtonItem:sender 
									  animated:YES];
		}else{
			[self.actionSheet showInView:self.view.window];
		}
	}else {
		[self.actionSheet dismissWithClickedButtonIndex:1 animated:YES];
		self.actionSheet = nil;
	}

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"ClearAllArticle", nil)]){
		[self.dataSource clearAllItems];
	}
	self.actionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
//	[self.theTableView reloadData];
	self.actionSheet = nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ItemViewController* itemViewController = [[ItemViewController alloc] initWithItems:[self.dataSource GRItemList] itemIndex:indexPath];
	
	itemViewController.onlineMode = NO;
	
	if ([UserPreferenceDefine iPadMode]){
		
		UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:itemViewController];
		nav.modalPresentationStyle = UIModalPresentationPageSheet;
		nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:nav 
								animated:YES];
		[nav release];

	}else{
		[self.navigationController pushViewController:itemViewController 
											 animated:YES];
	}
	
	[itemViewController release];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	CGFloat height = 44;
	
	if ([UserPreferenceDefine iPadMode] || [UserPreferenceDefine shouldShowPreviewOfArticle]){
		height = 60;
	}
	
	return height;

}

-(void)itemDownloadFinished:(NSNotification*)notification{
	[self.theTableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.theTableView = nil;
	self.view = nil;
	self.dataSource = nil;
	self.actionSheet = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:ITEMDOWNLOADFINISHED
												  object:nil];	
	[self.dataSource release];
	[self.theTableView release];
	[self.sub release];
	[self.clearButton release];
	self.actionSheet = nil;
    [super dealloc];
}


@end

