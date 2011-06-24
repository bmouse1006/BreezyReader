//
//  TagSubTableViewCell.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"

@interface TagSubTableViewCell : UITableViewCell {
	NSObject<GRBaseProtocol>* _cellGRObject;
	
	UIImage* _leftIcon;
	UIImage* _unreadIcon;
	
	UILabel* _unreadLabel;
	
}

@property (nonatomic, retain, setter=setCellGRObject:) NSObject<GRBaseProtocol>* cellGRObject;
@property (nonatomic, retain) UIImage* leftIcon;
@property (nonatomic, retain) UIImage* unreadIcon;
@property (nonatomic, retain) UILabel* unreadLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier;

-(void)setCellGRObject:(NSObject<GRBaseProtocol>*)mCellGRObject;

-(UIView*)generateAccessoryViewForUnreadCount:(NSNumber*)unreadCount;

@end
