//
//  RecFeedsCell.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-3.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRRecFeed.h"


@interface RecFeedsCell : UITableViewCell {

	UILabel* _feedTitle;
	UILabel* _feedSnippet;
	UIButton* _subButton;
	UIActivityIndicatorView* _indicator;
	
	GRRecFeed* _feed;
	
	BOOL useDarkBackground;
	
}

@property (nonatomic, retain) IBOutlet UILabel* feedTitle;
@property (nonatomic, retain) IBOutlet UILabel* feedSnippet;
@property (nonatomic, retain) IBOutlet UIButton* subButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* indicator;
@property (nonatomic, retain) GRRecFeed* feed;
@property (nonatomic, assign, setter=setUseDarkBackground:) BOOL useDarkBackground;

-(void)setRecFeedObj:(GRRecFeed*)obj;
-(void)setIsSubscribing:(BOOL)isSubscribing;
-(void)refreshCell;
-(IBAction)subscribe;

@end
