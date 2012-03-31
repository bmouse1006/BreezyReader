//
//  GoogleAuthManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAppConstants.h"
#import "UserPreferenceDefine.h"

#define LOGINSTATUS @"loginStatus"

#define AUTHINFOFILE		@"/ReaderAuthInfo.plist"

#define CAPTCHANEEDED @"captchaNeeded"
#define LOGINTOKEN @"loginToken"
#define LOGINCAPTCHA @"loginCaptcha"
#define CAPTCHAURL @"captchaURL"

@interface GoogleAuthManager : NSObject {

	NSString* _username;
	NSString* _password;
	NSString* _loginStatus;
	NSString* _token;
	
	NSMutableDictionary* _authValues;
	
	NSOperationQueue* _operationQueue;
}

@property (copy) NSString* username;
@property (copy) NSString* password;
@property (copy) NSString* token;
@property (retain) NSMutableDictionary* authValues;
@property (copy) NSString* loginStatus;
@property (readonly, getter=returnSID) NSString* SID;
@property (readonly, getter=returnAuth) NSString* Auth;

@property (nonatomic, retain) NSOperationQueue* operationQueue;

+ (GoogleAuthManager*)shared;

-(BOOL)loginForUser:(NSString*)username 
	   withPassword:(NSString*)password 
		 loginToken:(NSString*)loginToken
	   logincaptcha:(NSString*)logincaptcha;

-(void)logout;
-(void)reloginNeeded;

-(BOOL)hasLogin;
-(NSString*)returnSID;
-(NSString*)returnResponseValueForKey:(NSString*)key;
-(NSString*)getValidToken:(NSError **)mError;

-(void)writeAuthInfoToFile;

-(void)asyncLoginForUser:(NSString*)aUsername 
			withPassword:(NSString*)aPassword
			  loginToken:(NSString*)loginToken 
			logincaptcha:(NSString*)logincaptcha;

-(NSMutableURLRequest*)URLRequestFromString:(NSString*)urlString;

//-(NSURLRequest*)authRequestForURL(NSURL*)url;

@end

@interface GoogleAuthManager (private)

-(NSMutableDictionary*)parseResponseMessage:(NSData*)data;
-(void)changeLoginStatusAndSetCookies:(NSMutableDictionary*)response;
-(void)removeCookies;
-(void)saveCookies;
-(BOOL)doWeHaveSIDCookies;
-(void)cleanLoginInfo;
-(void)loginWithToken:(NSString*)loginToken 
		 logincaptcha:(NSString*)logincaptcha;
-(void)initAuthInfo;

@end
