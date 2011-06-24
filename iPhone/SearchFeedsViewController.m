//
//  SearchFeedsViewController.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-18.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "SearchFeedsViewController.h"


@implementation SearchFeedsViewController

@synthesize searchString = _searchString;
@synthesize dataSource = _dataSource;
@synthesize theTableView = _theTableView;
#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	SearchFeedsDataSource* ds = [[SearchFeedsDataSource alloc] init];
	self.dataSource = ds;
	self.theTableView.dataSource = ds;
	[ds release];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Search Display delegate
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
	DebugLog(@"search did begin");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
	DebugLog(@"search did end");
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
	self.searchString = nil;
	self.dataSource = nil;
	self.theTableView = nil;
    [super dealloc];
}


@end

