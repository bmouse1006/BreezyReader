//
//  GRDownloadManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRItem.h"
#import "GRSubscription.h"
#import "GRSubDownloader.h"
#import "GRItemDownloader.h"
#import "GRSubModel.h"

#define DOWNLOADERQUEUECHANGED @"downloaderQueueChanged"
#define DOWNLOADERQUEUECHANGEDINDEXSET @"indexSet"
#define DOWNLOADERQUEUECHANGEDTYPE @"changeType"
#define DOWNLOADERQUEUECHANGEDMOVEFROM @"moveFrom"
#define DOWNLOADERQUEUECHANGEDMOVETO @"moveTo"

typedef enum{
	GRDownloaderQueueChangeTypeInsert,
	GRDownloaderQueueChangeTypeRemove,
	GRDownloaderQueueChangeTypeUpdate,
	GRDownloaderQueueChangeTypeMove,
	GRDownloaderQueueChangeTypeStateChange
} GRDownloadManagerQueueChangeType;

@interface GRDownloadManager : NSObject<GRSubDownloaderDelegate, GRItemDownloaderDelegate> {

	NSMutableArray* _downloaderQueue;

	NSMutableDictionary* _downloaderIndex;
	
	NSUInteger _maxConcurrency;
	
	NSUInteger _numberOfRunningDownloader;
	
	NSMutableDictionary* _itemDownloaderDictionary;
	
	NSFetchedResultsController* _fetchedResultsController;
	NSManagedObjectContext* _context;
}

@property (retain) NSMutableArray* downloaderQueue;
@property (retain) NSMutableDictionary* downloaderIndex;
@property (nonatomic, assign) NSUInteger maxConcurrency;
@property (assign, readonly) NSUInteger numberOfRunningDownloader;
@property (nonatomic, retain) NSMutableDictionary* itemDownloaderDictionary;
@property (nonatomic, retain) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext* context;

-(BOOL)containsDownloaderForSub:(GRSubscription*)sub;
-(BOOL)addSubscriptionToDownloadQueue:(GRSubscription*)sub;
-(BOOL)removeDownloaderForSub:(GRSubscription *)sub;
-(BOOL)removeDownloader:(GRSubDownloader*)downloader;
-(BOOL)setDownloadStatusForSubscription:(GRSubscription *)sub;
-(BOOL)saveSingleItem:(GRItem*)item;
-(BOOL)stopAllDownloaders;
-(BOOL)startAllDownloaders;
-(BOOL)stopDownloaderForSub:(GRSubscription*)sub;
-(BOOL)startDownloaderForSub:(GRSubscription*)sub;
-(NSUInteger)numberofDownloadersForStates:(GRDownloaderStates)states;
+ (GRDownloadManager*)shared;
-(GRSubDownloader*)downloaderForSub:(GRSubscription*)sub;
+(void)didReceiveMemoryWarning;
-(BOOL)itemDownloaded:(GRItem*)item;

@end

@interface GRDownloadManager (private)

-(void)downloaderQueueChanged;
-(void)startTopWaittingDownloader;
-(void)sendDownloaderQueueChangedNotification:(NSIndexSet*)indexSet 
							  queueChangeType:(GRDownloadManagerQueueChangeType)changeType;
-(GRSubModel*)downloadedSubscriptionForID:(NSString*)subID;
-(NSArray*)fetchDownloadedSub;
-(NSMutableDictionary*)cachedDownloadedSubscriptions;
-(void)setupFetchedController;

@end

