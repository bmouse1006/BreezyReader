//
//  RecFeedsCell.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-3.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "RecFeedsCell.h"

@implementation RecFeedsCell

@synthesize feedTitle = _feedTitle;
@synthesize feedSnippet = _feedSnippet;
@synthesize subButton = _subButton;
@synthesize indicator = _indicator;
@synthesize feed = _feed;
@synthesize useDarkBackground;

-(void)subscribeCancelled{
	DebugLog(@"cancel received");
	[self setIsSubscribing:NO];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:[NOTIFICATION_SUBSCRIBEFEED_CANCELLED stringByAppendingString:self.feed.streamID]
												  object:nil];
}

-(IBAction)subscribe{
	//register notification for cancel
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(subscribeCancelled)
												 name:[NOTIFICATION_SUBSCRIBEFEED_CANCELLED stringByAppendingString:self.feed.streamID]
											   object:nil];
	//notify that to subscribe this feed
	[self setIsSubscribing:YES];
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.feed, NOTIFICATION_SUBSCRIBEFEED_FEEDOBJ, nil];
	NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_SUBSCRIBEFEED object:self userInfo:userInfo];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)setRecFeedObj:(GRRecFeed*)obj{
	self.feed = obj;
	[self refreshCell];
}

-(void)refreshCell{
	self.feedTitle.text = self.feed.title;
	self.feedSnippet.text = self.feed.snippet;
	[self setIsSubscribing:self.feed.isSucscribing];
}

-(void)setIsSubscribing:(BOOL)isSubscribing{
	self.feed.isSucscribing = isSubscribing;
	if (isSubscribing){
		self.subButton.hidden = YES;
		[self.indicator startAnimating];
	}else {
		self.subButton.hidden = NO;
		[self.indicator stopAnimating];
	}

}

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView)
    {
        useDarkBackground = flag;
		
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBG" : @"LightBG" ofType:@"png"];
        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}

-(void)dealloc{

	self.feedTitle = nil;
	self.feedSnippet = nil;
	self.subButton = nil;
	self.indicator = nil;
	self.feed = nil;
	[super dealloc];
}

@end
