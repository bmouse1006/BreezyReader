//
//  GoogleAuthManager.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleAuthManager.h"

#define USERNAME @"username"
#define PASSWORD @"password"
#define LOGINTOKEN @"loginToken"
#define LOGINCAPTCHA @"loginCaptcha"

@implementation GoogleAuthManager

@synthesize username = _username;
@synthesize password = _password;
@synthesize authValues = _authValues;
@synthesize loginStatus = _loginStatus;
@synthesize token = _token;

@synthesize operationQueue = _operationQueue;

static GoogleAuthManager *shareAuthManager = nil;

-(void)reloginNeeded{
	[self logout];
	NSNotification* notification = [NSNotification notificationWithName:LOGINFAILED object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(NSMutableURLRequest*)addCookiesToURLRequest:(NSMutableURLRequest*)request{
	NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies != nil){
		[request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	}
	return request;
}

-(NSMutableURLRequest*)URLRequestFromString:(NSString*)urlString{
	//encode URL string
	NSString* googleScheme = nil;
	BOOL enableSSL = [UserPreferenceDefine shouldUseSSLConnection];
	if (enableSSL){
		googleScheme = GOOGLE_SCHEME_SSL;
	}else {
		googleScheme = GOOGLE_SCHEME;
	}

	NSString* encodedURLString = [googleScheme stringByAppendingString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	DebugLog(@"encoded URL String is %@", encodedURLString);
	//构造request
	NSURL* url = [NSURL URLWithString:encodedURLString];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	//get auth
	NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	NSString* authStr = nil;
	for (NSHTTPCookie* cookie in cookies){
		if ([cookie.name isEqualToString:COOKIE_AUTH]){
			authStr = cookie.value;
			break;
		}
	}
	NSString *authorizationHeader = [NSString stringWithFormat:@"GoogleLogin auth=%@", authStr];
	[request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
	[request setValue:@"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)" 
   forHTTPHeaderField:@"user-agent"];
	//add cookies
	request = [self addCookiesToURLRequest:request];
	DebugLog(@"%@", [request.allHTTPHeaderFields description]);
	
	return [[request retain] autorelease];
}

-(void)writeAuthInfoToFile{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return;
	}
	NSString *thePath = [documentsDirectory stringByAppendingString:AUTHINFOFILE];
	[self.authValues writeToFile:thePath atomically:YES];
}

-(void)initAuthInfo{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return;
	}
	NSString *thePath = [documentsDirectory stringByAppendingString:AUTHINFOFILE];
	self.authValues = [NSMutableDictionary dictionaryWithContentsOfFile:thePath];
	if (!self.authValues){
		self.authValues = [NSMutableDictionary dictionaryWithCapacity:0];
	}
}

-(void)logout{
	[self cleanLoginInfo];
	self.loginStatus = LOGIN_NOTIN;
}

-(void)asyncLoginForUser:(NSString*)aUsername 
			withPassword:(NSString*)aPassword
			  loginToken:(NSString*)loginToken 
			logincaptcha:(NSString*)logincaptcha{
	
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:aUsername, USERNAME ,aPassword, PASSWORD, nil];
	
	if (loginToken){
		[userInfo setObject:loginToken forKey:LOGINTOKEN];
	}
	
	if (logincaptcha){
		[userInfo setObject:logincaptcha forKey:LOGINCAPTCHA];
	}
	
	
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(asyncLoginForUserTask:) object:userInfo];
	[self.operationQueue addOperation:operation];
	[operation release];
}

-(void)asyncLoginForUserTask:(NSDictionary*)userInfo{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSString* user = [userInfo objectForKey:USERNAME];
	NSString* passwd = [userInfo objectForKey:PASSWORD];
	NSString* loginToken = [userInfo objectForKey:LOGINTOKEN];
	NSString* logincaptcha = [userInfo objectForKey:LOGINCAPTCHA];
	[[GoogleAuthManager shared] loginForUser:user 
								withPassword:passwd 
								  loginToken:loginToken 
								logincaptcha:logincaptcha];
	[pool release];
}

