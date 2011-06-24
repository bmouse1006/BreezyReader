//
//  DownloadedItemsViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadedItemsDataSource.h"
#import "GRSubModel.h"

@interface DownloadedItemsViewController : UITableViewController <UITableViewDelegate, UIActionSheetDelegate> {
	UITableView* _theTableView;
	DownloadedItemsDataSource* _dataSource;
	
	GRSubscription* _sub;
	
	UIBarButtonItem* _clearButton;
	
	UIActionSheet* _actionSheet;
}

@property (nonatomic, retain) UITableView* theTableView;
@property (nonatomic, retain) DownloadedItemsDataSource* dataSource;
@property (nonatomic, retain) GRSubscription* sub;
@property (nonatomic, retain) UIBarButtonItem* clearButton;
@property (nonatomic, retain) UIActionSheet* actionSheet;

-(id)initWithObject:(id)sub;

@end
