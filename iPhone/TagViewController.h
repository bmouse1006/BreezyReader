//
//  TagViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRDataManager.h"
#import "TagDataSource.h"
#import "FeedViewController.h"
#import "GRTag.h"
#import "UserPreferenceDefine.h"

@interface TagViewController : UITableViewController {
	GRTag* _grTag;
	
	UITableView* _theTableView;
	TagDataSource* _dataSource;
	
	UIBarButtonItem* _downloadButton;
	
	BOOL _structureChanged;
	BOOL _unreadCountChanged;
	
}

@property (nonatomic, retain) GRTag* grTag;
@property (nonatomic, retain) UITableView* theTableView;
@property (nonatomic, retain) TagDataSource* dataSource;
@property (nonatomic, retain) UIBarButtonItem* downloadButton;
@property (nonatomic, assign) BOOL structureChanged;
@property (nonatomic, assign) BOOL unreadCountChanged;

-(void)updateTableView;
-(void)sendSelectNotification:(id)obj;

@end
