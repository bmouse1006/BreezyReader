//
//  GRDataManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAppLib.h"
#import "GRTag.h"
#import "GRItem.h"
#import "GRFeed.h"
#import "GRSubscription.h"

#define CONTINUEDFEEDKEY		@"continuedFeed"

#define TAGLISTFILE				@"/ReaderDataManagerTagList.plist"
#define	SUBSCRIPTIONLISTFILE	@"/ReaderDataManagerSubScriptionList.plist"
#define UNREADCOUNTFILE			@"/ReaderDataManagerUnreadCount.plist"
#define CACHEFILE				@"/ReaderDataManagerCache.plist"
#define FAVORITELISTFILE		@"/ReaderDataManagerFavorite.plist"

#define DEFAULTITEMCOUNT		10

@interface GRDataManager : NSObject<GoogleReaderControllerDelegate> {
	
	NSDictionary* _tagDict;			//original dictionary for tag list from JSON
	NSDictionary* _subDict;//original dictionary for subscription list from JSON
	NSDictionary* _unreadCount;		//original dictionary for unread count list from JSON
	
	NSMutableDictionary* _processedTagDict;			//processed tag dictionary
	NSMutableDictionary* _processedSubDict;//processed sub dictionary
	
	NSMutableDictionary* _favoriteSubDict; //value: visit count,  key: id for subscription, 
	
	NSMutableDictionary* _cache;//cache for get Feed/Sub/Tag
	
	NSMutableDictionary* _feedPool;
	NSMutableDictionary* _itemPool;
	
	GoogleReaderController* _grController;//Google reader controller
	
	NSOperationQueue* _feedOperationQueue;//queues for operations 
	NSOperationQueue* _editOperationQueue;
	
	NSMutableSet* _runningOperationKeys;//the key set that present the current running tasks
	
	NSError* _grError; //stores that error info if there is any
	
	BOOL errorHappened; // does the error happened
	
	NSArray* _recFeedList;
	
	NSString* _lastSubscribedStreamID;
	
}

@property (retain) NSDictionary* tagDict;
@property (retain) NSDictionary* subDict;
@property (retain) NSDictionary* unreadCount;
@property (retain) NSMutableDictionary* processedTagDict;
@property (retain) NSMutableDictionary* processedSubDict;
@property (retain) NSMutableDictionary* favoriteSubDict;

@property (retain) NSMutableDictionary* cache;
@property (retain) NSMutableDictionary* feedPool;
@property (retain) NSMutableDictionary* itemPool;
@property (retain) GoogleReaderController* grController;
@property (retain) NSOperationQueue* feedOperationQueue;
@property (retain) NSOperationQueue* editOperationQueue;
@property (retain) NSArray* recFeedList;

@property (retain) NSMutableSet* runningOperationKeys;

@property (retain) NSError* grError;
@property (assign) BOOL errorHappened;

@property (nonatomic, retain) NSString* lastSubscribedStreamID;

+ (GRDataManager*)shared;
+(void)didReceiveMemoryWarning;

-(GRTag*)getUpdatedGRTag:(NSString*)tagID;
-(GRSubscription*)getUpdatedGRSub:(NSString*)subID;

-(NSArray*)getSubscriptionListWithTag:(NSString*)tagID;//get subscription list for a tag
-(NSArray*)getAllSubscriptions;
-(NSArray*)getTagListContainsText:(NSString*)str;//get a tag list that contains specific text (for label and state)
-(NSArray*)getLabelList;
-(NSArray*)getStateList;
-(NSArray*)getFavoriteSubList;//get my favorite subscription list (currently returns nil)
-(NSArray*)getRecFeedList;//get recommended feed list
-(NSDictionary*)getUnreadCount;//get return count for all sub and tag
-(void)syncUnreadCount;

-(GRFeed*)feedWithSubID:(NSString*)subID;//get a Feed for specific subscription ID
-(GRItem*)itemWithID:(NSString*)itemID;//get a Item for specific item ID
-(BOOL)refreshFeedWithSub:(GRSubscription*)sub manually:(BOOL)manually;
-(void)continuingFeed:(GRFeed*)feed;

-(void)markItemsAsRead:(NSArray*)items;
-(void)markItemAsRead:(GRItem*)item;
-(void)markAllAsRead:(GRSubscription*)sub waitUtilDone:(BOOL)wait;
-(void)reverseStateForItem:(GRItem*)item state:(NSString*)label;
-(void)refreshRecFeedsList;
-(void)reloadData;

-(void)subscribeFeed:(NSString*)streamID withTitle:(NSString*)title withTag:(NSString*)tag;
-(void)unsubscribeFeed:(NSString*)streamID;
-(void)removeTag:(NSString*)tag;

-(void)didReceiveErrorWhileRequestingData:(NSError *)error;
-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response;

-(void)cleanPooledObjects;
-(void)cleanAllData;

@end

@interface GRDataManager (private) 

-(NSArray*)getSubscriptionListWithoutTag;//get subscription list that with no tag

-(void)readerDMSetup;
-(void)sendNotification:(NSString*)name withUserInfo:(NSDictionary*)userInfo;
-(void)notifyErrorHappened;
-(void)readNewDataUnsynchronizly;
-(void)readListFromFile;
-(void)writeListToFile;
-(void)removeSavedFiles;
-(void)syncReaderStructure;

-(void)taskSyncReaderStructure;
-(void)taskContinuingFeed:(GRFeed*)feed;
-(void)taskSyncSubscriptions;
-(void)taskSyncTags;
-(void)taskSyncUnreadCount;
-(void)taskMarkAllAsRead:(GRSubscription*)sub;

-(void)buildProcessedList;
-(void)updateUnreadCountToProcessedList;
-(void)cleanCache;
-(void)clearMemory;

@end