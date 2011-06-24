//
//  HomeDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRDataManager.h"
#import "BaseReaderDataSouce.h"
#import "TagSubTableViewCell.h"

#define FAVORITELISTSECTIONNAME @"1FAVORITELISTSECTIONNAME"
#define DISCOVERSECTION		@"5DISCOVERSECTION"
#define STATESLISTSECTIONNAME	 @"2STATESLISTSECTIONNAME"
#define TAGLISTSECTIONNAME     @"3TAGLISTSECTIONNAME"
#define SUBLISTSECTIONNAME     @"4FEEDLISTSECTIONNAME"

@interface HomeDataSource : BaseReaderDataSouce{
	NSArray* _tagList;
	NSArray* _subList;
	NSDictionary* _unreadCount;
	NSArray* _statesList;
	NSArray* _favoriteList;
	NSArray* _discoverList;
	
	NSSortDescriptor* _sortDescriptor;
	
	UITableViewCellEditingStyle _editingStyle;
	
}

@property (nonatomic, retain) NSArray* tagList;
@property (nonatomic, retain) NSArray* subList;
@property (nonatomic, retain) NSArray* discoverList;
@property (nonatomic, retain) NSDictionary* unreadCount;
@property (nonatomic, retain) NSArray* statesList;
@property (nonatomic, retain) NSArray* favoriteList;
@property (nonatomic, retain) NSSortDescriptor* sortDescriptor;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;

-(void)emptyData;
-(void)addTagToShowAllItems;
-(NSArray*)createDiscoverList;
-(UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

