//
//  AddNewTagViewController.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-8.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "AddNewTagViewController.h"
#import "UserPreferenceDefine.h"

@implementation AddNewTagViewController

@synthesize doneButton = _doneButton;
@synthesize cancelButton = _cancelButton;
@synthesize cell = _cell;
@synthesize tagName = _tagName;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSBundle mainBundle] loadNibNamed:@"AddNewTagViewController" owner:self options:nil];
	self.tagName.placeholder = NSLocalizedString(@"newTagName", nil);
	self.tagName.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	[self.tagName becomeFirstResponder];
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.doneButton;
	self.navigationItem.title = NSLocalizedString(@"addNewTag", nil);
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (!self.cell){
		[[NSBundle mainBundle] loadNibNamed:@"AddNewTagViewController" owner:self options:nil];

	}
	
	return self.cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}



#pragma mark -
#pragma mark IBAction

-(IBAction)cancel{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)done{
	//send notification to choose label view and dismiss modal view
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.tagName.text, NOTIFICATION_ADDNEWTAG_LABELNAME, nil];
	
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_ADDNEWTAG 
																 object:self 
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)tagNameChanges:(id)sender{
	if (!self.tagName.text || [self.tagName.text isEqualToString:@""]){
		self.doneButton.enabled = NO;
	}else {
		self.doneButton.enabled = YES;
	}

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


- (void)dealloc {
	self.doneButton = nil;
	self.cancelButton = nil;
	self.cell = nil;
	self.tagName = nil;
    [super dealloc];
}


@end

