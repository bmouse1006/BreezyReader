//
//  AddNewFeedViewController.m
//  SmallReader
//
//  Created by Jin Jin on 10-12-11.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "AddNewFeedViewController.h"
#import "UserPreferenceDefine.h"
#import "GRTag.h"
#import "GRDataManager.h"

@implementation AddNewFeedViewController

@synthesize theTableView =_theTableView;
@synthesize URLInputCell = _URLInputCell;
@synthesize labelCell = _labelCell;
@synthesize subscribeCell = _subscribeCell;
@synthesize subscribeLabel = _subscribeLabel;
@synthesize tagLabel = _tagLabel;
@synthesize URLLabel = _URLLabel;
@synthesize URLText = _URLText;
@synthesize selectedTagsLabel = _selectedTagsLabel;
@synthesize cancelButton = _cancelButton;
@synthesize activeIndicator = _activeIndicator;

@synthesize selectedTags = _selectedTags;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"addNewFeed", nil);
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	[self.activeIndicator stopAnimating];
	[self localizeUI];
	[self.URLText becomeFirstResponder];
	[self showAllSelectedTags];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger nb = 0;
	switch (section) {
		case 0:
			nb = 2;
			break;
		case 1:
			nb = 1;
		default:
			break;
	}
    return nb;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell* cell = nil;
	
	switch ([indexPath section]) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell = self.URLInputCell;
					break;
				case 1:
					cell = self.labelCell;
					break;
				default:
					break;
			}
			break;
		case 1:
			cell = self.subscribeCell;
		default:
			break;
	}

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
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

-(IBAction)cancelAction{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)localizeUI{
	self.subscribeLabel.text = NSLocalizedString(self.subscribeLabel.text, nil);
	self.URLLabel.text = NSLocalizedString(self.URLLabel.text, nil);
	self.tagLabel.text = NSLocalizedString(self.tagLabel.text, nil);
}

-(void)confirmSubscribe{
	self.subscribeLabel.hidden = YES;
	self.theTableView.allowsSelection = NO;
	[self.activeIndicator startAnimating];
	
	NSString* streamID = [@"feed/" stringByAppendingString:self.URLText.text];
	NSString* tagID = nil;
	for (GRTag* tag in self.selectedTags){
		if (![tag.label isEqualToString:NOLABEL]){
			tagID = tag.ID;
		}
	[[GRDataManager shared] subscribeFeed:streamID
								withTitle:nil
								  withTag:tagID];
	}
}

-(void)subscribeSuccess{
	//Need to perform any UI update related operation in main thread
	[self performSelectorOnMainThread:@selector(taskSubscribeSuccess) 
						   withObject:nil 
						waitUntilDone:NO];
}

-(void)taskSubscribeSuccess{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)subscribeFailed{
	//Need to perform any UI update related operation in main thread
	[self performSelectorOnMainThread:@selector(taskSubscribeFailed)
						   withObject:nil
						waitUntilDone:NO];
}

-(void)taskSubscribeFailed{
	[self.activeIndicator stopAnimating];
	self.subscribeLabel.hidden = NO;
	self.theTableView.allowsSelection = YES;
	UIAlertView* failedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorMessage", nil)
														  message:NSLocalizedString(@"subscribeFailedMessage", nil)
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												otherButtonTitles:nil];
	[failedAlert show];
	[failedAlert release];
}

-(void)showAllSelectedTags{
	NSMutableString* tagLabelString = [NSMutableString stringWithCapacity:0];
	
	for (GRTag* tag in self.selectedTags){
		if ([self.selectedTags indexOfObject:tag] == 0){
			//the first label
			[tagLabelString appendFormat:@"%@", NSLocalizedString([tag presentationString], nil)];
		}else {
			[tagLabelString appendFormat:@", %@", NSLocalizedString([tag presentationString], nil)];
		}
	}
	
	self.selectedTagsLabel.text = tagLabelString;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell == self.labelCell){
		ChooseLabelForSubController* chooseLabel = [[ChooseLabelForSubController alloc] initWithSelectedTags:self.selectedTags];
		chooseLabel.delegate = self;
		UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:chooseLabel];
		[chooseLabel release];
		if ([UserPreferenceDefine iPadMode]){
			nv.modalPresentationStyle = UIModalPresentationFormSheet;
			nv.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		}
		
		[self presentModalViewController:nv animated:YES];
		[nv release];
	}else if (cell == self.subscribeCell){
		[self confirmSubscribe];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark --
#pragma mark delegate methods for ChooseLabelForSubController
-(void)didCancelSubscribeForFeed:(NSString*)streamID{
	//do nothing
}

-(void)didChooseLabelForFeed:(NSString*)streamID labels:(NSArray*)labels withTitle:(NSString*)title{
	self.selectedTags = [NSMutableArray arrayWithArray:labels];
	[self showAllSelectedTags];
}

-(void)didFinishLabelChoose:(NSString*)streamID{
	//do nothing
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

-(void)releaseOutlet{
	self.URLText = nil;
	self.URLInputCell = nil;
	self.subscribeCell = nil;
	self.subscribeLabel = nil;
	self.labelCell = nil;
	self.selectedTagsLabel = nil;
	self.cancelButton = nil;
	self.activeIndicator = nil;
	self.URLLabel = nil;
	self.tagLabel = nil;
	self.theTableView = nil;
}

- (void)viewDidUnload {
	[self releaseOutlet];
	self.view = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:NOTIFICATION_SUBSCRIBEFEED_SUCCESS 
											   object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:NOTIFICATION_SUBSCRIBEFEED_FAILED
											   object:nil];	
	[self releaseOutlet];
    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(subscribeSuccess) 
													 name:NOTIFICATION_SUBSCRIBEFEED_SUCCESS 
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(subscribeFailed) 
													 name:NOTIFICATION_SUBSCRIBEFEED_FAILED
												   object:nil];	
		GRTag* noname = [[GRTag alloc] init];
		noname.label = NOLABEL;
		
		self.selectedTags = [NSMutableArray arrayWithCapacity:0];
		[self.selectedTags addObject:noname];
		[noname release];
		
	}

	return self;
}


@end

