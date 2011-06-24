//
//  UserPreferenceDataSouce.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPreferenceTableViewCell.h"

@interface UserPreferenceDataSouce : NSObject <UITableViewDataSource, UserPreferenceTableViewCellDelegate> {

	NSDictionary* _userPreferenceBundle;
	
	NSMutableDictionary* _itemsForPreference;
	
	NSString* _bundleName;
	
}

@property (nonatomic, retain) NSDictionary* userPreferenceBundle;
@property (nonatomic, retain) NSMutableDictionary* itemsForPreference;
@property (nonatomic, retain) NSString* bundleName;

@end
