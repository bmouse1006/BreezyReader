//
//  DownloaderViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloaderViewDataSource.h"

@interface DownloaderViewController : UITableViewController {

	DownloaderViewDataSource* _dataSource;
	UITableView* _theTableView;
	
}

@property (nonatomic, retain) DownloaderViewDataSource* dataSource;
@property (nonatomic, retain) UITableView* theTableView;

-(void)reloadSourceAndTable;

@end

@interface DownloaderViewController (private)

-(void)downloaderQueueChanged:(NSNotification*)sender;

@end