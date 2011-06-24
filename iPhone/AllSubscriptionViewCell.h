//
//  AllSubscriptionViewCell.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRSubscription.h"

@interface AllSubscriptionViewCell : UITableViewCell {
	GRSubscription* _cellGRObject;
}

@property (nonatomic, retain, setter=setCellGRObject:) GRSubscription* cellGRObject;

@end
