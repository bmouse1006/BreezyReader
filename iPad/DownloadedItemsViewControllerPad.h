//
//  DownloadedItemsViewControllerPad.h
//  SmallReader
//
//  Created by Jin Jin on 10-9-6.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadedItemsDataSource.h"
#import "GRSubscription.h"

@interface DownloadedItemsViewControllerPad : UITableViewController {
	UITableView* _theTableView;
	DownloadedItemsDataSource* _theDataSource;
	GRSubscription* _sub;
}

@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) DownloadedItemsDataSource* theDataSource;
@property (nonatomic, retain) GRSubscription* sub;

-(void)setInitObject:(id)obj;

-(id)initWithObject:(id)object;

@end
