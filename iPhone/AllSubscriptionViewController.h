//
//  AllSubscriptionViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllSubscriptionDataSource.h"

@interface AllSubscriptionViewController : UITableViewController {
	
	AllSubscriptionDataSource* _dataSource;
	UITableView* _theTableView;
	UINavigationController* _theNavigationController;
}

@property (nonatomic, retain) AllSubscriptionDataSource* dataSource;
@property (nonatomic, retain) UITableView* theTableView;
@property (nonatomic, retain) UINavigationController* theNavigationController;

-(id)initWithNavigationController:(UINavigationController*)controller;

@end

@interface AllSubscriptionViewController (private)

-(void)reloadSourceAndTable;
-(void)sendSelectNotification:(id)obj;

@end