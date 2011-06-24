//
//  FeedDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedDataSource.h"


@implementation FeedDataSource

@synthesize grFeed = _grFeed;
@synthesize grSub = _grSub;
@synthesize feedBuffer = _feedBuffer;
@synthesize buttomCell = _buttomCell;
@synthesize showSource = _showSource;

-(void)markAllAsRead{
	[self.grFeed.items makeObjectsPerformSelector:@selector(markAsRead)];
}

-(NSDate*)latestUpdateTime{
	return self.grFeed.updated;
}

-(void)loadBufferFeed{
	bufferStatus = BUFFERRING;
	NSString* continuation = self.grFeed.gr_continuation;
	if (continuation && ![@"" isEqualToString:continuation]){
		//load buffer from data manager
		[self.readerDM continuingFeed:self.grFeed];
	}
}

-(void)mergeBufferFeedToDataSource{
	//merge buffer to current feed
	[self.grFeed mergeWithFeed:self.feedBuffer continued:YES];
	//clear buffer
	self.feedBuffer = nil;
	bufferStatus = NEEDBUFFER;
	self.buttomCell = [self changeButtomCellAppearance:self.buttomCell];
}

-(BOOL)loadingMoreCellIsSelected{
	if (self.grFeed.gr_continuation == nil){
		return FALSE;
	}
	
	BOOL reloadData = NO;
	
	switch (bufferStatus) {
		case BUFFERRED:
			[self mergeBufferFeedToDataSource];
			[self loadBufferFeed];
			reloadData = YES;
			break;
		case BUFFERRING:
			bufferStatus = NEEDMERGE;
			break;
		case NEEDBUFFER:
			bufferStatus = NEEDMERGE;
			[self loadBufferFeed];
			break;
		default:
			break;
	}
	
	self.buttomCell = [self changeButtomCellAppearance:self.buttomCell];
	return reloadData;
}

-(void)reverseStarForItem:(GRItem*)mItem{
	[self.readerDM reverseStateForItem:mItem state:ATOM_STATE_STARRED];
}

-(void)refresh{
	self.grFeed = [self.readerDM feedWithSubID:[self.grSub keyString]];
	if (self.grFeed.gr_continuation){
		self.feedBuffer = [self.readerDM feedWithSubID:[[self.grFeed keyString] stringByAppendingString:self.grFeed.gr_continuation]];
	}
}

-(BOOL)refreshBuffer{
	DebugLog(@"refresh buffer now");
	
	self.feedBuffer = [self.readerDM feedWithSubID:[[self.grFeed keyString] stringByAppendingString:self.grFeed.gr_continuation]];

	BOOL needReloadTable = NO;
	if (bufferStatus == NEEDMERGE){
		[self mergeBufferFeedToDataSource];
		[self loadBufferFeed];
		needReloadTable = YES;
	}else{
		bufferStatus = BUFFERRED;
	}
	self.buttomCell = [self changeButtomCellAppearance:self.buttomCell];
	return needReloadTable;
}

-(UITableViewStyle)tableViewStyle{
	return UITableViewStylePlain;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.grFeed itemCount] + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}

-(UITableViewCell*)changeButtomCellAppearance:(UITableViewCell*)mButtomCell{
	[[mButtomCell retain] autorelease];
	DebugLog(@"buffer status is %d", bufferStatus);
	NSString* buttonString = nil;
	switch (bufferStatus) {
		case BUFFERRED:
			buttonString = NSLocalizedString(@"More", nil);
			break;
		case BUFFERRING:
			buttonString = NSLocalizedString(@"Loading", nil);
			break;
		case NEEDBUFFER:
			buttonString = NSLocalizedString(@"More", nil);
			break;
		case NEEDMERGE:
			buttonString = NSLocalizedString(@"Loading", nil);
			break;
		default:
			break;
	}
	if (self.grFeed == nil){
		buttonString = NSLocalizedString(@"Loading", nil);
	} else if (self.grFeed.gr_continuation == nil) {
		buttonString = NSLocalizedString(@"NoMore", nil);
	}
	
	[mButtomCell.textLabel performSelectorOnMainThread:@selector(setText:) 
											withObject:buttonString 
										 waitUntilDone:NO];
	
	return mButtomCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [self.grFeed itemCount]){
		self.buttomCell = [self changeButtomCellAppearance:self.buttomCell];
		return self.buttomCell;
	}

    static NSString *CellIdentifier = @"FeedCell";
    ItemTableViewCell* cell = (ItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		
		if (self.showSource || [UserPreferenceDefine shouldShowPreviewOfArticle]){
			style = UITableViewCellStyleSubtitle;
		}
		
		cell = [[[ItemTableViewCell alloc] initWithStyle:style
										 reuseIdentifier:CellIdentifier] autorelease];
		cell.delegate = self;
    }
	cell.showSource = self.showSource;
	cell.cellGRObject = [self.grFeed getItemAtIndex:indexPath];
	
    return cell;
}

-(NSString*)name{
	return NSLocalizedString([self.grSub presentationString], nil);
}

-(NSString*)navigationBarName{
	return NSLocalizedString([self.grSub presentationString], nil);
}

-(UITableViewCell*)createButtomCell{
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell = [self changeButtomCellAppearance:cell];
	cell.textLabel.textColor = [UIColor grayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:15];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	
	return cell;

}

-(id)initWithGRSub:(GRSubscription*)mGRSub{
	if (self = [super init]){
		self.grSub = mGRSub;
		self.grFeed = nil;
		self.feedBuffer = nil;
		self.showSource = NO;
		self.buttomCell = [self createButtomCell];
		bufferStatus = NEEDBUFFER;
		[self refresh];
	}
	return self;
}

-(void)dealloc{
	[self.grFeed release];
	[self.grSub release];
	[self.feedBuffer release];
	[self.buttomCell release];
	[super dealloc];
}

@end
