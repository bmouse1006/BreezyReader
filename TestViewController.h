//
//  TestViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAppLib.h"
#import "GRFeed.h"
#import "GRItem.h"
#import "RegexKitLite.h"

@interface TestViewController : UIViewController {
	
	IBOutlet UITextField* username;
	IBOutlet UITextField* password;
	IBOutlet UITextField* queryURL;
	
	IBOutlet UITextField* label;
	IBOutlet UITextField* states;
	
	UITextField* sourceImageTag;
	
	UILabel* parseResult;
	
	GoogleReaderController* googleReaderController;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *queryURL;
@property (nonatomic, retain) IBOutlet UITextField *label;
@property (nonatomic, retain) IBOutlet UITextField *states;
@property (nonatomic, retain) IBOutlet UITextField* sourceImageTag;
@property (nonatomic, retain) IBOutlet UILabel* parseResult;

@property (retain) GoogleReaderController* googleReaderController;

-(void)testConnectionWithUserName:(NSString*)username
					  andPassword:(NSString*)password;

-(IBAction)testConnection;
-(IBAction)queryAction;
-(IBAction)logout;
-(IBAction)allSubscription;
-(IBAction)readSubscription;

-(IBAction)testReadForLabel;
-(IBAction)testReadForState;

-(IBAction)parseImageTag;

@end
