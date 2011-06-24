//
//  HomeDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HomeDataSource.h"
#import "GRDownloadManager.h"
#import "GRSubscription.h"
#import "GRDiscover.h"

@implementation HomeDataSource

@synthesize discoverList = _discoverList;
@synthesize statesList = _statesList;
@synthesize favoriteList = _favoriteList;
@synthesize tagList = _tagList;
@synthesize subList = _subList;
@synthesize unreadCount = _unreadCount;
@synthesize sortDescriptor = _sortDescriptor;
@synthesize editingStyle = _editingStyle;

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//	return [super numberOfSectionsInTableView:tableView]+1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	NSInteger nb = 0;
//	if (section == 0){
//		nb = 1;
//	}else {
//		nb = [super tableView:tableView numberOfRowsInSection:section-1];
//	}
//	return nb;
//}

#pragma mark -
#pragma mark Table view data source

-(void)emptyData{
	[super emptyData];
	self.statesList = nil;
	self.favoriteList = nil;
	self.tagList = nil;
	self.subList = nil;
	self.unreadCount = nil;
	self.discoverList = nil;
}

-(NSArray*)autoHideProcess:(NSArray*)list{
	
	BOOL autoHide = [UserPreferenceDefine shouldAutoHideSubAndTagWithNoNewItems];
	NSArray* outputArray = nil;
	if (autoHide){
		NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:0];
		for (id item in list){
			if ([item unread] > 0){
				[tempArray addObject:item];
			}
		}
		outputArray = tempArray;
	}else {
		outputArray = list;
	}

	return outputArray;
		
}

-(NSArray*)createDiscoverList{
	NSArray* list = self.discoverList;
	if (!list){
		GRDiscover* recedFeeds = [[GRDiscover alloc] initWithGRDiscoverType:GRDiscoverTypeRecFeeds];
		GRDiscover* recedItems = [[GRDiscover alloc] initWithGRDiscoverType:GRDiscoverTypeRecItems];
		GRDiscover* searchFeeds = [[GRDiscover alloc] initWithGRDiscoverType:GRDiscoverTypeSearchFeeds];
		GRDiscover* addNewFeed = [[GRDiscover alloc] initWithGRDiscoverType:GRDiscoverTypeAddNewFeed];
//		list = [NSArray arrayWithObjects:recedFeeds, recedItems, searchFeeds, nil];
//		list = [NSArray arrayWithObjects:recedFeeds, searchFeeds, nil];
		list = [NSArray arrayWithObjects:recedFeeds, addNewFeed,nil];
		[recedFeeds release];
		[recedItems	release];
		[searchFeeds release];
		[addNewFeed release];
	}
	
	return [[list retain] autorelease];
}

