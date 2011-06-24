//
//  DownloadedItemsDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseReaderDataSouce.h"
#import "GRSubscription.h"
#import "GRObjectsManager.h"

@interface DownloadedItemsDataSource : BaseReaderDataSouce<NSFetchedResultsControllerDelegate> {
	GRSubscription* _subscription;
	NSFetchedResultsController* _fetchController;
	UITableView* _tableView;
	
	NSMutableArray* _deleteRows;
	NSMutableArray* _insertRows;
}

@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) NSFetchedResultsController* fetchController;
@property (nonatomic, retain) UITableView* tableView;

-(id)initWithSubscription:(GRSubscription*)sub;
-(void)clearAllItems;
-(NSArray*)GRItemList;
-(void)deleteSubscription:(GRSubscription*)sub;

@end
