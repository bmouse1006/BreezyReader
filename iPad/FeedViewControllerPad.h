//
//  FeedViewControllerPadPad.h
//  SmallReader
//
//  Created by Jin Jin on 10-9-6.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedDataSource.h"
#import "GRSubscription.h"
#import "ItemViewController.h"
#import "UserPreferenceDefine.h"
#import "ChooseLabelForSubController.h"

#define FEEDTABLEVIEWCELLHEIGHT 60

@interface FeedViewControllerPad : UITableViewController <UIActionSheetDelegate, ChooseLabelForSubDelegate> {
	GRSubscription* _grSub;
	UITableView* _theTableView;
	FeedDataSource* _dataSource;
	
	UIBarButtonItem* _normalRefreshButton;
	UIBarButtonItem* _activityButton;
	UISegmentedControl* _unreadSegment;
	
	UIToolbar* _buttomToolbar;
	UILabel* _updatedTimeLabel;
	
	UIActionSheet* _actionSheet;
	
	BOOL _showSource;
	
	UIBarButtonItem* _subscribeButton;
	UIBarButtonItem* _dismissButton;
	BOOL _modalStyle;
	
	id<ChooseLabelForSubDelegate> _delegate;
}

@property (nonatomic, retain) GRSubscription* grSub;
@property (nonatomic, retain) IBOutlet FeedDataSource* dataSource;
@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) UIBarButtonItem* normalRefreshButton;
@property (nonatomic, retain) UIBarButtonItem* activityButton;
@property (nonatomic, retain) UISegmentedControl* unreadSegment;
@property (nonatomic, retain) IBOutlet UIToolbar* buttomToolbar;
@property (nonatomic, retain) UILabel* updatedTimeLabel;
@property (nonatomic, assign) BOOL showSource;
@property (nonatomic, retain) UIActionSheet* actionSheet;
@property (nonatomic, retain) UIBarButtonItem* subscribeButton;
@property (nonatomic, retain) UIBarButtonItem* dismissButton;
@property (nonatomic, assign) BOOL modalStyle;
@property (nonatomic, assign) id<ChooseLabelForSubDelegate> delegate;

-(id)initWithObject:(id<GRBaseProtocol>)mGRSub;

@end

@interface FeedViewControllerPad (private)

-(void)errorHappened:(NSNotification*)sender;
-(void)feedUpdated:(NSNotification*)sender;
-(void)refreshDatasource:(id)sender;

-(void)createButtomToolbar;
-(void)createTableView;

-(void)createNavigationBarButton;
-(void)handleSegmentControllerEvent;
-(void)formatUpdateTimeLabel:(UILabel*)label;

@end