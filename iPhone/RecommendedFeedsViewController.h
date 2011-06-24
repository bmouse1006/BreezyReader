//
//  RecommendedFeedsViewController.h
//  SmallReader
//
//  Created by Jin Jin on 10-10-28.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRDiscover.h"
#import "RecFeedsDataSource.h"
#import "ChooseLabelForSubController.h"

@interface RecommendedFeedsViewController : UITableViewController <ChooseLabelForSubDelegate> {
	
	GRDiscover* _discoverObj; 
	
	UITableView* _theTableView;
	UIActivityIndicatorView* _activityIndicator;
	RecFeedsDataSource* _dataSource;
	
	NSString* _lastSubscribedStreamID;
}

@property (nonatomic, retain) GRDiscover* discoverObj;
@property (nonatomic, retain) UITableView* theTableView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) RecFeedsDataSource* dataSource;
@property (nonatomic, retain) NSString* lastSubscribedStreamID;

-(id)initWithGRDiscover:(GRDiscover*)discover;
-(id)initWithObject:(id)initObj;

-(void)recFeedsRefreshed;
-(void)receiveSubscribeRequest:(NSNotification*)notification;

@end
