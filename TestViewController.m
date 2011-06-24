//
//  TestViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestViewController.h"


@implementation TestViewController

@synthesize username;
@synthesize password;
@synthesize queryURL;
@synthesize googleReaderController;
@synthesize label;
@synthesize states;
@synthesize sourceImageTag;
@synthesize parseResult;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"loginStatus"]){
		DebugLog(@"login status changed!!");
//		NSString* oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//		NSString* newValue = [change objectForKey:NSKeyValueChangeNewKey];
//		DebugLog(@"old value is: %@", oldValue);
//		DebugLog(@"new value is: %@", newValue);
	}
}

-(IBAction)testConnection{
	[self testConnectionWithUserName:[username text] andPassword:[password text]];
}

-(IBAction)logout{
	DebugLog(@"logout now");
	[[GoogleAuthManager shared] logout];
}

-(void)testConnectionWithUserName:(NSString*)aUsername
					  andPassword:(NSString*)aPassword{
	DebugLog(@"connecting starts");
//	GoogleAuthManager *authManager = [GoogleAuthManager shared];
//	[authManager loginForUser:aUsername withPassword:aPassword];
	DebugLog(@"connecting finished");	
}

-(IBAction)queryAction{
	DebugLog(@"querying the api %@", queryURL.text);
	[googleReaderController testGoogleAPIwithURL:queryURL.text];
}

-(IBAction)allSubscription{
	[googleReaderController allSubscriptions];
	[googleReaderController allTags];
	[googleReaderController	unreadCount];
}

-(IBAction)readSubscription{
	NSString* url = queryURL.text;
//	NSString* url = nil;
	GRFeed* parsedFeed = [googleReaderController getFeedForURL:url count:nil startFrom:nil exclude:nil continuation:nil];
	[parsedFeed retain];
	for (GRItem* item in parsedFeed.items){
		DebugLog(@"item id is %@, item title is %@", item.ID, item.title);
	}
	[parsedFeed release];
	parsedFeed = nil;
}

-(IBAction)testReadForLabel{
	NSString* labelText = self.label.text;
	GRFeed* parsedFeed = [googleReaderController getFeedForLabel:labelText count:nil startFrom:nil exclude:nil continuation:nil];
	[parsedFeed retain];
	for (GRItem* item in parsedFeed.items){
		DebugLog(@"item id is %@, item title is %@", item.ID, item.title);
	}
	[parsedFeed release];
	parsedFeed = nil;
}

-(IBAction)testReadForState{
	NSString* stateText = self.states.text;
	GRFeed* parsedFeed = [googleReaderController getFeedForStates:stateText count:nil startFrom:nil exclude:nil continuation:nil];
	[parsedFeed retain];
	for (GRItem* item in parsedFeed.items){
		DebugLog(@"item id is %@, item title is %@", item.ID, item.title);
	}
	[parsedFeed release];
	parsedFeed = nil;
}

-(IBAction)parseImageTag{
/*	
	NSString* tagString = @"<       iMg width=\"200\" height=300 title=\"每日一美女：Scarlett" "Johansson\" alt=\"每日一美女：Scarlett Johansson / Jandan.net\"src=   http://pic.yupoo.com/jdvip/506119acf7bc/medium.jpg             '          /><       img width=\"200\" height=300 title=\"每日一美女：Scarlett" "Johansson\" alt=\"每日一美女：Scarlett Johansson / Jandan.net\"SrC=   http://pic.yupoo.com/jdvip/506119acf7bc/medium222222222222.jpg             '          />";
	
//	NSString* htmlString = @"<img src    =      http://pic.yupoo.com/jdvip/506119acf7bc/medium.jpg ' title=\"每日一美女：Scarlett" "Johansson\" alt=\"每日一美女：Scarlett Johansson / Jandan.net\"/>";
	
	NSString* searchPattern = @"(?<=&lt;img\\s*.*\\s*src=\\s*[\"|’])(.*?)(?=[\"|'])";
	
//	NSString* propertyParttern = @"(?i)(?<=&lt;img).*(?=&gt;)";
	
	NSString* propertyParttern = @"(?i)<\\s*img\\s*.*?\\s*src\\s*=\\s*[\"']?\\s*([^\\s'\"]*)\\s*[\"']?\\s*.*?>";
	
	NSString* srcParttern = @"\\bsrc\\s*=\\s*[\"|'](.+?)[\"|']";
	
	NSString* result = [tagString stringByMatching:searchPattern capture:1L];
	
	NSArray* resultArray = [tagString arrayOfCaptureComponentsMatchedByRegex:propertyParttern];
	
	for (NSString* tempStr in resultArray){
		DebugLog(@"tempStr: %@", tempStr);
	}
	
//	NSString* imageProperties = [tagString stringByMatching:propertyParttern capture:1];
//	NSString* imageSrc = [imageProperties stringByMatching:srcParttern capture:1L];
//	
//	DebugLog(@"source string is %@", tagString);
//	DebugLog(@"regex string is %@", searchPattern);
//	DebugLog(@"match string is %@", result);
//	DebugLog(@"imageProperties is %@", imageProperties);
//	DebugLog(@"image src is %@", imageSrc);
	
//	UIWebView* tempView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
//	
//	[tempView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.google.com"]];
//	
//	UIViewController* tempController = [[UIViewController alloc] init];
//	
//	tempController.view = tempView;
//	
//	[self presentModelViewController:tempController animated:YES];
	
	self.parseResult.text = result;
*/
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

-(id)init{
	if (self = [super init]){
		[[GoogleAuthManager shared] addObserver:self 
									 forKeyPath:@"loginStatus" 
										options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
										context:self];
		GoogleReaderController* tempController = [[GoogleReaderController alloc] init];
		self.googleReaderController = tempController;
		[tempController release];
	}
	return self;
}

- (void)dealloc {
	[self.googleReaderController release];
    [super dealloc];
}


@end
