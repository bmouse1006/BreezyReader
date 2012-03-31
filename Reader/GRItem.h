//
//  Entry.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  retainright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"
#import "GoogleAppConstants.h"

@interface GRItem : NSObject<GRBaseProtocol> {
	NSString*	_ID;
	NSString*	_title;
	NSDate*		_published;
	NSDate*		_updated;
	NSString*	_selfLink;
	NSString*	_alternateLink;
	NSString*	_summary;
	NSString*	_content;
	NSString*   _plainSummary;
	NSString*   _plainContent;
	NSString*	_author;//it will be nil if it's unknown
	
	NSMutableSet* _gr_linkingUsers;
	NSMutableDictionary* _categories;
	
	NSString*	_source;
	NSString*	_source_ID;
	NSString*	_source_alternateLink;
	NSString*	_source_selfLink;
	NSString*	_source_title;
	
	NSString*   _shortPresentDateTime;
	
	NSArray* _contentImageURLs;
	NSArray* _summaryImageURLs;
	NSDictionary* _imageURLFileMap;
	
	BOOL readed;
	BOOL starred;
	BOOL keptUnread;

}

@property (nonatomic, retain) NSString*	ID;
@property (nonatomic, retain) NSString*	title;
@property (nonatomic, retain) NSDate*	published;
@property (nonatomic, retain) NSDate*	updated;
@property (nonatomic, retain) NSString*	selfLink;
@property (nonatomic, retain) NSString*	alternateLink;
@property (nonatomic, retain) NSString*	summary;
@property (nonatomic, retain) NSString*	content;
@property (nonatomic, retain) NSString*	author;

@property (nonatomic, retain) NSMutableSet* gr_linkingUsers;
@property (nonatomic, retain) NSMutableDictionary* categories;

@property (nonatomic, retain) NSString*	source;
@property (nonatomic, retain) NSString*	source_ID;
@property (nonatomic, retain) NSString*	source_selfLink;
@property (nonatomic, retain) NSString*	source_alternateLink;
@property (nonatomic, retain) NSString*	source_title;

@property (nonatomic, retain) NSString* shortPresentDateTime;

@property (nonatomic, retain) NSArray* contentImageURLs;
@property (nonatomic, retain) NSArray* summaryImageURLs;
@property (nonatomic, retain) NSDictionary* imageURLFileMap;
@property (nonatomic, readonly, getter=returnPreviewImage) UIImage* previewImage;

@property (nonatomic, readonly, assign) BOOL readed;
@property (nonatomic, readonly, assign) BOOL starred;
@property (nonatomic, readonly, assign) BOOL keptUnread;

@property (nonatomic, readonly, getter=getPlainSummary) NSString* plainSummary;
@property (nonatomic, readonly, getter=getPlainContent) NSString* plainContent;

-(NSString*)presentationString;
-(NSString*)getShortUpdatedDateTime;

-(GRItem*)mergeWithItem:(GRItem*)item;

-(UIImage*)icon;

-(BOOL)isReaded;
-(BOOL)isStarred;

-(void)addCategoryWithLabel:(NSString*)label andTerm:(NSString*)term;
-(void)removeCategoryWithLabel:(NSString*)label;
-(void)removeCategoryWithState:(NSString*)state;

-(void)markAsRead;

+(GRItem*)mergeItemToPool:(GRItem*)item;
+(void)didReceiveMemoryWarning;

-(BOOL)containsState:(NSString*)state;

//get a list of image URL
-(NSArray*)imageURLList;

-(void)downloadedImageFilePath:(NSDictionary*)URLFilePathMap;

-(void)parseImagesFromSummaryAndContent;

-(NSString*)filePathForImageURLString:(NSString*)urlString;
-(NSString*)encryptedImageFileName:(NSString*)imageURL;

@end

@interface GRItem (private)

-(NSArray*)getAllImageURL:(NSString*)article;

@end 
