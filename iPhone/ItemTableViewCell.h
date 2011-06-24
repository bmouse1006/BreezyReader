//
//  ItemTableViewCell.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRItem.h"
#import "GRCellDelegate.h"

@interface ItemTableViewCell : UITableViewCell {
	GRItem* _cellGRObject;
	UIButton* _starButton;
	
	NSObject<GRCellDelegate>* delegate;
	
	BOOL _showSource;
}

@property (nonatomic, retain, setter=setCellGRObject:) GRItem* cellGRObject;
@property (nonatomic, retain) UIButton* starButton;

@property (nonatomic, retain) NSObject<GRCellDelegate>* delegate;
@property (nonatomic, assign) BOOL showSource;

-(void)setupViewforRead;
-(void)setupViewforUnread;
-(void)setupStarButton;

-(void)setupViewForGRObject;

@end
