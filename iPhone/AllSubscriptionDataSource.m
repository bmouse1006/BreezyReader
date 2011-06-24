//
//  AllSubscriptionDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AllSubscriptionDataSource.h"
#import "GRSubscription.h"
#import "GRTag.h"
#import "GRObjectsManager.h"
#import "GRSubModel.h"
#import "GRItemModel.h"
#import "GRObjectsManager.h"
#import "AllSubscriptionViewCell.h"
#import "TagSubTableViewCell.h"

@implementation AllSubscriptionDataSource

@synthesize fetchController = _fetchController;

-(void)refresh{
	[self.sectionKeys removeAllObjects];
	[self.rowsForSectionKey removeAllObjects];
	
	[self setupResultControllers];
	
	[self splitUpFetchedResult];

}

#pragma mark Table View style
-(UITableViewStyle)tableViewStyle{
//	UITableViewStyle style = UITableViewStylePlain;
	UITableViewStyle style = UITableViewStyleGrouped;
	if ([UserPreferenceDefine iPadMode]){
		style = UITableViewStyleGrouped;
	}
	return style;
}

#pragma mark -
#pragma mark Table view data source


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
	AllSubscriptionViewCell *cell = (AllSubscriptionViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[AllSubscriptionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	cell.cellGRObject = [(GRSubModel*)[self objectForIndexPath:indexPath] GRSub];
	
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
	 if (editingStyle == UITableViewCellEditingStyleDelete) {
	 // Delete the row from the data sourc
		GRSubModel* obj = [self objectForIndexPath:indexPath];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"source", obj.ID];
		 
		NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"ID" ascending:YES];
		 
		NSFetchedResultsController* controller = [GRObjectsManager fetchedResultsControllerFromModel:ITEMMODELNAME
																						   predicate:predicate
																					 sortDescriptors:[NSArray arrayWithObject:sort]];
		 [sort release];
		 
		 NSError* error = nil;
		 
		 [controller performFetch:&error];
		 
		 NSArray* items = [controller fetchedObjects];
		 
		 for (GRItemModel* item in items){
			 [item removeDownloadedImages];
			 [GRObjectsManager deleteObject:item];
		 }
		 [GRObjectsManager commitChangeForContext:[controller managedObjectContext]];
		 [GRObjectsManager deleteObject:obj];
		 [GRObjectsManager commitChangeForContext:[self.fetchController managedObjectContext]];	   
		 [self removeObjectAtIndexPath:indexPath];
		 [tableView beginUpdates];
		 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						  withRowAnimation:UITableViewRowAnimationLeft];
		 [tableView endUpdates];
	 }   
 
 }
 

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

-(void)setupResultControllers{
	NSSortDescriptor* sort1 = [[NSSortDescriptor alloc] initWithKey:@"downloadedDate" ascending:NO];
	NSArray* sortArray =  [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	self.fetchController = [GRObjectsManager fetchedResultsControllerFromModel:@"GRSubModel"
																	 predicate:nil
															   sortDescriptors:sortArray];
	NSError* error = nil;
	[self.fetchController performFetch:&error];
	
	if (error){
		DebugLog(@"error happened while fetching downloaded subscriptions");
		self.fetchController = nil;
	}
	
	[sortArray release];
}

-(void)splitUpFetchedResult{
	NSArray* tempFetchedResult = [self.fetchController fetchedObjects];
	
	NSMutableArray* oneday = [NSMutableArray array];
	NSMutableArray* twodays = [NSMutableArray array];
	NSMutableArray* oneWeek = [NSMutableArray array];
	NSMutableArray* oneMonth = [NSMutableArray array];
	NSMutableArray* oneMonthBefore = [NSMutableArray array];
	
	NSTimeInterval oneDayInterval = 24*60*60;
	
	NSDate* now = [NSDate date];
	
	NSMutableArray* compareDates = [NSMutableArray array];
	
	[compareDates addObject:[now dateByAddingTimeInterval:oneDayInterval*(-1)]];
	[compareDates addObject:[now dateByAddingTimeInterval:oneDayInterval*(-2)]];
	[compareDates addObject:[now dateByAddingTimeInterval:oneDayInterval*(-7)]];
	[compareDates addObject:[now dateByAddingTimeInterval:oneDayInterval*(-30)]];
	[compareDates addObject:[NSDate distantPast]];
	
	int compareIndex = 0;
	
	for (GRSubModel* obj in tempFetchedResult){
		NSComparisonResult result = [obj.downloadedDate compare:[compareDates objectAtIndex:compareIndex]];
		
		while(!(result == NSOrderedDescending || result == NSOrderedSame)){
			compareIndex++;
			result = [obj.downloadedDate compare:[compareDates objectAtIndex:compareIndex]];
		};
		
		switch (compareIndex) {
			case 0:
				[oneday addObject:obj];
				break;
			case 1:
				[twodays addObject:obj];
				break;
			case 2:
				[oneWeek addObject:obj];
				break;
			case 3:
				[oneMonth addObject:obj];
				break;
			case 4:
				[oneMonthBefore addObject:obj];
			default:
				break;
		}
		
	}
	
	if ([oneday count]){
		[self.sectionKeys addObject:ONEDAY];
		[self.rowsForSectionKey setObject:oneday forKey:ONEDAY];
	}
	
	if ([twodays count]){
		[self.sectionKeys addObject:TWODAYS];
		[self.rowsForSectionKey setObject:twodays forKey:TWODAYS];
	}
	
	if ([oneWeek count]){
		[self.sectionKeys addObject:ONEWEEK];
		[self.rowsForSectionKey setObject:oneWeek forKey:ONEWEEK];
	}
	
	if ([oneMonth count]){
		[self.sectionKeys addObject:ONEMONTH];
		[self.rowsForSectionKey setObject:oneMonth forKey:ONEMONTH];
	}
	
	if ([oneMonthBefore count]){
		[self.sectionKeys addObject:ONEMONTHBEFORE];
		[self.rowsForSectionKey setObject:oneMonthBefore forKey:ONEMONTHBEFORE];
	}
}

-(void)dealloc{
	[self.fetchController release];
	[super dealloc];
}

@end
