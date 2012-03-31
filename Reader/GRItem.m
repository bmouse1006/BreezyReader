//
//  Entry.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRItem.h"
#import "RegexKitLite.h"
#import "NSString+MD5.h"

#define PATTERN @"<.*?>"

@implementation GRItem

@synthesize ID = _ID;
@synthesize	title = _title;
@synthesize	published = _published;
@synthesize	updated = _updated;
@synthesize	selfLink = _selfLink;
@synthesize	alternateLink = _alternateLink;
@synthesize	summary = _summary;
@synthesize content = _content;
@synthesize	author = _author;
@synthesize gr_linkingUsers = _gr_linkingUsers;
@synthesize categories = _categories;
@synthesize source = _source;
@synthesize source_ID = _source_ID;
@synthesize	source_selfLink = _source_selfLink;
@synthesize	source_alternateLink = _source_alternateLink;
@synthesize	source_title = _source_title;
@synthesize shortPresentDateTime = _shortPresentDateTime;

@synthesize readed, starred, keptUnread;
@synthesize contentImageURLs = _contentImageURLs;
@synthesize summaryImageURLs = _summaryImageURLs;
@synthesize imageURLFileMap = _imageURLFileMap;

@synthesize plainSummary = _plainSummary;
@synthesize plainContent = _plainContent;

-(NSString*)getPlainSummary{
	if (_plainSummary){
		return _plainSummary;
	}
	
	_plainSummary = [self.summary stringByReplacingOccurrencesOfRegex:PATTERN 
														   withString:@""];
	
	[_plainSummary retain];
	
	return _plainSummary;
}

-(NSString*)getPlainContent{
	if (_plainContent){
		return _plainContent;
	}
	_plainContent = [self.content stringByReplacingOccurrencesOfRegex:PATTERN 
														   withString:@""];
	[_plainContent retain];
	return _plainContent;
}

-(void)parseImagesFromSummaryAndContent{
	if (!self.summaryImageURLs){
		self.summaryImageURLs = [self getAllImageURL:self.summary];
	}
	
	if (!self.contentImageURLs){
		self.contentImageURLs = [self getAllImageURL:self.content];
	}
}

-(NSArray*)imageURLList{
	[self parseImagesFromSummaryAndContent];
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
	
	for (id object in self.summaryImageURLs){
	  	[array addObject:[object objectAtIndex:1]];
	}
	
	for (id object in self.contentImageURLs){
		[array addObject:[object objectAtIndex:1]];
	}
	
	return array;
}

-(void)downloadedImageFilePath:(NSDictionary*)URLFilePathMap{
	self.imageURLFileMap = URLFilePathMap;
}

-(UIImage*)returnPreviewImage{
	
	UIImage* image = nil;
//	
//	if (self.summaryImageNames == nil || [self.summaryImageNames count] < 1){
//		if (self.contentImageNames == nil || [self.contentImageNames count] < 1){
//			image = nil;
//		}else {
//			image = [UIImage imageNamed:[self fullPathForImageName:[self.contentImageNames objectAtIndex:0]]];
//		}
//
//	}else{
//		image = [UIImage imageNamed:[self fullPathForImageName:[self.summaryImageNames objectAtIndex:0]]];
//	}
//	
	return image;
}

