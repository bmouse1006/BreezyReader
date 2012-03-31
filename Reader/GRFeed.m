//
//  GRFeed.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRFeed.h"


@implementation GRFeed

@synthesize	generator = _generator;
@synthesize	generator_URI =_generator_URI;
@synthesize	ID =_ID;
@synthesize	selfLink =_selfLink;
@synthesize	alternateLink =_alternateLink;
@synthesize	title = _title;
@synthesize	subTitle = _subTitle;
@synthesize	gr_continuation = _gr_continuation;
@synthesize	author = _author;
@synthesize	updated = _updated;
@synthesize	published = _published;
@synthesize refreshed = _refreshed;
@synthesize items = _items;
@synthesize	sourceXML = _sourceXML;
@synthesize itemIDs = _itemIDs;
@synthesize sortArray = _sortArray;
@synthesize subscriptionID = _subscriptionID;

@synthesize isUnreadOnly;

-(NSString*)keyString{
	NSString* tail;
	if (isUnreadOnly){
		tail = @"_unread";
	}else {
		tail = @"_all";
	}
	
	return [self.subscriptionID stringByAppendingString:tail];
}

-(void)sortItems{
	[self.items sortUsingDescriptors:self.sortArray];
}

-(NSString*)presentationString{
	return self.title;
}

-(GRFeed*)mergeWithFeed:(GRFeed*)feed continued:(BOOL)continued{ 
	[feed retain];
	if (feed){
		@synchronized(_items){
			self.generator = feed.generator;
			self.generator_URI = feed.generator_URI;
//			self.ID = feed.ID;
			self.selfLink = feed.selfLink;
			self.alternateLink = feed.alternateLink;
			self.title = feed.title;
			self.subTitle = feed.subTitle;
			self.author = feed.author;
//			self.updated = feed.updated;
			self.published = feed.published;
			self.refreshed = [NSDate date];
			self.sourceXML = feed.sourceXML;
			self.gr_continuation = feed.gr_continuation;
			if (continued){
				[self.items addObjectsFromArray:feed.items];
			}else {
				NSArray* tempItems = [NSArray arrayWithArray:feed.items];
				for (int i = [tempItems count] - 1	; i >= 0; i--){
					GRItem* item = [tempItems objectAtIndex:i];
					if ([self.itemIDs containsObject:item.ID]){
						[feed.items removeObjectAtIndex:i];
					}
				}
				[feed.items addObjectsFromArray:self.items];
				self.items = feed.items;
			}
			[self.itemIDs unionSet:feed.itemIDs];
		}
	}
	[feed release];
	return self;
}

-(NSInteger)itemCount{
	return [self.items count];
}

-(GRItem*)getItemAtIndex:(NSIndexPath*)indexPath{
	return [self.items objectAtIndex:indexPath.row];
}

-(void)dealloc{

	[self.generator release];
	[self.generator_URI release];
	[self.ID	release];
	[self.selfLink	release];
	[self.alternateLink	release];
	[self.title	release];
	[self.subTitle release];
	[self.gr_continuation release];
	[self.author	release];
	
	[self.updated	release];
	[self.published release];
	[self.refreshed release];
	[self.sourceXML release];
	
	[self.items release];
	[self.itemIDs release];
	
	[self.sortArray release];
	[self.subscriptionID release];
	[super dealloc];
	
}

-(id)init{
	if (self = [super init]){
		NSSortDescriptor* tempSort1 = [[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO];
		self.sortArray = [NSArray arrayWithObjects:tempSort1, nil];
		self.items = [NSMutableArray arrayWithObjects:0];
		self.itemIDs = [NSMutableSet setWithCapacity:0];
		[tempSort1 release];
		self.refreshed = [NSDate date];
		
		isUnreadOnly = YES;
	}
	
	return self;
}

-(void)addItem:(GRItem*)item{
	//if ID of item is not in the set of item ID, than add this item to item Array
	if (![self.itemIDs containsObject:item.ID]){
		[self.itemIDs addObject:item.ID];
		[self.items addObject:item];
	}
}

-(UIImage*)icon{
	return nil;
}

@end
