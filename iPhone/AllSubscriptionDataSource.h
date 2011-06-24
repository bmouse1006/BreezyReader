//
//  AllSubscriptionDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseReaderDataSouce.h"

#define ONEDAY		@"oneDay"
#define TWODAYS		@"twoDays"
#define ONEWEEK		@"oneWeek"
#define ONEMONTH	@"oneMonth"
#define ONEMONTHBEFORE	@"oneMonthBefore"
#define FETCHRESULT @"fetchResult"

@interface AllSubscriptionDataSource : BaseReaderDataSouce {
	
	NSFetchedResultsController* _fetchController;
}

@property (nonatomic, retain) NSFetchedResultsController* fetchController;

-(void)refresh;
-(void)setupResultControllers;
-(void)splitUpFetchedResult;

@end
