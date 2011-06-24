//
//  TagListDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseReaderDataSouce.h"
#import "TagSubTableViewCell.h"

#define SHOWALL @"SHOWALL"
#define SUBLIST @"SUBLIST"

@interface TagDataSource : BaseReaderDataSouce{
	GRTag* _grTag;
	NSArray* _subList;
	
	NSSortDescriptor* _sortDescriptor;
	
	UITableViewCellEditingStyle _editingStyle;
}

@property (nonatomic, retain) GRTag* grTag;
@property (nonatomic, retain) NSArray* subList;
@property (nonatomic, retain) NSSortDescriptor* sortDescriptor;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;

-(id)initWithGRTag:(GRTag*)mGRTag;
-(void)addTagToShowAllItems;
-(UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
