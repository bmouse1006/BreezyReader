//
//  TagSubTableViewCell.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TagSubTableViewCell.h"


@implementation TagSubTableViewCell

@synthesize cellGRObject = _cellGRObject;
@synthesize leftIcon = _leftIcon;
@synthesize unreadIcon = _unreadIcon;
@synthesize unreadLabel = _unreadLabel;

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context{
	if ([keyPath isEqualToString:@"unread"]){
		DebugLog(@"unread count changed");
		NSNumber* newnumber = [change objectForKey:NSKeyValueChangeNewKey];
		NSNumber* oldnumber = [change objectForKey:NSKeyValueChangeOldKey];
		
		if (![newnumber isEqualToNumber:oldnumber]){		
			[self performSelectorOnMainThread:@selector(generateAccessoryViewForUnreadCount:)
								   withObject:newnumber 
								waitUntilDone:NO];
		}
	}
	
}

-(void)setCellGRObject:(NSObject<GRBaseProtocol>*)mCellGRObject{
	
	if (_cellGRObject != mCellGRObject){
		[_cellGRObject removeObserver:self forKeyPath:@"unread"];
		[_cellGRObject release];
		_cellGRObject = mCellGRObject;
		[_cellGRObject retain];
		[_cellGRObject addObserver:self forKeyPath:@"unread"
						   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
						   context:nil];
	}

	UIImage* icon = [_cellGRObject icon];
	
	self.leftIcon = icon;
	self.imageView.image = icon;
	self.textLabel.text = NSLocalizedString([_cellGRObject presentationString], nil);
	self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	[self generateAccessoryViewForUnreadCount:[NSNumber numberWithInt:[_cellGRObject unreadCount]]];
	
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier{
	if (self = [super initWithStyle:style reuseIdentifier:identifier]){
		self.leftIcon = nil;
		self.unreadIcon = nil;
		self.cellGRObject = nil;
	}
	
	return self;
}

-(UIView*)generateAccessoryViewForUnreadCount:(NSNumber*)mUnreadCount{

	NSUInteger unreadCount = [mUnreadCount intValue];
	if (self.unreadLabel == nil){
		UILabel* countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
		countLabel.font = [UIFont systemFontOfSize:12];
		countLabel.textAlignment = UITextAlignmentRight;
		countLabel.highlightedTextColor = [UIColor whiteColor];
		countLabel.backgroundColor = [UIColor clearColor];
		self.accessoryView = countLabel;
		self.editingAccessoryView = countLabel;
		self.unreadLabel = countLabel;
		[countLabel release];
	}
	
	if (unreadCount > 0){
		if (![self.unreadLabel.text isEqualToString:[mUnreadCount stringValue]]){
			self.unreadLabel.text = [NSString stringWithFormat:@"%i", unreadCount];
		}
	}else {
		DebugLog(@"clear unread count");
		self.unreadLabel.text = @"";
		if (self.editing){
			[self setEditing:NO animated:YES];
		}
	}
	
	if ([self.unreadLabel.text isEqualToString:@"1000"]){
		self.unreadLabel.text = @"1000+";
	}
	
	return self.unreadLabel;
}

-(void)dealloc{
	[self.cellGRObject removeObserver:self forKeyPath:@"unread"];
	[self.cellGRObject release];
	[self.leftIcon release];
	[self.unreadIcon release];
	[self.unreadLabel release];
	[super dealloc];
}

@end