-(void)refresh{
	
	NSArray* preSectionKeys = [[NSArray alloc] initWithArray:self.sectionKeys];
	NSDictionary* preRowForSectionKey = [[NSDictionary alloc] initWithDictionary:self.rowsForSectionKey];
	[self.rowsForSectionKey removeAllObjects];
	[self.sectionKeys removeAllObjects];
	
	self.discoverList = [self createDiscoverList];
	self.favoriteList = [self.readerDM getFavoriteSubList];
	self.statesList = [self.readerDM getStateList];
	self.tagList = [self autoHideProcess:[self.readerDM getLabelList]];
	self.subList = [self autoHideProcess:[self.readerDM getSubscriptionListWithTag:@""]];
	self.unreadCount = [self.readerDM getUnreadCount];
	
	[self addTagToShowAllItems];
	
	if ([self.favoriteList count] > 0){
		[self.sectionKeys addObject:FAVORITELISTSECTIONNAME];
		[self.rowsForSectionKey setValue:self.favoriteList forKey:FAVORITELISTSECTIONNAME];
	}
	
	if ([self.discoverList count] > 0){
		[self.sectionKeys addObject:DISCOVERSECTION];
		[self.rowsForSectionKey setValue:self.discoverList forKey:DISCOVERSECTION];
	}
	
	if ([self.statesList count] > 0){
		self.statesList = [self.statesList sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
		[self.sectionKeys addObject:STATESLISTSECTIONNAME];
		[self.rowsForSectionKey setValue:self.statesList forKey:STATESLISTSECTIONNAME];
	}

	if ([self.tagList count] > 0){
		self.tagList = [self.tagList sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
		[self.sectionKeys addObject:TAGLISTSECTIONNAME];
		[self.rowsForSectionKey setValue:self.tagList forKey:TAGLISTSECTIONNAME];
	}
	
	if ([self.subList count] > 0){
		self.subList = [self.subList sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
		[self.sectionKeys addObject:SUBLISTSECTIONNAME];
		[self.rowsForSectionKey setValue:self.subList forKey:SUBLISTSECTIONNAME];
	}
	
	[self getChangesForSectionsAndRows:preSectionKeys rowsForSectionKey:preRowForSectionKey];
	
	[preSectionKeys release];
	[preRowForSectionKey release];
	
}

-(void)addTagToShowAllItems{
	GRTag* allItems = [[GRTag alloc] init];
	allItems.ID = [ATOM_PREFIXE_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READING_LIST];
	allItems.sortID = @"00000000000";
	allItems.label = ATOM_STATE_READING_LIST;
	allItems.isUnreadOnly = YES;
	NSArray* array = [NSArray arrayWithObject:allItems];
	[allItems release];
	self.statesList = [array arrayByAddingObjectsFromArray:self.statesList];
}

-(UITableViewStyle)tableViewStyle{
	return UITableViewStyleGrouped;
//	return UITableViewStylePlain;
}

-(NSString*)name{
	return NSLocalizedString(@"HomeViewName", nil);
}

-(NSString*)navigationBarName{
	return NSLocalizedString(@"HomeViewNavName", nil);
}

#pragma mark Delegate method

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)mEditingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString* sectionType = [self.sectionKeys objectAtIndex:[indexPath section]];
	id targetObj = [self objectForIndexPath:indexPath];
	
	switch (mEditingStyle) {
		case UITableViewCellEditingStyleInsert:
			[[GRDownloadManager shared] addSubscriptionToDownloadQueue:targetObj];
			UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
			[cell setEditing:NO animated:YES];
			
			break;
		case UITableViewCellEditingStyleDelete:
			//modify UI first in order to avoid any confliction
			//remove object from array
			[self removeObjectAtIndexPath:indexPath];
			//remove cell from table view
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							 withRowAnimation:UITableViewRowAnimationLeft];
			[tableView endUpdates];
			if ([sectionType isEqualToString:SUBLISTSECTIONNAME]){
				//unsubscribe subscription
				[[GRDataManager shared] unsubscribeFeed:((GRSubscription*)targetObj).ID];
			}else if ([sectionType isEqualToString:TAGLISTSECTIONNAME]) {
				//remove tag
				[[GRDataManager shared] removeTag:((GRTag*)targetObj).ID];
			}
			break;
		default:
			break;
	}						
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	id targetRow = [self objectForIndexPath:indexPath];
	
    static NSString *CellIdentifier = @"HomeCell";
    TagSubTableViewCell* cell = (TagSubTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
    if (cell == nil) {
		cell = [[[TagSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.cellGRObject = targetRow;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString* sectionKey = [self.sectionKeys objectAtIndex:[indexPath section]];
	
	BOOL canEdit = NO;
	
	if ([sectionKey isEqualToString:TAGLISTSECTIONNAME] || [sectionKey isEqualToString:SUBLISTSECTIONNAME]){
		if (![[GRDownloadManager shared] containsDownloaderForSub:[self objectForIndexPath:indexPath]]){
			canEdit = YES;
		}
	}
	
	return canEdit;
	
}

-(UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath{

	UITableViewCellEditingStyle style = self.editingStyle;
	
	if (style == UITableViewCellEditingStyleInsert){
		GRSubscription* obj = [self objectForIndexPath:indexPath];
		if (obj.unread == 0){
			style = UITableViewCellEditingStyleNone;
		}
	}
	
	return style;

}

//get tag list and feed list from reader data manager
-(id)init{
	if (self = [super init]){
		NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
		self.sortDescriptor = sort;
		self.editingStyle = UITableViewCellEditingStyleDelete;
		[sort release];
		[self refresh];
	}
	return self;
}

-(void)dealloc{
	[self.tagList release];
	[self.unreadCount release];
	[self.subList release];
	[self.statesList release];
	[self.favoriteList release];
	[self.sortDescriptor release];
	self.discoverList = nil;
	[super dealloc];
}

@end

