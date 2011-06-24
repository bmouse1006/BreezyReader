// 
//  GRItemModel.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRItemModel.h"


@implementation GRItemModel 

@dynamic readed;
@dynamic selfLink;
@dynamic author;
@dynamic alternateLink;
@dynamic published;
@dynamic ID;
@dynamic source_alternateLink;
@dynamic source;
@dynamic title;
@dynamic starred;
@dynamic summary;
@dynamic source_title;
@dynamic newAttribute;
@dynamic source_selfLink;
@dynamic source_ID;
@dynamic content;
@dynamic updated;
@dynamic downloadedDate;

-(void)setGRItem:(GRItem *)item{
	[item retain];
	self.readed = [NSNumber numberWithInt:item.readed];
	self.selfLink = item.selfLink;
	self.author = item.author;
	self.alternateLink = item.alternateLink;
	self.published = item.published;
	self.ID = item.ID;
	self.source_alternateLink = item.source_alternateLink;
	self.source = item.source;
	self.title = item.title;
	self.starred = [NSNumber numberWithInt:item.starred];
	self.summary = item.summary;
	self.source_title = item.source_title;
	self.source_selfLink = item.source_selfLink;
	self.source_ID = item.source_ID;
	self.content = item.content;
	self.updated = item.updated;
	[item release];
}

-(GRItem*)GRItem{
	
	GRItem* item = [[GRItem alloc] init];
	
	item.selfLink = self.selfLink;
	item.author = self.author;
	item.alternateLink = self.alternateLink;
	item.published = self.published;
	item.ID = self.ID;
	item.source_alternateLink = self.source_alternateLink;
	item.source = self.source;
	item.title = self.title;
	item.summary = self.summary;
	item.source_title = self.source_title;
	item.source_selfLink = self.source_selfLink;
	item.source_ID = self.source_ID;
	item.content = self.content;
	item.updated = self.updated;
	
	return [item autorelease];
}

-(void)removeDownloadedImages{
	GRItem* item = [self GRItem];
	[item retain];
	
	NSArray* imageURLList = [item imageURLList];
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	fileManager.delegate = nil;
	
	for (NSString* urlString in imageURLList){
		NSString* fullFilePath = [item filePathForImageURLString:urlString];
		DebugLog(@"going to remove image: %@", fullFilePath);
		if ([fileManager fileExistsAtPath:fullFilePath]){
			[fileManager removeItemAtPath:fullFilePath
									error:nil];
		}else {
			DebugLog(@"file %@ doesn't exist", fullFilePath);
		}
	}
	[fileManager release];
	
	[item release];
}

@end
