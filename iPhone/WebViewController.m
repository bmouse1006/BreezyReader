//
//  WebViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize webView = _webView;
@synthesize URLRequest = _URLRequest;
@synthesize myToolbar = _myToolbar;
@synthesize activityIndView = _activityIndView;

-(id)initWithURLRequest:(NSURLRequest*)request{
	if (self = [super init]){
		self.URLRequest = request;
	}
	return self;
}

- (void)dealloc {
	[self.webView release];
	[self.URLRequest	release];
	[self.myToolbar release];
	[self.activityIndView release];
    [super dealloc];
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.webView loadRequest:self.URLRequest];
}

-(void)loadToolbarItems{
	
	// create the system-defined "OK or Done" button
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																  target:self
																  action:@selector(dismissModelView)];
	
	NSArray *items = [NSArray arrayWithObjects:cancelButton,nil];
	[self.myToolbar setItems:items animated:YES];	
	[cancelButton release];
}

-(IBAction)dismissModalView{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UIWebView delegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[self.activityIndView stopAnimating];
	
}

-(void)webViewDidStartLoad:(UIWebView*)webView{
//	if (!self.activityIndView){
//		UIActivityIndicatorView* indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//	
//		self.activityIndView = indView;
//		
//		[indView release];
//	}
		
	[self.activityIndView startAnimating];

}

@end
