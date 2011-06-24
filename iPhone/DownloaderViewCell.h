//
//  DownloaderViewCell.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRSubDownloader.h"

@protocol DownloaderViewCellDelegate

-(void)switchDownloaderStatus:(GRSubscription*)sub;

@end

@interface DownloaderViewCell : UITableViewCell {

	GRSubDownloader* _downloaderObject;
	
	UIProgressView* _progressView;
	
	UIButton* _controlButton;
	
	id<DownloaderViewCellDelegate> _delegate;
}

@property (nonatomic, retain, setter=setDownloaderObject:) GRSubDownloader* downloaderObject;
@property (nonatomic, retain) UIProgressView* progressView;
@property (nonatomic, retain) UIButton* controlButton;
@property (nonatomic, assign) id<DownloaderViewCellDelegate> delegate;

-(void)layoutProgressView;
-(void)layoutByStates;

-(void)actionForControlButton;
-(UIImage*)getFitSizedButtonImage:(UIImage*)buttonImage;

@end
