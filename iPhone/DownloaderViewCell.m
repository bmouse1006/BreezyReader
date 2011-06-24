//
//  DownloaderViewCell.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloaderViewCell.h"
#import "TSCellBackgroundView.h"

#define NUMBEROFSUCCESSDOWNLOAD @"numberOfSuccessDownload"
#define STATES @"states"

@implementation DownloaderViewCell

@synthesize downloaderObject = _downloaderObject;
@synthesize progressView = _progressView;
@synthesize controlButton = _controlButton;

@synthesize delegate = _delegate;

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context{
	
	if ([keyPath isEqualToString:NUMBEROFSUCCESSDOWNLOAD] && object == self.downloaderObject){
		
		DebugLog(@"downloaded number changed!!");

		[self performSelector:@selector(layoutProgressView) 
					 onThread:[NSThread mainThread] 
				   withObject:nil 
				waitUntilDone:NO];
	}
	
	if ([keyPath isEqualToString:STATES] && object == self.downloaderObject){
		
		DebugLog(@"states changed!! new value is %i", self.downloaderObject.states);
		
		[self performSelector:@selector(layoutByStates) 
					 onThread:[NSThread mainThread] 
				   withObject:nil 
				waitUntilDone:NO];
	}
}

-(void)setDownloaderObject:(GRSubDownloader*)obj{
	if (_downloaderObject != obj){
		//remove observer
		[_downloaderObject removeObserver:self forKeyPath:NUMBEROFSUCCESSDOWNLOAD];
		[_downloaderObject removeObserver:self forKeyPath:STATES];
		
		[_downloaderObject release];
		_downloaderObject = obj;
		[_downloaderObject retain];
		//add observer
		[_downloaderObject addObserver:self
							forKeyPath:NUMBEROFSUCCESSDOWNLOAD
							   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
							   context:nil];
		[_downloaderObject addObserver:self
							forKeyPath:STATES
							   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
							   context:nil];
	}

	[self layoutProgressView];
	[self layoutByStates];

	self.textLabel.text = NSLocalizedString([self.downloaderObject.subscription presentationString], nil);
	self.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-1];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];

}

-(void)layoutByStates{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
	if (!self.controlButton){
		
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0, 0, 40, 40);
		[button becomeFirstResponder];
		[button addTarget:self
				   action:@selector(actionForControlButton) 
		 forControlEvents:UIControlEventTouchUpInside];
		self.controlButton = button;
		self.accessoryView = self.controlButton;
	}
	
	TSCellBackgroundView* backView = nil;
	
	UIImage* buttonImage = nil;
	
	NSString* stop = @"stop.png";
	NSString* play = @"play.png";
	
	switch (self.downloaderObject.states) {
		case GRDownloaderStatesRunning:
			self.progressView.hidden = NO;
			self.detailTextLabel.text = NSLocalizedString(@" ", nil);
			buttonImage = [self getFitSizedButtonImage:[UIImage imageNamed:stop]];
			backView = [[TSCellBackgroundView alloc] init];
			backView.theCellStyle = CellStyle_Middle;
			break;
		case GRDownloaderStatesStopped:
			self.progressView.hidden = YES;
			self.detailTextLabel.text = NSLocalizedString(@"Stopped", nil);
			buttonImage = [self getFitSizedButtonImage:[UIImage imageNamed:play]];
			break;
		case GRDownloaderStatesWaitting:
			self.progressView.hidden = YES;
			buttonImage = [self getFitSizedButtonImage:[UIImage imageNamed:stop]];
			self.detailTextLabel.text = NSLocalizedString(@"Waiting", nil);
			break;
		default:
			self.progressView.hidden = YES;
			buttonImage = [self getFitSizedButtonImage:[UIImage imageNamed:play]];
			break;
	}
	[self.controlButton setImage:buttonImage
						forState:UIControlStateNormal];	
	self.backgroundView = backView;
	[backView release];
	[self setNeedsDisplay];
	[pool release];
}

-(void)layoutProgressView{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if (!self.progressView){
		UIProgressView* pView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		self.progressView = pView;
		CGRect frame = self.progressView.frame;
		frame.origin.x = 10;
		frame.origin.y = 35;
		frame.size.width = 260;
		self.progressView.frame = frame;
		[pView release];
		//add progress view to detail text label view;
		[self.contentView addSubview:self.progressView];
		[self.contentView bringSubviewToFront:self.progressView];
		self.detailTextLabel.text = @" ";
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
	
	self.progressView.progress = (float)self.downloaderObject.numberOfSuccessDownload/((float)self.downloaderObject.numberOfTotalItems+0.01);//avoid devide zero error
	[pool release];
}

-(void)actionForControlButton{
	[self.delegate switchDownloaderStatus:self.downloaderObject.subscription];
}

-(UIImage*)getFitSizedButtonImage:(UIImage*)buttonImage{;
	
//	CGSize size = buttonImage.size;
//	
//	NSInteger limitWidth = 24;
//	NSInteger limitHeight = 24;
//	
//	if (size.width > limitWidth || size.height > limitHeight){
//		
//		CGSize newSize = CGSizeMake(limitWidth, limitHeight);
//		UIGraphicsBeginImageContext(newSize);
//		CGRect newRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
//		[buttonImage drawInRect:newRect];
//		buttonImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//	}
	return buttonImage;
}

#pragma mark --
#pragma mark init and dealloc

-(id)init{
	if (self = [super init]){
		self.progressView = nil;
		self.downloaderObject = nil;
		self.controlButton = nil;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return self;
}

-(void)dealloc{
	[self.downloaderObject removeObserver:self 
							   forKeyPath:NUMBEROFSUCCESSDOWNLOAD];
	[self.downloaderObject removeObserver:self
							   forKeyPath:STATES];
	[self.progressView release];
	[self.downloaderObject release];
	[self.controlButton release];
	[super dealloc];
}

@end