-(BOOL)loginForUser:(NSString*)aUsername 
	   withPassword:(NSString*)aPassword 
		 loginToken:(NSString*)loginToken
	   logincaptcha:(NSString*)logincaptcha{

	@synchronized(_loginStatus){
		//if login status is failed. clean it first
//		if ([LOGIN_FAILED isEqualToString:self.loginStatus])
//			[self cleanLoginInfo];

//		//if it's not a new user
//		if ([aUsername isEqualToString:self.username]){
//			//Do we have cookies?
//			if ([self doWeHaveSIDCookies]){
//				if (![LOGIN_SUCCESSFUL isEqualToString:self.loginStatus])
//					self.loginStatus = LOGIN_SUCCESSFUL;
//				return TRUE;
//			}	
//		}
		self.username = aUsername;
		self.password = aPassword;

		[self cleanLoginInfo];
		self.loginStatus = LOGIN_NOTIN;
		[self loginWithToken:loginToken 
				logincaptcha:logincaptcha];
	}
	return ([LOGIN_SUCCESSFUL isEqualToString:self.loginStatus])?YES:NO;
}


-(void)didReceiveData:(NSData *)data{

	self.authValues = [self parseResponseMessage:data];
	[self changeLoginStatusAndSetCookies:self.authValues];

}

-(void)didFail{
	DebugLog(@"did fail with error");
	[self.authValues setObject:@"Network connection error" forKey:@"Error"];
	self.loginStatus = LOGIN_FAILED;
}

-(void)connectionDidFinishLoading{
	DebugLog(@"did finish loading");
}

-(NSMutableDictionary*)parseResponseMessage:(NSData*)data{
	/*sample response messages. First one is a success response. Second is a failure response. We only take care of the body
	 
	 HTTP/1.0 200 OK
	 Server: GFE/1.3
	 Content-Type: text/plain 
	 
	 SID=DQAAAGgA...7Zg8CTN
	 LSID=DQAAAGsA...lk8BBbG
	 Auth=DQAAAGgA...dk3fA5N
	 
	 ~~~~~~~~~
	 
	 HTTP/1.0 403 Access Forbidden
	 Server: GFE/1.3
	 Content-Type: text/plain
	 
	 Url=http://www.google.com/login/captcha
	 Error=CaptchaRequired
	 CaptchaToken=DQAAAGgA...dkI1LK9
	 CaptchaUrl=Captcha?ctoken=HiteT4b0Bk5Xg18_AcVoP6-yFkHPibe7O9EqxeiI7lUSN
	 
	 ～～～～～～
	 need to deal with message in other format
	 */
	[data retain];
	NSMutableDictionary* tempDic = [[[NSMutableDictionary alloc] init] autorelease];
	
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];	
	DebugLog(@"return string is %@", str);
	//get array of lines
	NSArray* lines = [str componentsSeparatedByString:@"\n"];

	for (NSString* currLine in lines){
		//store key and value, which are seperated by '=', to a dictionary
		NSMutableString* mutableLine = [NSMutableString stringWithString:currLine];
		NSRange range = [currLine rangeOfString:@"="];
		if (range.location != NSNotFound){
			NSString* key = [currLine substringToIndex:range.location];
			[mutableLine deleteCharactersInRange:[currLine rangeOfString:[key stringByAppendingString:@"="]]];
			[tempDic setObject:mutableLine forKey:key];
		}						   
	}
	[str release];
	[data release];
	return tempDic;
}

-(void)cleanLoginInfo{
	//remove auth values and cookies
	[self.authValues removeAllObjects];
	[self removeCookies];
}

