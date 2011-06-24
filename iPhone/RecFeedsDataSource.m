//
//  RecFeedsDataSource.m
//  SmallReader
//
//  Created by Jin Jin on 10-10-31.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "RecFeedsDataSource.h"
#import "RecFeedsCell.h"

@implementation RecFeedsDataSource

@synthesize tempCell = _tempCell;

-(NSString*)name{
	return NSLocalizedString(@"recommendedFeeds", nil);
};

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    RecFeedsCell* cell = (RecFeedsCell*)[tableView dequeueReusableCellWithIdentifier:@"RecFeedsCell"];
	
	if (!cell){
		[[NSBundle mainBundle] loadNibNamed:@"RecFeedsCell" owner:self options:nil];
		cell = self.tempCell;
		self.tempCell = nil;
	}
	
	id obj = [self objectForIndexPath:indexPath];
	
	BOOL useDarkBG = (indexPath.row % 2);
	cell.useDarkBackground = useDarkBG;
	
	[cell setRecFeedObj:obj];
	
    return [[cell retain] autorelease];
}

-(void)refresh{
	//get recommended feeds list
	NSArray* preSectionKeys = [[NSArray alloc] initWithArray:self.sectionKeys];
	NSDictionary* preRowForSectionKey = [[NSDictionary alloc] initWithDictionary:self.rowsForSectionKey];
	[self.rowsForSectionKey removeAllObjects];
	[self.sectionKeys removeAllObjects];
	
	NSArray* feedList = [self.readerDM getRecFeedList];
	
	[self.sectionKeys addObject:@"recFeedsList"];
	[self.rowsForSectionKey setObject:feedList forKey:@"recFeedsList"];

	[self getChangesForSectionsAndRows:preSectionKeys rowsForSectionKey:preRowForSectionKey];
	
	[preSectionKeys release];
	[preRowForSectionKey release];
	
}

-(void)dealloc{
	[self.tempCell release];
	[super dealloc];
}

@end
