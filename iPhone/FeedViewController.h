//
//  FeedViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedDataSource.h"
#import "GRSubscription.h"
#import "ItemViewController.h"
#import "UserPreferenceDefine.h"

#define FEEDTABLEVIEWCELLHEIGHT 40

@interface FeedViewController : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate> {
	GRSubscription* _grSub;
	UITableView* _theTableView;
	FeedDataSource* _dataSource;
	
	UIBarButtonItem* _normalRefreshButton;
	UIBarButtonItem* _activityButton;
	UISegmentedControl* _unreadSegment;
	
	UITableViewCell* _selectedCell;
	
	UIToolbar* _buttomToolbar;
	UILabel* _updatedTimeLabel;
	
	BOOL _showSource;
}

@property (nonatomic, retain) GRSubscription* grSub;
@property (nonatomic, retain) IBOutlet FeedDataSource* dataSource;
@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) UIBarButtonItem* normalRefreshButton;
@property (nonatomic, retain) UIBarButtonItem* activityButton;
@property (nonatomic, retain) UISegmentedControl* unreadSegment;
@property (nonatomic, retain) UITableViewCell* selectedCell;
@property (nonatomic, retain) IBOutlet UIToolbar* buttomToolbar;
@property (nonatomic, retain) UILabel* updatedTimeLabel;
@property (nonatomic, assign) BOOL showSource;

-(id)initWithObject:(id<GRBaseProtocol>)mGRSub;

@end

@interface FeedViewController (private)

-(void)errorHappened:(NSNotification*)sender;
-(void)feedUpdated:(NSNotification*)sender;
-(void)refreshDatasource:(id)sender;

-(void)createButtomToolbar;
-(void)createTableView;

-(void)createRefreshButton;
-(void)handleSegmentControllerEvent;
-(void)formatUpdateTimeLabel:(UILabel*)label;

@end

