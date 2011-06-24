//
//  ChooseLabelForSubController.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-6.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "ChooseLabelForSubController.h"
#import "GRDataManager.h"
#import "UserPreferenceDefine.h"
#import "AddNewTagViewController.h"

@implementation ChooseLabelForSubController

@synthesize theTableView = _theTableView;
@synthesize tags = _tags;
@synthesize selectedTags = _selectedTags;
@synthesize cellForTag = _cellForTag;
@synthesize subscriptionTitle = _subscriptionTitle;
@synthesize streamID = _streamID;
@synthesize delegate = _delegate;
@synthesize chooseDone = _chooseDone;
#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	UITableView* tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
														  style:UITableViewStyleGrouped];
	self.theTableView = tableView;
	[tableView release];
	
	self.theTableView.delegate = self;
	self.theTableView.dataSource = self;

	self.view = self.theTableView;
	
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				  target:self
																				  action:@selector(cancel)];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(done)];
	
	self.navigationItem.rightBarButtonItem = doneButton;
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.title = self.subscriptionTitle;

}

-(void)viewDidLoad{
	[super viewDidLoad];
	[self createCells];
	[self checkMarkAllCell];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	if (self.chooseDone){
		[self.delegate didFinishLabelChoose:self.streamID];	
	}
}

-(void)cancel{
	NSNotification* notification = [NSNotification notificationWithName:[NOTIFICATION_SUBSCRIBEFEED_CANCELLED stringByAppendingString:self.streamID] object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	[self.delegate didCancelSubscribeForFeed:self.streamID];
}

-(void)done{
	//pass all the tag to parent controller and dismiss this one
	//is it OK to subscribe feed here?
	//or only transfer tags back?
	self.chooseDone = YES;
	[self.delegate didChooseLabelForFeed:self.streamID 
								  labels:[self.selectedTags allValues] 
							   withTitle:self.subscriptionTitle];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString* title = nil;
	if ([self isListSection:section]){
		title = NSLocalizedString(@"SectionHeaderForTagChoose", nil);
	}
	return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger nb = 0;
	switch (section) {
		case 0:
			nb = [self.tags count];
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
			cell = [self.cellForTag objectForKey:[[self.tags objectAtIndex:indexPath.row] presentationString]];
			break;
		case 1:
			cell = [[[UITableViewCell alloc] init] autorelease];
			cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.text = NSLocalizedString(@"addNewTag", nil);
			break;
		default:
			break;
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([self isListSection:[indexPath section]]){
		GRTag* tag = [self.tags objectAtIndex:indexPath.row];
		
		[self changeTagInSelectedList:tag];
	} else {
		AddNewTagViewController* addnew = [[AddNewTagViewController alloc] init];
		UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:addnew];
		[addnew release];
		
		if ([UserPreferenceDefine iPadMode]){
			nav.modalPresentationStyle = UIModalPresentationFormSheet;
		}
		
		[self presentModalViewController:nav 
								animated:YES];
		
		[nav release];

	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)changeTagInSelectedList:(GRTag*)tag{
	GRTag* t = [self.tags objectAtIndex:0];
	if ([[tag presentationString] isEqualToString:NOLABEL]){
		//if no label is selected
		[self.selectedTags removeAllObjects];
		[self.selectedTags setObject:t forKey:[t presentationString]];
	}else {
		[self.selectedTags removeObjectForKey:[t presentationString]];
		if ([self.selectedTags objectForKey:[tag presentationString]]){
			[self.selectedTags removeObjectForKey:[tag presentationString]];
			if ([self.selectedTags count] == 0){
				[self.selectedTags setObject:t forKey:[t presentationString]];
			}
		}else {
			[self.selectedTags setObject:tag forKey:[tag presentationString]];
		}
	}
	
	[self checkMarkAllCell];
}

-(void)checkMarkAllCell{
	for (GRTag* tag in self.tags){
		UITableViewCell* cell = [self.cellForTag objectForKey:[tag presentationString]];
		if ([self.selectedTags objectForKey:[tag presentationString]]){
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
}

-(BOOL)isListSection:(NSInteger)section{
	return (section == 0);
}

#pragma mark -
#pragma mark callback methods
-(void)newTagAdded:(NSNotification*)notification{
	DebugLog(@"new tag is added");
	NSString* tagName = [notification.userInfo objectForKey:NOTIFICATION_ADDNEWTAG_LABELNAME];
	
	GRTag* tag = [[GRTag alloc] initWithLabel:tagName];
	[self.tags addObject:tag];
	[self changeTagInSelectedList:tag];
	[tag release];
	
	[self createCells];
	[self.theTableView reloadData];
	[self checkMarkAllCell];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
							  
-(UITableViewCell*)createCellForTag:(GRTag*)tag{
	
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell.textLabel.text = NSLocalizedString([tag presentationString], nil);
	cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	return cell;
}

-(void)createCells{
	self.cellForTag = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for (GRTag* tag in self.tags){
		UITableViewCell* cell = [self createCellForTag:tag];
		[self.cellForTag setObject:cell forKey:[tag presentationString]];
	}
}

-(id)init{
	if (self = [super init]){
		self.streamID = @"";
		self.delegate = nil;
		self.chooseDone = NO;
		self.tags = [NSMutableArray arrayWithCapacity:0];
		GRTag* noname = [[GRTag alloc] init];
		noname.label = NOLABEL;
		[self.tags addObject:noname];
		[self.tags addObjectsFromArray:[[GRDataManager shared] getLabelList]];
		
		self.selectedTags = [NSMutableDictionary dictionaryWithCapacity:0];
		[self.selectedTags setObject:noname forKey:[noname presentationString]];
		[noname release];
	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(newTagAdded:)
													 name:NOTIFICATION_ADDNEWTAG
												   object:nil];
	}
	
	return self;
}

-(id)initWithSubTitle:(NSString*)subTitle andStreamID:(NSString*)mStreamID{
	if (self = [self init]){
		self.subscriptionTitle = subTitle;
		self.streamID = mStreamID;
	}
	
	return self;
}

-(id)initWithSelectedTags:(NSArray*)mSelectedTags{
	if (self = [self init]){
		self.selectedTags = [NSMutableDictionary dictionaryWithCapacity:0];
		NSMutableDictionary* tempArray = [NSMutableDictionary dictionaryWithCapacity:0];
		
		for (GRTag* tag in self.tags){
			[tempArray setObject:tag
						  forKey:[tag presentationString]];			
		}
		
		for (GRTag* obj in mSelectedTags){
			if (![tempArray objectForKey:[obj presentationString]]){
				[self.tags addObject:obj];
			}
			[self.selectedTags setObject:obj forKey:[obj presentationString]];
		}
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NOTIFICATION_ADDNEWTAG
												  object:nil];
	self.theTableView = nil;
	self.tags = nil;
	self.selectedTags = nil;
	self.cellForTag = nil;
	self.subscriptionTitle = nil;
	self.streamID = nil;
	self.delegate = nil;
    [super dealloc];
}


@end