//change the login status according to the response parsed auth Value
-(void)changeLoginStatusAndSetCookies:(NSMutableDictionary*)response{
	NSString* errorMessage = [response objectForKey:@"Error"];
	NSString* returnSID = [response objectForKey:@"SID"];
	NSString* returnAuth = [response objectForKey:@"Auth"];
	NSString* aptchaToken = [response objectForKey:@"CaptchaToken"];
	NSString* aptchaURL = [response objectForKey:@"CaptchaUrl"];
	
	if (errorMessage != nil || returnSID == nil || returnAuth == nil){
		//login with error. clean sid infor
		if ([errorMessage isEqualToString:@"CaptchaRequired"]){//required captcha
			//send out notification to process captcha
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aptchaToken, LOGINTOKEN, aptchaURL, CAPTCHAURL, nil];
			NSNotification* notificatoin = [NSNotification notificationWithName:CAPTCHANEEDED object:nil userInfo:userInfo];
			
			[[NSNotificationCenter defaultCenter] postNotification:notificatoin];
			
		}else{
			[self removeCookies];
			self.loginStatus = LOGIN_FAILED;
		}
	}
	else {
		[self saveCookies];
		self.loginStatus = LOGIN_SUCCESSFUL;
	}

}


-(void)removeCookies{
	//remove cookie
	NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (NSHTTPCookie* tempCookie in cookies){
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:tempCookie];
	}
	DebugLog(@"Cookies removed");
}

-(void)saveCookies{
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	NSArray* keys = [self.authValues allKeys];
	for (NSString* key in keys){
		NSString* value = [self.authValues objectForKey:key];
		NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
									key, NSHTTPCookieName, 
									COOKIE_DOMAIN, NSHTTPCookieDomain, 
									COOKIE_PATH, NSHTTPCookiePath, 
									[NSDate dateWithTimeIntervalSinceNow:1296000], NSHTTPCookieExpires, 
									value, NSHTTPCookieValue,
									nil];
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:properties]];
	}
	
	DebugLog(@"Cookies saved");
}

-(BOOL)doWeHaveSIDCookies{
	BOOL returnValue = NO;
	NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for(NSHTTPCookie* cookie in cookies){
		if ([[cookie name] isEqualToString:COOKIE_SID]){
			NSDate* today = [NSDate date];
			NSDate* expiresDate = [cookie expiresDate];
			if ([today compare:expiresDate] == NSOrderedDescending){//Cookie expired
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
				returnValue = NO;
			}else {
				returnValue = YES;
			}
			break;
		}
	}
	return returnValue;
}

-(void)loginWithToken:(NSString*)loginToken 
		 logincaptcha:(NSString*)logincaptcha{
	
	NSURL* url = [NSURL URLWithString:URI_LOGIN];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	
	NSString* bodyString = [NSString stringWithFormat:LOGIN_REQUEST_BODY_STRING, 
							self.username, self.password];
	
	if (loginToken && logincaptcha){
		bodyString = [bodyString stringByAppendingFormat:LOGIN_TOKEN_STRING, loginToken, logincaptcha];
	}
	
	NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
	
	/*Sample POST message
	 POST /accounts/ClientLogin HTTP/1.0
	 Content-type: application/x-www-form-urlencoded
	 
	 accountType=HOSTED_OR_GOOGLE&Email=jondoe@gmail.com&Passwd=north23AZ&service=cl&
	 source=Gulp-CalGulp-1.05
	 */
	
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:bodyData];
	
	self.loginStatus = LOGIN_INPROGRESS;

	NSURLResponse* response = nil;
	
	UIApplication* app = [UIApplication sharedApplication]; 
	app.networkActivityIndicatorVisible = YES; // to stop it, set this to NO
	
	NSError* error = nil;
	NSData* resultData = [NSURLConnection sendSynchronousRequest:request 
												 returningResponse:&response 
															 error:&error];
	
	app.networkActivityIndicatorVisible = NO; // to stop it, set this to NO

	if (error){
		[self didFail];
	}else {
		[self didReceiveData:resultData];
	}

}

