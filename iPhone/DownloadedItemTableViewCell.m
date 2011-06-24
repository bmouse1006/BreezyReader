//
//  DownloadedItemTableViewCell.m
//  SmallReader
//
//  Created by Jin Jin on 10-9-16.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import "DownloadedItemTableViewCell.h"
#import "UserPreferenceDefine.h"

@implementation DownloadedItemTableViewCell

//don't need star image for downloaded items.
//could add more specification in the future
-(void)setupViewForGRObject{
	[super setupViewForGRObject];
	self.imageView.image = nil;
}

@end
