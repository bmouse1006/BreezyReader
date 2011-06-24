//
//  LoginViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAuthManager.h"
#import "GRDataManager.h"
#import "UserPreferenceDefine.h"

#define OBSERVEKEYPATH @"loginStatus"

@interface LoginViewController : UIViewController {

	UITextField* _usernameView;
	UITextField* _passwordView;
	
	UIButton* _loginButton;
	
	UIActivityIndicatorView* _activityIndicator;
}

@property (nonatomic, retain) IBOutlet UITextField* usernameView;
@property (nonatomic, retain) IBOutlet UITextField* passwordView;

@property (nonatomic, retain) IBOutlet UIButton* loginButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;


- (BOOL)textFieldShouldReturn:(UITextField *)textField;

-(IBAction)loginButtonTouched;
-(void)localizeViews;

@end
