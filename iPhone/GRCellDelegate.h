//
//  GRCellDelegate.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRItem.h"

@protocol GRCellDelegate

@required

-(void)reverseStarForItem:(GRItem*)mItem;

@end
