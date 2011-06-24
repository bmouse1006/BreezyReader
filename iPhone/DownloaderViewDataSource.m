//
//  DownloaderViewDataSource.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloaderViewDataSource.h"
#import "GRDownloadManager.h"

@implementation DownloaderViewDataSource

-(void)refresh{
	DebugLog(@"refresh downloader view data source");
	self.defaultList = [NSArray arrayWithArray:[GRDownloadManager shared].downloaderQueue];
}

-(UITableViewStyle)tableViewStyle{
	
	UITableViewStyle style = UITableViewStylePlain;
//	if ([UserPreferenceDefine iPadMode]){
//		style = UITableViewStyleGrouped;
//	}
	return style;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	DebugLog(@"get number of sub downloaders");
	NSInteger count = [self.defaultList count];
//	if (!count){
//		count = 1;
//	}
    return count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	GRSubDownloader* downloader = [self objectForIndexPath:indexPath];
	[[GRDownloadManager shared] removeDownloader:downloader];
	[self refresh];
	return;
}

-(id)objectForIndexPath:(NSIndexPath*)indexPath{
	id object = [self.defaultList objectAtIndex:indexPath.row];
	return object;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (![self.defaultList count]){
//		UITableViewCell* defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//		defaultCell.detailTextLabel.text = @"no downloader";
//		return defaultCell;
//	}
//	
//	if (![self.defaultList count]){
//		UITableViewCell* cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//		cell.textLabel.text = @"no downloader";
//		cell.textLabel.textAlignment = UITextAlignmentCenter;
//		return cell;
//	}
	
    static NSString *CellIdentifier = @"Cell";
    
    DownloaderViewCell *cell = (DownloaderViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[DownloaderViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.delegate = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	cell.downloaderObject = [self.defaultList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark delegate method

-(void)switchDownloaderStatus:(GRSubscription*)sub{
	GRSubDownloader* downloader = [[GRDownloadManager shared] downloaderForSub:sub];
	switch (downloader.states) {
		case GRDownloaderStatesRunning:
			[[GRDownloadManager shared] stopDownloaderForSub:sub];
			break;
		case GRDownloaderStatesWaitting:
			[[GRDownloadManager shared] stopDownloaderForSub:sub];
			break;
		case GRDownloaderStatesStopped:
			[[GRDownloadManager shared] startDownloaderForSub:sub];
			break;
		default:
			break;
	}
}

@end
