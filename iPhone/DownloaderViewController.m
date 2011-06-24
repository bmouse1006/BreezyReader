//
//  DownloaderViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloaderViewController.h"
#import "DownloaderViewCell.h"
#import "GRDownloadManager.h"

@implementation DownloaderViewController

@synthesize dataSource = _dataSource;
@synthesize theTableView = _theTableView;

-(void)reloadSourceAndTable{
	[self.dataSource refresh];
	[self.theTableView reloadData];
}

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

#pragma mark -
#pragma mark View lifecycle

-(void)loadView{
	DebugLog(@"loading downloader view");
	DownloaderViewDataSource* source = [[DownloaderViewDataSource alloc] init];
	self.dataSource = source;
	[source release];
	
	UITableView* tempTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
															  style:[self.dataSource tableViewStyle]];
	
	tempTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tempTableView.dataSource = source;
	tempTableView.delegate = self;
//	tempTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.theTableView = tempTableView;
	self.view = tempTableView;
	
	[tempTableView release];
	
	[self reloadSourceAndTable];	
	
	//regesiter downloader queue changed notification
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//	[self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//							 withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 54;
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
	self.dataSource = nil;
	self.theTableView = nil;
	self.view = nil;
}

#pragma mark -
#pragma mark init and dealloc

-(id)init{
	if (self = [super init]){
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(downloaderQueueChanged:) 
													 name:DOWNLOADERQUEUECHANGED 
												   object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:DOWNLOADERQUEUECHANGED 
												  object:nil];
	[self.dataSource release];
	[self.theTableView release];
    [super dealloc];
}

@end

@implementation DownloaderViewController (private)


#pragma mark -
#pragma mark notification handler

-(void)downloaderQueueChanged:(NSNotification*)sender{
	NSDictionary* userInfo = sender.userInfo;
	
	NSIndexSet* indexSet = [userInfo objectForKey:DOWNLOADERQUEUECHANGEDINDEXSET];
	NSNumber* changedType = [userInfo objectForKey:DOWNLOADERQUEUECHANGEDTYPE];
	
	GRDownloadManagerQueueChangeType type = [changedType intValue];
	if (type == GRDownloaderQueueChangeTypeStateChange){
		return;
	}
	
	[self.dataSource refresh];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[indexSet firstIndex]
												inSection:0];
	DebugLog(@"changed index is %i", [indexSet firstIndex]);
	DebugLog(@"change type is %i", type);
	[self.theTableView beginUpdates];
	
	//remove downloader
	switch (type) {
		case GRDownloaderQueueChangeTypeInsert:
			[self.theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
									 withRowAnimation:UITableViewRowAnimationLeft];
			break;
		case GRDownloaderQueueChangeTypeRemove:
			[self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									 withRowAnimation:UITableViewRowAnimationLeft];
			break;
		case GRDownloaderQueueChangeTypeMove:
			break;
		default:
			break;
	}
	//add downloader
	
	[self.theTableView endUpdates];
	
}

@end

