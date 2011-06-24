//
//  LoginViewControllerPad.h
//  SmallReader
//
//  Created by Jin Jin on 10-9-10.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"


@interface LoginViewControllerPad : UIViewController {
	UITextField* _username;
	UITextField* _password;
	
	UIButton* _loginButton;
	
	UIActivityIndicatorView* _activityIndicator;
}

@property (nonatomic, retain) IBOutlet UITextField* username;
@property (nonatomic, retain) IBOutlet UITextField* password;
@property (nonatomic, retain) IBOutlet UIButton* loginButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;

-(void)localizeViews;
-(IBAction)loginButtonTouched;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
