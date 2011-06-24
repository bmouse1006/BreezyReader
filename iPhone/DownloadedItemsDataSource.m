//
//  DownloadedItemsDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadedItemsDataSource.h"
#import "GRObjectsManager.h"
#import "GRItem.h"
#import "GRItemModel.h"
#import "DownloadedItemTableViewCell.h"

@implementation DownloadedItemsDataSource

@synthesize subscription = _subscription;
@synthesize fetchController = _fetchController;
@synthesize tableView = _tableView;

-(void)refresh{
	[self.rowsForSectionKey removeAllObjects];
	
	NSSortDescriptor* sort1 = [[NSSortDescriptor alloc] initWithKey:@"published" ascending:NO];
	NSArray* sortArray =  [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	NSString* key = @"source";
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, self.subscription.ID];
	
	self.fetchController = [GRObjectsManager fetchedResultsControllerFromModel:@"GRItemModel"
																	 predicate:predicate
															   sortDescriptors:sortArray];
	self.fetchController.delegate = self;
	
	[sortArray release];
	
	NSError* error = nil;
	[self.fetchController performFetch:&error];
	
	if (error){
		DebugLog(@"error happened while fetching downloaded subscriptions");
		self.fetchController = nil;
	}

}

-(NSString*)name{
	return NSLocalizedString([self.subscription presentationString], nil);
}

-(NSString*)navigationBarName{
	return NSLocalizedString([self.subscription presentationString], nil);
}

-(void)clearAllItems{
	DebugLog(@"clear all items");
	NSArray* array = [self.fetchController fetchedObjects];
	
	for (GRItemModel* obj in array){
		[obj removeDownloadedImages];
		[GRObjectsManager deleteObject:obj];
	}
	
	NSString* ID = self.subscription.ID;
	[ID retain];
	
	[GRObjectsManager commitChangeForContext:[self.fetchController managedObjectContext]];
	[self deleteSubscription:self.subscription];
	//notify that downloaded sub has been removed
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", nil];
	[ID release];
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_DELETEDOWNLOADEDSUB
																 object:nil
															   userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];

}

-(void)deleteSubscription:(GRSubscription*)sub{
	
	NSSortDescriptor* sort1 = [[NSSortDescriptor alloc] initWithKey:@"ID" ascending:NO];
	NSArray* sortArray =  [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	NSString* key = @"ID";
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, sub.ID];
	
	NSFetchedResultsController* fetchedController = [GRObjectsManager fetchedResultsControllerFromModel:@"GRSubModel"
																	 predicate:predicate
															   sortDescriptors:sortArray];
	[sortArray release];
	NSError* error = nil;
	[fetchedController performFetch:&error];
	
	if (error){
		DebugLog(@"error happened while fetching downloaded subscriptions");
		fetchedController = nil;
	}
	 
	NSArray* array = [fetchedController fetchedObjects];
	
	for (NSManagedObject* subModel in array){
		DebugLog(@"delete sub");
		[GRObjectsManager deleteObject:subModel];
		[GRObjectsManager commitChangeForContext:[subModel managedObjectContext]];
	}
}

#pragma mark -
#pragma mark Table view data source


-(UITableViewStyle)tableViewStyle{
	return UITableViewStylePlain;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[self.fetchController fetchedObjects] count];
}

-(id)objectForIndexPath:(NSIndexPath *)indexPath{
	return [self.fetchController objectAtIndexPath:indexPath];
}
	
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    DownloadedItemTableViewCell *cell = (DownloadedItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		
		if ([UserPreferenceDefine shouldShowPreviewOfArticle]){
			style = UITableViewCellStyleSubtitle;
		}
		
        cell = [[[DownloadedItemTableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
    }
    
	GRItem* item = [(GRItemModel*)[self objectForIndexPath:indexPath] GRItem];
	
	cell.cellGRObject = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		GRItemModel* obj = [self objectForIndexPath:indexPath];
		[obj removeDownloadedImages];
		[GRObjectsManager deleteObject:obj];
		[GRObjectsManager commitChangeForContext:[self.fetchController managedObjectContext]];
    }   
}

-(NSArray*)GRItemList{
	NSMutableArray* array = [NSMutableArray array];
	
	NSArray* fetchedArray = [self.fetchController fetchedObjects];
	for (GRItemModel* obj in fetchedArray){
		[array addObject:[obj GRItem]];
	}
	
	return array;
}

#pragma mark -
#pragma mark NSFetchedResultsController delegate method

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
	[_deleteRows removeAllObjects];
	[_insertRows removeAllObjects];
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
	if ([_deleteRows count]){
		[self.tableView deleteRowsAtIndexPaths:_deleteRows
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	
	if ([_insertRows count]){
		[self.tableView insertRowsAtIndexPaths:_insertRows
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
	switch (type) {
		case NSFetchedResultsChangeDelete:
			[_deleteRows addObject:indexPath];
			break;
		case NSFetchedResultsChangeInsert:
			[_insertRows addObject:indexPath];
		default:
			break;
	}
}



#pragma mark initial and dealloc

-(id)initWithSubscription:(GRSubscription*)sub{
	if (self = [super init]){
		self.subscription = sub;
		self.fetchController = nil;
		_deleteRows = [[NSMutableArray alloc] initWithCapacity:0];
		_insertRows = [[NSMutableArray alloc] initWithCapacity:0];
		[self.sectionKeys addObject:@"KEY"];
	}
	
	return self;
}

-(void)dealloc{
	[_deleteRows release];
	[_insertRows release];
	[self.subscription release];
	[self.fetchController release];
	[self.tableView release];
	[super dealloc];
}

@end
