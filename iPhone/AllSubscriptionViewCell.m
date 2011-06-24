//
//  AllSubscriptionViewCell.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AllSubscriptionViewCell.h"


@implementation AllSubscriptionViewCell

@synthesize cellGRObject = _cellGRObject;

-(void)setCellGRObject:(GRSubscription*)sub{
	[sub retain];
	if (_cellGRObject != sub){
		[_cellGRObject release];
		_cellGRObject = sub;
		[_cellGRObject retain];
	};
	[sub release];
	
	self.textLabel.text = NSLocalizedString([_cellGRObject presentationString], nil);
	self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	
}

#pragma mark lifecycle

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)CellIdentifier{
	if (self = [super initWithStyle:style reuseIdentifier:CellIdentifier]){
//		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return self;
}

-(void)dealloc{
	[self.cellGRObject release];
	[super dealloc];
}

@end
