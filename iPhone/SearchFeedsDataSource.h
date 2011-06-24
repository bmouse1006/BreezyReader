//
//  SearchFeedsDataSource.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-18.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseReaderDataSouce.h"

@interface SearchFeedsDataSource : BaseReaderDataSouce {
	NSString* _searchString;
	NSArray* _fetchedIDs;
	NSMutableArray* _fetchedItems;
	//default list
}

@property (nonatomic, retain) NSString* searchString;
@property (nonatomic, retain) NSArray* fetchedIDs;
@property (nonatomic, retain) NSMutableArray* fetchedItems;

-(void)searchFeedsForString:(NSString*)searchString;

@end
