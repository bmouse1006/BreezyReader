//
//  LoginViewController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController

@synthesize usernameView = _usernameView;
@synthesize passwordView = _passwordView;

@synthesize loginButton = _loginButton;
@synthesize activityIndicator = _activityIndicator;

-(id)init{
	if (self = [super init]){
		[[GoogleAuthManager shared] addObserver:self 
									 forKeyPath:OBSERVEKEYPATH 
										options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
										context:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleCaptcha:) 
													 name:CAPTCHANEEDED 
												   object:nil];
	}
	return self;
}

//handle captcha
-(void)handleCaptcha:(NSNotification*)notification{
//	NSDictionary* userInfo = notification.userInfo;
	
//	NSString* loginToken = [userInfo objectForKey:LOGINTOKEN];
//	NSString* captchaURL = [userInfo objectForKey:CAPTCHAURL];
//	
//	DebugLog(@"login token is %@", loginToken);
//	DebugLog(@"catcha URL is %@", captchaURL);
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
			self.usernameView.enabled = YES;
			self.passwordView.enabled = YES;
			self.loginButton.hidden = NO;
			self.activityIndicator.hidden = YES;
			[self.activityIndicator stopAnimating];
		}
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self localizeViews];
	[self.usernameView becomeFirstResponder];
}

-(void)localizeViews{
	self.usernameView.placeholder = NSLocalizedString(self.usernameView.placeholder, nil);
	self.passwordView.placeholder = NSLocalizedString(self.passwordView.placeholder, nil);
	[self.loginButton setTitle:NSLocalizedString(self.loginButton.currentTitle, nil) 
					  forState:UIControlStateNormal];
	self.loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.loginButton.titleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	if (self.interfaceOrientation != fromInterfaceOrientation){
		if (fromInterfaceOrientation == UIInterfaceOrientationPortrait){//Portrait to landscape
			[UIView beginAnimations:@"login page move up" context:nil];
			CGAffineTransform originalTransform = CGAffineTransformIdentity;
			CGAffineTransform newTransform = CGAffineTransformTranslate(originalTransform, 0, -40);
			self.usernameView.transform = newTransform;
			newTransform = CGAffineTransformTranslate(originalTransform, 0, -50);
			self.passwordView.transform = newTransform;
			newTransform = CGAffineTransformTranslate(originalTransform, 0, -60);
			self.loginButton.transform = newTransform;
			self.activityIndicator.transform = newTransform;
			[UIView commitAnimations];
			//move text field input and button up
		}else if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
				  fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {//landscape to protrait
			//move text field input and button down
			[UIView beginAnimations:@"login page move down" context:nil];		
			NSArray* subViews = [self.view subviews];
			for (UIView* subView in subViews) {
				subView.transform = CGAffineTransformIdentity;
			}	
			[UIView commitAnimations];
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	return [UserPreferenceDefine shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(IBAction)loginButtonTouched{
	[self textFieldShouldReturn:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (self.usernameView.text == nil || [self.usernameView.text isEqualToString:@""]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong input", nil)
														message:NSLocalizedString(@"UserNameIsEmpty", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											  otherButtonTitles:nil];
		[alert show];
        [alert release];
		return NO;
	}
	
	if (self.passwordView.text == nil || [self.passwordView.text isEqualToString:@""]){
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
	self.usernameView.enabled = NO;
	self.passwordView.enabled = NO;
	self.loginButton.hidden = YES;
	self.activityIndicator.hidden = NO;
	[self.activityIndicator startAnimating];
	[[GoogleAuthManager shared] asyncLoginForUser:self.usernameView.text 
									 withPassword:self.passwordView.text 
									   loginToken:nil
									 logincaptcha:nil];

	return YES;
}

-(void)showAlertView{
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


- (void)dealloc {
	[[GoogleAuthManager shared] removeObserver:self forKeyPath:OBSERVEKEYPATH];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:CAPTCHANEEDED
												  object:nil];
	[self.usernameView release];
	[self.passwordView release];
	[self.loginButton release];
	[self.activityIndicator release];
    [super dealloc];
}


@end
