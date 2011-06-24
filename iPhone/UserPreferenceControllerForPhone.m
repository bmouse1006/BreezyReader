//
//  UserPreferenceControllerForPhone.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceControllerForPhone.h"


@implementation UserPreferenceControllerForPhone

@synthesize dataSource = _dataSource;
#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	[super loadView];
	UITableView* theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
															 style:UITableViewStyleGrouped];
	UserPreferenceDataSouce* ds = [[UserPreferenceDataSouce alloc] init];
	self.dataSource = ds;
	theTableView.dataSource = ds;
	theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	[ds release];
	self.tableView = theTableView;
	self.view = theTableView;
	self.title = NSLocalizedString(@"UserPreference", nil);
	
	UIBarButtonItem* resetButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil)
																	style:UIBarButtonItemStyleBordered
																   target:self
																   action:@selector(resetUserPreference)];
	self.navigationItem.rightBarButtonItem = resetButton;
	[resetButton release];
	
	[theTableView release];
	
}

-(void)resetUserPreference{
	DebugLog(@"reset user preference");
	[UserPreferenceDefine resetPreference];
	[self.tableView reloadData];
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
    // Return YES for supported orientations
    return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
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
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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


#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	/*
//	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//	 [self.navigationController pushViewController:detailViewController animated:YES];
//	 [detailViewController release];
//	 */
//}


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

-(id)init{
	if (self = [super init]){
		
		UITabBarItem* barItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"UserPreference", nil) 
															  image:[UIImage imageNamed:@"cog.png"] 
																tag:0];
		self.tabBarItem = barItem;
		[barItem release];
	
	}
	
	return self;
}

- (void)dealloc {
	[self.dataSource release];
    [super dealloc];
}


@end

