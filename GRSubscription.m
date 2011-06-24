//
//  GRSubscription.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRSubscription.h"


@implementation GRSubscription

@synthesize ID = _ID;
@synthesize title = _title;
@synthesize sortID = _sortID;
@synthesize firstItemMSec = _firstItemMSec;
@synthesize categories = _categories;
@synthesize downloadedDate = _downloadedDate;

@synthesize unread;
@synthesize newestItemTimestampUsec;
@synthesize isUnreadOnly;

-(BOOL)isEqual:(id)object{
	BOOL equal = NO;
	
	if ([object isKindOfClass:[GRSubscription class]]){
		GRSubscription* obj = object;
		equal = [self.ID isEqualToString:obj.ID];
	}
	
	return equal;
}

-(NSString*)keyString{
	NSString* tail;
	if (isUnreadOnly){
		tail = @"_unread";
	}else {
		tail = @"_all";
	}

	return [self.ID stringByAppendingString:tail];
}

-(NSString*)presentationString{
	return self.title;
}

-(NSInteger)unreadCount{
	return self.unread;
}

-(UIImage*)icon{
	static NSString* DefaultIconName = @"text.png";
	
	UIImage* image = nil;
	NSString* imageName = [self.title stringByAppendingString:@".png"];
	image = [UIImage imageNamed:imageName];
	
	if (!image){
		image = [UIImage imageNamed:DefaultIconName];
	}
	
	return image;
}

-(GRRecFeed*)recFeedFromSubscription{
	GRRecFeed* feed = [[[GRRecFeed alloc] init] autorelease];
	feed.streamID = self.ID;
	feed.title = self.title;
	
	return feed;
}

+(GRSubscription*)subscriptionWithJSONObject:(NSDictionary*)JSONSub{

	if (![JSONSub isKindOfClass:[NSDictionary class]]){
		return nil;
	}
	
	GRSubscription* newSub = [[[GRSubscription alloc] init] autorelease];
	
	newSub.ID = [JSONSub objectForKey:@"id"];
	newSub.title = [JSONSub objectForKey:@"title"];
	newSub.sortID = [JSONSub objectForKey:@"sortid"];
	newSub.firstItemMSec = [[JSONSub objectForKey:@"firstitemmsec"] doubleValue];
	
	return newSub;

}

+(GRSubscription*)subscriptionForAllItems{
	GRSubscription* allItems = [[GRSubscription alloc] init];
	allItems.ID = @"usr/-/state/com.google/reading-list";
	allItems.title = @"reading-list";
	allItems.sortID = @"000000";
	return [allItems autorelease];
}

+(GRSubscription*)subscriptionForGRRecFeed:(GRRecFeed*)recFeed{
	GRSubscription* recSub = [[GRSubscription alloc] init];
	recSub.ID = recFeed.streamID;
	recSub.title = recFeed.title;
	recSub.sortID = @"000000";
	return [recSub autorelease];
}

-(id)init{
	if (self = [super init]){
		self.categories = [NSMutableSet setWithCapacity:0];
		self.ID = nil;
		self.sortID = nil;
		self.title = nil;
		newestItemTimestampUsec = 0;
		unread = 0;
		isUnreadOnly = YES;
	}
	return self;
}

-(void)dealloc{

	[self.ID release];
	[self.title release];
	[self.sortID release];
	[self.categories release];
	[self.downloadedDate release];
	[super dealloc];
}

@end
