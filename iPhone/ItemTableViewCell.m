//
//  ItemTableViewCell.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "UserPreferenceDefine.h"
#import "GRDataManager.h"

@implementation ItemTableViewCell

@synthesize cellGRObject = _cellGRObject;
@synthesize starButton = _starButton;
@synthesize showSource = _showSource;
@synthesize delegate;

-(void)setCellGRObject:(GRItem*)mCellGRObject{
	[mCellGRObject retain];
	if (_cellGRObject != mCellGRObject){
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:[_cellGRObject.ID stringByAppendingString:@"read"] 
													  object:nil];
		[_cellGRObject release];
		_cellGRObject = mCellGRObject;
		[_cellGRObject retain];
		[[NSNotificationCenter defaultCenter] addObserver:self
												  selector:@selector(layoutSubviews)
													  name:[_cellGRObject.ID stringByAppendingString:@"read"]
													object:nil];
	}
	[mCellGRObject release];
	[self setupViewForGRObject];
}

-(void)setupStarButton{
	if (!self.starButton){
		CGRect buttonFrame = CGRectMake(8, 8, 40, 40);
		UIButton* button = [[UIButton alloc] initWithFrame:buttonFrame];
		[self.contentView addSubview:button];
		[button becomeFirstResponder];
		[button addTarget:self 
				   action:@selector(starForCurrentItem) 
		 forControlEvents:UIControlEventTouchUpInside];
		self.starButton = button;
		[button release];
	}
}

 -(void)starForCurrentItem{
	 [self.delegate reverseStarForItem:self.cellGRObject];
	 [self setNeedsLayout];
 }
		 
- (void)layoutSubviews{
	self.imageView.image = [self.cellGRObject icon];
	if (!self.highlighted){
		if ([self.cellGRObject isReaded]){
			[self setupViewforRead];
		}else {
			[self setupViewforUnread];
		}
	}
	[super layoutSubviews];
}

-(void)setupViewForGRObject{
	self.imageView.image = [self.cellGRObject icon];
	
	self.textLabel.text = [self.cellGRObject presentationString];
	self.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-1];
	
	self.detailTextLabel.text = nil;

	if (self.showSource){

		self.detailTextLabel.text = self.cellGRObject.source_title;
	}
	
	if ([UserPreferenceDefine shouldShowPreviewOfArticle]) {
		NSString* plainSummary = self.cellGRObject.plainSummary;
		if (!plainSummary){
			plainSummary = self.cellGRObject.plainContent;
		}
		
		if (self.detailTextLabel.text){
			plainSummary = [self.detailTextLabel.text stringByAppendingFormat:@"  %@", plainSummary];
		}
		
//		self.detailTextLabel.text = [plainSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		self.detailTextLabel.text = plainSummary;
	}
	
	UILabel *subTime = nil;
	if (self.accessoryView == nil){
		subTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 16)];
		subTime.font = [UIFont systemFontOfSize:12];
		subTime.textAlignment = UITextAlignmentRight;
		subTime.textColor = [UIColor grayColor];
		subTime.text = [self.cellGRObject getShortUpdatedDateTime];
		subTime.highlightedTextColor = self.textLabel.highlightedTextColor;
		subTime.backgroundColor = [UIColor clearColor];
		self.accessoryView = subTime;
		[subTime release];
	}else {
		subTime = (UILabel*)self.accessoryView;
		subTime.text = [self.cellGRObject getShortUpdatedDateTime];
		self.accessoryView = subTime;
	}
}

-(void)setupViewforRead{
//	self.backgroundColor = [UIColor colorWithRed:0.949 green:1 blue:0.875 alpha:1];
	if ([UserPreferenceDefine iPadMode]){
		self.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
	}else {
		self.backgroundColor = [UIColor colorWithRed:0.929 
											   green:0.953
												blue:0.996
											   alpha:1];
	}

	self.textLabel.textColor = [UIColor grayColor];
}

-(void)setupViewforUnread{
	self.backgroundColor = [UIColor whiteColor];
	self.textLabel.textColor = [UIColor blackColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.delegate = nil;
		self.cellGRObject = nil;
		self.showSource = NO;
		[self setupStarButton];
	}

	return self;
}


-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:[self.cellGRObject.ID stringByAppendingString:@"read"] 
												  object:nil];
	[self.cellGRObject release];
	[self.starButton release];
	[self.delegate release];
	
	[super dealloc];
}

@end
