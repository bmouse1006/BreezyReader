    //
//  LoginViewControllerPad.m
//  SmallReader
//
//  Created by Jin Jin on 10-9-10.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import "LoginViewControllerPad.h"

#define LOGINSTATUS @"loginStatus"

@implementation LoginViewControllerPad

@synthesize username = _username;
@synthesize password = _password;
@synthesize loginButton = _loginButton;
@synthesize activityIndicator = _activityIndicator;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id)init{
	if (self = [super init]){
		[[GoogleAuthManager shared] addObserver:self 
									 forKeyPath:LOGINSTATUS 
										options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
										context:nil];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:OBSERVEKEYPATH]){
		NSString* oldStatus = [change objectForKey:NSKeyValueChangeOldKey];
		NSString* newStatus = [change objectForKey:NSKeyValueChangeNewKey];
		DebugLog(@"old status is %@", oldStatus);
		DebugLog(@"new status is %@", newStatus);
		//after login success
		if ([newStatus isEqualToString:LOGIN_INPROGRESS]){
		}else if ([newStatus isEqualToString:LOGIN_SUCCESSFUL]){
			[[GRDataManager shared] reloadData];
			[self.parentViewController dismissModalViewControllerAnimated:YES];
		}else if([newStatus isEqualToString:LOGIN_FAILED]){
			self.username.enabled = YES;
			self.password.enabled = YES;
			self.loginButton.hidden = NO;
			[self.activityIndicator stopAnimating];
		}
	}
}

-(void)localizeViews{
	self.username.placeholder = NSLocalizedString(self.username.placeholder, nil);
	self.password.placeholder = NSLocalizedString(self.password.placeholder, nil);
	[self.loginButton setTitle:NSLocalizedString(self.loginButton.currentTitle, nil) 
					  forState:UIControlStateNormal];
	self.loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.loginButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self localizeViews];
	[self.username becomeFirstResponder];
}

-(IBAction)loginButtonTouched{
	[self textFieldShouldReturn:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (self.username.text == nil || [self.username.text isEqualToString:@""]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong input", nil)
														message:NSLocalizedString(@"UserNameIsEmpty", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											  otherButtonTitles:nil];
		[alert show];
        [alert release];
		return NO;
	}
	
	if (self.password.text == nil || [self.password.text isEqualToString:@""]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong input", nil)
														message:NSLocalizedString(@"PasswordIsEmpty", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											  otherButtonTitles:nil];
		[alert show];
        [alert release];
		return NO;
	}
	
	//disable subviews
	self.username.enabled = NO;
	self.password.enabled = NO;
	self.loginButton.hidden = YES;
	[self.activityIndicator startAnimating];
	DebugLog(@"username is %@", self.username.text);
	DebugLog(@"password is %@", self.password.text);
	[[GoogleAuthManager shared] asyncLoginForUser:self.username.text 
									 withPassword:self.password.text 
									   loginToken:nil
									 logincaptcha:nil];
	
	return YES;
}

- (void)dealloc {
	[[GoogleAuthManager shared] removeObserver:self forKeyPath:LOGINSTATUS];
	[self.username release];
	[self.password release];
	[self.loginButton release];
	[self.activityIndicator release];
    [super dealloc];
}


@end
