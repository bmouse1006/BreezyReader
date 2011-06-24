//
//  BaseReaderDataSouce.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseReaderDataSouce.h"

@implementation BaseReaderDataSouce

@synthesize readerDM = _readerDM;
@synthesize defaultList = _defaultList;
@synthesize sortDescriptors = _sortDescriptors;
@synthesize sectionKeys = _sectionKeys;
@synthesize rowsForSectionKey = _rowsForSectionKey;

@synthesize removeSections = _removeSections;
@synthesize insertSections = _insertSections;
@synthesize removeIndexs = _removeIndexs;
@synthesize insertIndexs = _insertIndexs;
@synthesize updateIndexs = _updateIndexs;

#pragma mark -
#pragma mark delegate method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return [self.sectionKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString* key = [self.sectionKeys objectAtIndex:section];
	NSArray* array = [self.rowsForSectionKey objectForKey:key];
	return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"BaseCell";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    return cell;
}

-(void)removeObjectAtIndexPath:(NSIndexPath*)indexPath{
	NSString* key = [self.sectionKeys objectAtIndex:[indexPath section]];
	NSMutableArray* section = [NSMutableArray arrayWithArray:[self.rowsForSectionKey objectForKey:key]];
	[section removeObjectAtIndex:indexPath.row];
	[self.rowsForSectionKey setObject:section 
							   forKey:key];
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString* titleString = nil;
	
	if (section < [self.sectionKeys count]){
		titleString = [self.sectionKeys objectAtIndex:section];
	}
	return NSLocalizedString(titleString, nil);
}

-(NSString*)name{
	return @"Base name";
};

-(NSString*)navigationBarName{
	return @"Base navigation bar name";
}
//@property (readonly) UIImage* tabBarImage;

// this property determines the style of table view displayed
-(UITableViewStyle)tableViewStyle{
	return UITableViewStylePlain;
}

-(id)init{
	if (self = [super init]){
		self.readerDM = [GRDataManager shared];
		self.sortDescriptors = nil;
		self.sectionKeys = [NSMutableArray arrayWithCapacity:0];
		self.rowsForSectionKey = [NSMutableDictionary dictionaryWithCapacity:0];
	}
	return self;
}

-(void)dealloc{
	[self.defaultList release];
	[self.readerDM release];
	[self.sortDescriptors release];
	[self.rowsForSectionKey release];
	[self.sectionKeys release];
	[self.removeSections release];
	[self.removeIndexs release];
	[self.insertIndexs release];
	[self.updateIndexs release];
	[self.insertSections release];
	[super dealloc];
}

-(void)refresh{
};

-(void)emptyData{
	self.defaultList = nil;
	
	NSArray* preSectionKeys = [[NSArray alloc] initWithArray:self.sectionKeys];
	NSDictionary* preRowsForKey = [[NSDictionary alloc] initWithDictionary:self.rowsForSectionKey];
	
	[self.rowsForSectionKey removeAllObjects];
	[self.sectionKeys removeAllObjects];
	
	[self getChangesForSectionsAndRows:preSectionKeys rowsForSectionKey:preRowsForKey];
	
	[preRowsForKey release];
	[preSectionKeys release];
}

-(id)objectForIndexPath:(NSIndexPath*)indexPath{
	
	id obj = nil;
	
	if ([indexPath section] < [self.sectionKeys count]){
		NSString* key = [self.sectionKeys objectAtIndex:[indexPath section]];
		if (indexPath.row < [[self.rowsForSectionKey objectForKey:key] count]){
			obj = [[self.rowsForSectionKey objectForKey:key] objectAtIndex:indexPath.row];
		}
	}
	
	return obj;
}

-(void)eraseChangeDataForRowAndSections{
	self.removeSections = nil;
	self.insertSections = nil;
	self.removeIndexs = nil;
	self.insertIndexs = nil;
}

-(NSIndexSet*)indexSetForAllSections{
	NSUInteger sectionCount = [self.sectionKeys count];
	if (!sectionCount)
		return nil;
	NSRange range = {0, sectionCount};
	NSIndexSet* indexSet = [[[NSIndexSet alloc] initWithIndexesInRange:range] autorelease];
	return indexSet;
}

@end

@implementation BaseReaderDataSouce (private)


-(void)getChangesForSectionsAndRows:(NSArray*)preSectionKeys rowsForSectionKey:(NSDictionary*)preRowsForSecKey{
	DebugLog(@"in get changes");
	DebugLog(@"count of pre section is %i", [preSectionKeys count]);
	[preSectionKeys retain];
	[preRowsForSecKey retain];
	
	NSMutableArray* mInsertIndexs = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray* mRemoveIndexs = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableIndexSet* mInsertSections = [[NSMutableIndexSet alloc] init];
	NSMutableIndexSet* mRemoveSections = [[NSMutableIndexSet alloc] init];
	
	
	for (NSString* preKey in preSectionKeys) {
		if (![self.sectionKeys containsObject:preKey]){//if previous section key not included in current section key, remove
			[mRemoveSections addIndex:[preSectionKeys indexOfObject:preKey]];
			DebugLog(@"add an index %i to be removed", [preSectionKeys indexOfObject:preKey]);
			DebugLog(@"key is %@", preKey);
		}
	}
	
	for (NSString* newKey in self.sectionKeys){
		if (![preSectionKeys containsObject:newKey]){//if current key is a new key, insert
			[mInsertSections addIndex:[self.sectionKeys indexOfObject:newKey]];
			DebugLog(@"add an index %i to be inserted", [self.sectionKeys indexOfObject:newKey]);
			DebugLog(@"key is %@", newKey);
		}
	}
	
	for (NSString* remainingKey in preSectionKeys) {
		if (![mRemoveSections containsIndex:[preSectionKeys indexOfObject:remainingKey]]){
			NSArray* preRowsForKey = [preRowsForSecKey objectForKey:remainingKey];
			NSArray* currRowsForKey = [self.rowsForSectionKey objectForKey:remainingKey];
			
			for (id obj1 in preRowsForKey){
				if (![currRowsForKey containsObject:obj1]){
					//index path to remove
					[mRemoveIndexs addObject:[NSIndexPath indexPathForRow:[preRowsForKey indexOfObject:obj1]
																inSection:[preSectionKeys indexOfObject:remainingKey]]];
				}
			}
			
			for (id obj2 in currRowsForKey){
				if (![preRowsForKey containsObject:obj2]){
					//index path to insert
					[mInsertIndexs addObject:[NSIndexPath indexPathForRow:[currRowsForKey indexOfObject:obj2]
																inSection:[self.sectionKeys indexOfObject:remainingKey]]];
				}
			}
		}
	}
	
	self.insertIndexs = mInsertIndexs;
	self.removeIndexs = mRemoveIndexs;
	self.insertSections = mInsertSections;
	self.removeSections = mRemoveSections;
	
	[mInsertIndexs release];
	[mRemoveIndexs release];
	[mInsertSections release];
	[mRemoveSections release];
	
	[preSectionKeys release];
	[preRowsForSecKey release];
}


@end