//return SID, LSID, and AUTH according to login status
-(NSString*)returnSID{
	NSString* tempSID = nil;
	if ([LOGIN_SUCCESSFUL isEqualToString:self.loginStatus])
		tempSID = [self returnResponseValueForKey:@"SID"];
	return tempSID;
};

-(NSString*)returnAuth{
	NSString* tempAuth = nil;
	if ([LOGIN_SUCCESSFUL isEqualToString:self.loginStatus])
		tempAuth = [self returnResponseValueForKey:@"Auth"];
	return tempAuth;
}

-(NSString*)returnResponseValueForKey:(NSString*)key{
	NSString* tempKey = nil;
	tempKey = (NSString*)[self.authValues objectForKey:key];
	return tempKey;
}

-(NSString*)getValidToken:(NSError **)mError{
	@synchronized(_token){
		if (!self.token){
			NSError* error = nil;
			
			NSString* urlString = [URI_PREFIXE_API stringByAppendingString:API_TOKEN];
			NSURLRequest* request = [self URLRequestFromString:urlString];
			
			NSData* data = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:nil 
															 error:&error];
			
			if (error){//error happened
				if (mError){
					*mError = error;
					[[*mError retain] autorelease];
				}
				return nil;
			}
			NSString* tempToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			
			DebugLog(@"token is %@", tempToken);
			
			if (tempToken != nil && [tempToken length] <= 57){
//				self.token = tempToken;
				self.token = [tempToken substringFromIndex:2];
			}else {
				self.token = nil;
			}
			
			[tempToken release];
		}
	}
	
	return self.token;
}

-(BOOL)hasLogin{
	return [self doWeHaveSIDCookies];
}

//task for update token every 5 minutes
-(void)taskUpdateToken{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DebugLog(@"timer is running");
	NSError* error = nil;
	self.token = nil;
	[self getValidToken:&error];
	//NSString* urlString = [URI_PREFIXE_API stringByAppendingString:API_TOKEN];
//	NSURLRequest* request = [self URLRequestFromString:urlString];
//	
//	NSData* data = [NSURLConnection sendSynchronousRequest:request 
//										 returningResponse:nil 
//													 error:&error];
//	
//	if (error){//error happened
//		[pool release];
//		self.token = nil;
//	}
//	
//	NSString* tempToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//	self.token = tempToken;
//	[tempToken release];
	DebugLog(@"timer is finished");
	[pool release];
}

-(void)updateToken{
	NSInvocationOperation* opertaion =  [[NSInvocationOperation alloc] initWithTarget:self
																			 selector:@selector(taskUpdateToken) 
																			   object:nil];
	NSOperationQueue* queue = [[NSOperationQueue alloc] init];
	[queue addOperation:opertaion];
	[opertaion release];
	[queue release];
}

-(id)init{
	@synchronized(self){
		if (self = [super init]){
			self.authValues = [NSMutableDictionary dictionaryWithCapacity:0];
			NSOperationQueue* tempQueue = [[NSOperationQueue alloc] init];
			self.operationQueue = tempQueue;
			[tempQueue release];
			self.loginStatus = LOGIN_NOTIN;
			[NSTimer scheduledTimerWithTimeInterval:300
											 target:self
										   selector:@selector(updateToken)
										   userInfo:nil
											repeats:YES];
		}
	}
	return self;
}

-(void)dealloc{
	[self.username release];
	[self.password release];
	[self.token release];
	[self.authValues release];
	[self.operationQueue release];
	[super dealloc];
}

+ (GoogleAuthManager*)shared
{
    if (shareAuthManager == nil) {
        shareAuthManager = [[super allocWithZone:NULL] init];
    }
    return shareAuthManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self shared] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    return;
    //do nothing
}

- (id)autorelease
{
    return self;
}
@end
