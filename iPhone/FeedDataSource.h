//
//  FeedDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseReaderDataSouce.h"
#import "GRFeed.h"
#import "GRItem.h"
#import "GRSubscription.h"
#import "ItemTableViewCell.h"
#import "GRCellDelegate.h"

#define BUFFERRING -1
#define NEEDBUFFER 0
#define BUFFERRED 1
#define NEEDMERGE 2
#define NOMOREBUFFER 3

@interface FeedDataSource : BaseReaderDataSouce <GRCellDelegate> {
	GRFeed* _grFeed;
	GRFeed* _feedBuffer;
	GRSubscription* _grSub;
	NSInteger bufferStatus;
	
	UITableViewCell* _buttomCell;
	
	BOOL _showSource;
}

@property (nonatomic, retain) GRFeed* grFeed;
@property (nonatomic, retain) GRFeed* feedBuffer;
@property (nonatomic, retain) GRSubscription* grSub;

@property (nonatomic, retain) IBOutlet UITableViewCell* buttomCell;

@property (nonatomic, assign) BOOL showSource;

-(id)initWithGRSub:(GRSubscription*)mGRSub;

-(BOOL)loadingMoreCellIsSelected;

-(void)mergeBufferFeedToDataSource;

-(BOOL)refreshBuffer;

-(NSDate*)latestUpdateTime;

-(void)markAllAsRead;

@end

@interface FeedDataSource (private)

-(void)reverseStarForItem:(GRItem*)mItem;
-(UITableViewCell*)createButtomCell;
-(void)loadBufferFeed;
-(UITableViewCell*)changeButtomCellAppearance:(UITableViewCell*)mButtomCell;

@end