//
//  SearchFeedsViewController.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-18.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchFeedsDataSource.h"

@interface SearchFeedsViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
	NSString* _searchString;
	UITableView* _theTableView;
	SearchFeedsDataSource* _dataSource;
}

@property (nonatomic, retain) NSString* searchString;
@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) IBOutlet SearchFeedsDataSource* dataSource;

@end
