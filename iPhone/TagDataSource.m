//
//  HomeDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TagDataSource.h"
#import "GRDownloadManager.h"

@implementation TagDataSource

@synthesize subList = _subList;
@synthesize grTag = _grTag;
@synthesize sortDescriptor = _sortDescriptor;
@synthesize editingStyle = _editingStyle;

#pragma mark -
#pragma mark Table view data source

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

-(void)refresh{
	
	@synchronized(_rowsForSectionKey){
		NSArray* preSectionKeys = [[NSArray alloc] initWithArray:_sectionKeys];
		NSDictionary* preRowForSectionKey = [[NSDictionary alloc] initWithDictionary:_rowsForSectionKey];
		
		[_rowsForSectionKey removeAllObjects];
		[_sectionKeys removeAllObjects];
		
		self.grTag = [self.readerDM getUpdatedGRTag:self.grTag.ID];
		[self addTagToShowAllItems];
		
		self.subList = [[self autoHideProcess:[self.readerDM getSubscriptionListWithTag:self.grTag.ID]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
		
		[_sectionKeys addObject:SUBLIST];
		[_rowsForSectionKey setObject:self.subList forKey:SUBLIST];
		
		[self getChangesForSectionsAndRows:preSectionKeys rowsForSectionKey:preRowForSectionKey];
		
		[preSectionKeys release];
		[preRowForSectionKey release];
		
		DebugLog(@"-----refresh: row number is %d", [_sectionKeys count]);
	}
	
}


-(UITableViewStyle)tableViewStyle{
	return UITableViewStyleGrouped;
}

-(UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath{
	
	UITableViewCellEditingStyle style;
	if ([indexPath section] == 0){
		style = UITableViewCellEditingStyleNone;
	}else {
		style = self.editingStyle;
		if (style == UITableViewCellEditingStyleInsert){
			GRSubscription* obj = [self objectForIndexPath:indexPath];
			if (obj.unread == 0){
				style = UITableViewCellEditingStyleNone;
			}
		}
	}

	return style;
}

-(NSString*)name{
	return NSLocalizedString([self.grTag presentationString], nil);
}

-(NSString*)navigationBarName{
	return NSLocalizedString([self.grTag presentationString], nil);
}

#pragma mark -
#pragma mark delegate method
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id targetRow = [self objectForIndexPath:indexPath];
	
    static NSString *CellIdentifier = @"TagCell";
    TagSubTableViewCell* cell = (TagSubTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[TagSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.cellGRObject = targetRow;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)mEditingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	GRSubscription* object = (GRSubscription*)[self objectForIndexPath:indexPath];
	switch (mEditingStyle) {
		case UITableViewCellEditingStyleInsert:
			[[GRDownloadManager shared] addSubscriptionToDownloadQueue:object];
			UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
			[cell setEditing:NO animated:YES];
			break;
		case UITableViewCellEditingStyleDelete:
			[self removeObjectAtIndexPath:indexPath];
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationLeft];
			[tableView endUpdates];
			[[GRDataManager shared] unsubscribeFeed:object.ID];
			break;
		default:
			break;
	}


	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

	BOOL canEdit = NO;
	
	if (![[GRDownloadManager shared] containsDownloaderForSub:[self objectForIndexPath:indexPath]]){
		canEdit = YES;
	}
	
	return canEdit;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return nil;
}

-(void)addTagToShowAllItems{
	GRSubscription* subForAllItems = [self.grTag toSubscription];
	subForAllItems.title = NSLocalizedString(@"AllItems", nil);
	NSArray* array  = [NSArray arrayWithObject:subForAllItems];
	[self.sectionKeys removeObject:SHOWALL];
	[self.sectionKeys insertObject:SHOWALL atIndex:0];
	[self.rowsForSectionKey setObject:array forKey:SHOWALL];
}

-(void)unreadCountChanged:(NSNotification*)sender{
	DebugLog(@"TagDataSource: unread count changed");
	NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
	GRSubscription* object = (GRSubscription*)[self objectForIndexPath:path];
	object.unread = self.grTag.unread;
}

//get tag list and feed list from reader data manager
-(id)initWithGRTag:(GRTag*)mGRTag{
	if (self = [super init]){
		self.subList = nil;
		NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
		self.sortDescriptor = sort;
		[sort release];
		self.grTag = mGRTag;
		self.editingStyle = UITableViewCellEditingStyleDelete;
		[self refresh];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(unreadCountChanged:) 
													 name:UNREADCOUNTCHANGED 
												   object:nil];
	}
	return self;
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UNREADCOUNTCHANGED 
												  object:nil];
	[self.subList release];
	[self.sortDescriptor release];
	[super dealloc];
}

@end
