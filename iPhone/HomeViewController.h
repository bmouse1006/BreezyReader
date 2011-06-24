//
//  HomeViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAppLib.h"
#import "HomeDataSource.h"
#import "TagSubTableViewCell.h"
#import "FeedViewController.h"
#import "TagViewController.h"
#import "UserPreferenceDefine.h"
#import "RecommendedFeedsViewController.h"

@interface HomeViewController : UITableViewController<UIAlertViewDelegate> {
	UITableView* _theTableView;
	HomeDataSource* _dataSource;
	
	UIBarButtonItem* _loginButton;
	UIBarButtonItem* _downloadButton;
	
	BOOL _structureChanged;
	BOOL _unreadCountChanged;
	
}

@property (nonatomic, retain) UITableView* theTableView;
@property (nonatomic, retain) HomeDataSource* dataSource;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* loginButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* downloadButton;
@property (nonatomic, assign) BOOL structureChanged;
@property (nonatomic, assign) BOOL unreadCountChanged;

-(void)loginButtonActoin:(id)sender;
-(void)updateTableView;
-(void)logoutAction;

-(void)sendSelectNotification:(id)obj;
-(void)sendSelectNotificationWithClass:(NSString*)className initObj:(id)obj;

@end