-(void)markAsRead{
	NSString* readTag = [ATOM_PREFIXE_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
	[self addCategoryWithLabel:ATOM_STATE_READ andTerm:readTag];
}

-(BOOL)containsState:(NSString*)state{
	
	NSString* key = [ATOM_PREFIXE_STATE_GOOGLE stringByAppendingString:state];
	
	BOOL result = NO;
	if ([self.categories objectForKey:key]){
		result = YES;
	}
	return result;
}

-(void)addCategoryWithLabel:(NSString*)label andTerm:(NSString*)term{

	NSArray* token = [term componentsSeparatedByString:@"/"];
	NSMutableString* keyTerm = [NSMutableString stringWithString:term];
	
	NSString* termType = nil;
	
	if (token && [token count] >= 3){
		
		termType = [token objectAtIndex:2];
		[keyTerm replaceOccurrencesOfString:[token objectAtIndex:1] 
								 withString:@"-" 
									options:NSForcedOrderingSearch	
									  range:NSMakeRange(0, [term length])];
	}
	
	if ( [termType isEqualToString:@"state"]){//dont' deal with type of 'label'
		if ([label isEqualToString:ATOM_STATE_UNREAD]){
			keptUnread = YES;
		}else if ([label isEqualToString:ATOM_STATE_READ]) {
			readed = YES;
		}else if ([label isEqualToString:ATOM_STATE_STARRED]){
			starred = YES;
		}
		
	}
	
	[self.categories setObject:label forKey:keyTerm];
}

-(void)removeCategoryWithLabel:(NSString*)label{
	if ([label isEqualToString:ATOM_STATE_UNREAD] && [self.categories objectForKey:ATOM_STATE_READ]){
		readed = YES;
	}else if ([label isEqualToString:ATOM_STATE_READ]) {
		readed = NO;
	}else if ([label isEqualToString:ATOM_STATE_STARRED]){
		starred = NO;
	}
	[self.categories removeObjectForKey:label];
}

-(void)removeCategoryWithState:(NSString*)state{
	if ([state isEqualToString:ATOM_STATE_UNREAD]){
		keptUnread = NO;
	}else if ([state isEqualToString:ATOM_STATE_READ]) {
		readed = NO;
	}else if ([state isEqualToString:ATOM_STATE_STARRED]){
		starred = NO;
	}
	
	NSString* keyTerm = nil;
	
	NSArray* terms = [self.categories allKeys];
	for (NSString* term in terms){
		NSArray* tokens = [term componentsSeparatedByString:@"/"];
		NSString* termType = nil;
		if (tokens && [tokens count] >=3){
			termType = [tokens objectAtIndex:2];
		}
		if ([termType isEqualToString:@"state"] && [[self.categories objectForKey:term] isEqualToString:state]){
			keyTerm = term;
			break;
		}
	}
	
	[self.categories removeObjectForKey:keyTerm];
}

-(NSString*)getShortUpdatedDateTime{
	
	if (!self.shortPresentDateTime){
		NSDate* today = [NSDate date];
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		[formatter setDateFormat:@"yyyy.MM.dd"];
		
		today = [formatter dateFromString:[formatter stringFromDate:today]];
		NSDate* modifiedUpdatedDate = [formatter dateFromString:[formatter stringFromDate:self.updated]];
		
		if ([today isEqualToDate:modifiedUpdatedDate]){
			[formatter setDateFormat:@"HH:mm"];
		}else {
			[formatter setDateFormat:@"MM/dd"];
		}
		
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		self.shortPresentDateTime = [formatter stringFromDate:self.updated];
		[formatter release];
	}
	return self.shortPresentDateTime;
}

-(NSString*)presentationString{
	return self.title;
}

-(UIImage*)icon{
	UIImage* image = nil;
	if ([self isStarred]){
		image = [UIImage imageNamed:@"star.png"];
	}else {
		image = [UIImage imageNamed:@"star_empty.png"];
	}
	return image;
}

-(BOOL)isReaded{

	return (keptUnread)?NO:readed;
}

-(BOOL)isStarred{
	return starred;
}

-(GRItem*)mergeWithItem:(GRItem*)item{
	[item retain];
	if ([self.ID isEqualToString:item.ID]){
		//only below three fields will be updated
		//don't need to consider other situation
		self.updated = item.updated;				
		self.gr_linkingUsers = item.gr_linkingUsers;
		self.categories = item.categories;
	}
	[item release];
	return self;
}

-(NSString*)filePathForImageURLString:(NSString*)urlString{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return @"";
	}
	
	NSString* filename = [@"/" stringByAppendingString:[self encryptedImageFileName:urlString]];
	NSString* filePath = [documentsDirectory stringByAppendingString:filename];
	return filePath;
}

-(NSString*)encryptedImageFileName:(NSString*)imageURL{
	return [[[self.ID MD5] stringByAppendingString:[imageURL MD5]] stringByAppendingString:@".jpg"];
}

-(void)dealloc{
	
	[self.ID release];
	[self.title		release];
	[self.selfLink	release];
	[self.alternateLink release];
	[self.summary	release];
	[self.content   release];
	[self.author		release];
	[self.source		release];
	[self.source_ID	release];
	[self.source_alternateLink	release];
	[self.source_selfLink	release];
	[self.source_title release];
	
	[self.updated	release];
	[self.published  release];
	[self.gr_linkingUsers	release];
	[self.categories release];
	
	[self.contentImageURLs release];
	[self.summaryImageURLs release];
	[self.imageURLFileMap release];
	[self.shortPresentDateTime release];
	
	[_plainContent release];
	[_plainSummary release];
	
	[super dealloc];
}

-(id)init{
	if (self = [super init]){
		NSMutableSet* set = [[NSMutableSet alloc] initWithCapacity:0];
		NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
		self.gr_linkingUsers = set;
		self.categories = dictionary;
		[set release];
		[dictionary release];
		self.shortPresentDateTime = nil;
		self.contentImageURLs = nil;
		self.summaryImageURLs = nil;
		self.imageURLFileMap = nil;
		
		readed = NO;
		keptUnread = NO;
		starred = NO;
		
		_plainContent = nil;
		_plainSummary = nil;
	}
	return self;
} 

-(NSUInteger)hash{
	return [self.ID hash];
}

-(NSComparisonResult)compare:(id)object{
	return [self.updated compare:[(GRItem*)object updated]];
}

static NSMutableDictionary* itemPool = nil;

+(GRItem*)mergeItemToPool:(GRItem*)item{
	[item retain];
	if (!itemPool){
		itemPool = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	GRItem* returnItem = [itemPool objectForKey:item.ID];
	if (returnItem){
		[returnItem mergeWithItem:item];
	}else {
		[itemPool setObject:item forKey:item.ID];
		returnItem = item;
	}
	[item release];
	return returnItem;

}

+(void)didReceiveMemoryWarning{
	[itemPool removeAllObjects];
}

@end

@implementation GRItem (private)

-(NSArray*)getAllImageURL:(NSString*)article{
	//regular expression to get images
	NSString* imagePattern = @"(?i)<\\s*img\\s*.*?\\s*src\\s*=\\s*[\"']?\\s*([^\\s'\"]*)\\s*[\"']?\\s*.*?>";
	NSArray* allParsedImageURL = [article arrayOfCaptureComponentsMatchedByRegex:imagePattern];
	return [[allParsedImageURL retain] autorelease];
}

@end

