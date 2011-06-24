//
//  SearchFeedsDataSource.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-18.
//  Copyright 2010 Jin Jin. All rights reserved.
//

//获得Search结果
//Step 1:
//获得所有ID并保存:
//获得ID
//get方法
//http://www.google.com/reader/api/0/search/items/ids?q=apple&num=1000&output=json&ck=1290088578898&client=scroll

//Step 2:
//获得ID对应items，每次个数和订阅的Feed的缺省item获取一致
//post方法
//http://www.google.com/reader/api/0/stream/items/contents?ck=1290088580313&client=scroll
//表单数据
//i=[ID](可重复)
//T=[Token]


#import "SearchFeedsDataSource.h"


@implementation SearchFeedsDataSource

@synthesize searchString = _searchString;
@synthesize fetchedIDs = _fetchedIDs;
@synthesize fetchedItems = _fetchedItems;

-(void)startSearchingFeedsForString:(NSString*)searchString{
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.fetchedItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
	cell.textLabel.text = @"aa";
	
    return cell;
}

-(void)dealloc{
	self.searchString = nil;
	self.fetchedIDs = nil;
	self.fetchedItems = nil;
	[super dealloc];
}

@end
