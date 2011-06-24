//
//  BaseReaderDataSouce.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRDataManager.h"

@interface BaseReaderDataSouce: NSObject <UITableViewDataSource> {
	
	NSArray* _defaultList;
	GRDataManager* _readerDM;
	
	NSArray* _sortDescriptors;
	
	NSMutableArray* _sectionKeys;
	NSMutableDictionary* _rowsForSectionKey;

	NSArray* _insertIndexs;
	NSArray* _removeIndexs;
	NSArray* _updateIndexs;
	NSIndexSet* _insertSections;
	NSIndexSet* _removeSections;
}

@property (nonatomic, retain) NSArray* defaultList;
@property (nonatomic, retain) GRDataManager* readerDM;
@property (nonatomic, retain) NSArray* sortDescriptors;
@property (retain) NSMutableArray* sectionKeys;
@property (retain) NSMutableDictionary* rowsForSectionKey;
@property (nonatomic, retain) NSArray* insertIndexs;
@property (nonatomic, retain) NSArray* removeIndexs;
@property (nonatomic, retain) NSArray* updateIndexs;
@property (nonatomic, retain) NSIndexSet* insertSections;
@property (nonatomic, retain) NSIndexSet* removeSections;

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString* name;
@property (readonly) NSString* navigationBarName;
//@property (readonly) UIImage* tabBarImage;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;

-(void)refresh;
-(void)emptyData;
-(void)eraseChangeDataForRowAndSections;
-(id)objectForIndexPath:(NSIndexPath*)indexPath;
-(NSIndexSet*)indexSetForAllSections;
-(void)removeObjectAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface BaseReaderDataSouce (private)

-(void)getChangesForSectionsAndRows:(NSArray*)preSectionKeys rowsForSectionKey:(NSDictionary*)preRowsForSecKey;

@end
