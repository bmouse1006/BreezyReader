//
//  UserPreferenceControllerForPhone.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPreferenceDataSouce.h"
#import "UserPreferenceDefine.h"

@interface UserPreferenceControllerForPhone : UITableViewController {

	UserPreferenceDataSouce* _dataSource;
	
}

@property (nonatomic, retain) UserPreferenceDataSouce* dataSource;

@end
