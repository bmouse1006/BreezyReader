//
//  WebViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPreferenceDefine.h"

@interface WebViewController : UIViewController<UIWebViewDelegate> {
	UIWebView* _webView;
	NSURLRequest* _URLRequest;
	UIToolbar* _myToolbar;
	
	UIActivityIndicatorView* _activityIndView;
}

@property (nonatomic,retain) IBOutlet UIWebView* webView;
@property (nonatomic,retain) IBOutlet UIToolbar* myToolbar;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* activityIndView;
@property (nonatomic,retain) NSURLRequest* URLRequest;

-(id)initWithURLRequest:(NSURLRequest*)request;
-(IBAction)dismissModalView;

@end

@interface WebViewController (private)

-(void)loadToolbarItems;

@end