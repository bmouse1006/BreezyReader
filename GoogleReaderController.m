//
//  GoogleReaderController.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleReaderController.h"


@implementation GoogleReaderController

@synthesize connectionDataPool;
@synthesize token;
@synthesize errorMsg;
@synthesize delegate;

-(void)testGoogleAPIwithURL:(NSString*)urlString{
	
	NSMutableURLRequest* request = [[GoogleAuthManager shared] URLRequestFromString:urlString];
	
	[self connectWithRequest:request];
}


//delegate method for connection
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	DebugLog(@"did receive response");
}

//delegate method for connection
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//append all data together for one connection
	NSValue* key = [self keyForConnection:connection];
	DebugLog(@"key is %d", key);
	NSMutableData* receivedData = (NSMutableData*)[self.connectionDataPool objectForKey:key];
	DebugLog(@"data address is %d", receivedData);
	if (!receivedData){
		receivedData = [NSMutableData data];
	}
	[receivedData appendData:data];
	[self.connectionDataPool setObject:receivedData forKey:key];

}

//delegate method for connection
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	//remove the connection and from pool if error happens
	NSValue* key = [self keyForConnection:connection];
	[self.connectionDataPool removeObjectForKey:key];
	DebugLog(@"did fail with error");
}

//delegate method for connection
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	//parse loaded data
	NSValue* key = [self keyForConnection:connection];
	[self parseLoadedData:nil];
	//remove the connection and data from pool when finish loading
	[self.connectionDataPool removeObjectForKey:key];
	DebugLog(@"did finish loading");
}

//API here!!

//ATOM API
-(GRFeed*)getFeedForURL:(NSString*)URLString 
				count:(NSNumber*)count 
			startFrom:(NSDate*)date 
			  exclude:(NSString*)excludeString 
		 continuation:(NSString*)continuationStr{
	GRFeed* result = nil;	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];

	NSString* url = [URI_PREFIXE_ATOM stringByAppendingString:ATOM_GET_FEED];
	url = [url stringByAppendingString:URLString];
	result = (GRFeed*)[self readDataFromGoogleReader:url
									withParameters:parameterSet
											parser:@selector(ATOMParser:) 
										   APIType:API_ATOM];
	return result;
}

-(GRFeed*)getFeedForLabel:(NSString*)labelName				
				  count:(NSNumber*)count 
			  startFrom:(NSDate*)date 
				exclude:(NSString*)excludeString 
		   continuation:(NSString*)continuationStr{
	
	GRFeed* result = nil;	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [URI_PREFIXE_ATOM stringByAppendingString:ATOM_PREFIXE_LABEL];
	url = [url stringByAppendingString:labelName];
	result = (GRFeed*)[self readDataFromGoogleReader:url
									withParameters:parameterSet
											parser:@selector(ATOMParser:) 
										   APIType:API_ATOM];
	return result;
}

-(GRFeed*)getFeedForStates:(NSString*)state
				   count:(NSNumber*)count 
			   startFrom:(NSDate*)date 
				 exclude:(NSString*)excludeString 
			continuation:(NSString*)continuationStr{
	GRFeed* result = nil;	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [URI_PREFIXE_ATOM stringByAppendingString:state];
	result = (GRFeed*)[self readDataFromGoogleReader:url
									withParameters:parameterSet
											parser:@selector(ATOMParser:) 
										   APIType:API_ATOM];
	return result;
}

-(GRFeed*)getFeedForID:(NSString*)ID
				 count:(NSNumber*)count
			 startFrom:(NSDate*)date 
			   exclude:(NSString*)excludeString 
		  continuation:(NSString*)continuationStr{
	
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
	
	NSString* url = [URI_PREFIXE_ATOM stringByAppendingString:ID];
	GRFeed* result = (GRFeed*)[self readDataFromGoogleReader:url
									  withParameters:parameterSet
											  parser:@selector(ATOMParser:) 
											 APIType:API_ATOM];
	return [[result retain] autorelease];
	
}

//LIST API, return nil if fail
-(NSDictionary*)allRecommendationFeeds{
	NSDictionary* result = nil;	
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_LIST_RECOMMENDATION];
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:ATOM_ARGS_COUNT withValue:@"99999"];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
	result = (NSDictionary*)[self readDataFromGoogleReader:url
											withParameters:paramSet
													parser:@selector(JSONParser:) 
												   APIType:API_LIST];
	[paramSet release];
	return result;
}

-(NSDictionary*)allSubscriptions{
	
	NSDictionary* result = nil;	
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_LIST_SUBSCRIPTION];
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
	result = (NSDictionary*)[self readDataFromGoogleReader:url
											withParameters:paramSet
													parser:@selector(JSONParser:) 
												   APIType:API_LIST];
	[paramSet release];
	return result;
}

//return all tags
-(NSDictionary*)allTags{
	
	NSDictionary* result = nil;
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_LIST_TAG];
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
	result = (NSDictionary*)[self readDataFromGoogleReader:url
											withParameters:paramSet
													parser:@selector(JSONParser:) 
												   APIType:API_LIST];
	[paramSet release];
	return result;
}

//return unread cound for all subscription and tags
-(NSDictionary*)unreadCount{
	
	NSDictionary* result = nil;
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_LIST_UNREAD_COUNT];
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:@"output" withValue:@"json"];
	result = (NSDictionary*)[self readDataFromGoogleReader:url
											withParameters:paramSet
													parser:@selector(JSONParser:) 
												   APIType:API_LIST];
	[paramSet release];
	return result;
}

//add a new subscription to Google reader
//return "ok" for success, return "" or nil for fail
-(NSString*)addSubscription:(NSString*)subscription 
				  withTitle:(NSString*)title 
					  toTag:(NSString*)tag{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	NSString* feedName = subscription;
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	if (feedName){
		[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:feedName];//add feed URI
	}
	if (title){
		[paramSet setParameterForKey:EDIT_ARGS_TITLE withValue:title];//add feed title
	}
	if (tag){
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tag];//add tag name
	}

	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"subscribe"];//add API action. Here is 'subscribe'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;
}

//mark all as read for a subscription
-(NSString*)markAllAsReadForSubscription:(NSString*)subscription{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_MARK_ALL_AS_READ];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
//	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"unsubscribe"];//add API action. Here is 'unsubscribe'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;	
}

//remove a subscription from Google Reader
//return "ok" for successs, "" or nil for fail
-(NSString*)removeSubscription:(NSString*)subscription{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"unsubscribe"];//add API action. Here is 'unsubscribe'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;

}

//edit tag name for one subsctiption, add and remove
//return "ok" for successs, "" or nil for fail
-(NSString*)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
	if (tagToAdd != nil)
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
	if (tagToRemove != nil)
		[paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];//tag name to remove
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"edit"];//add API action. Here is 'edit'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;
}

//make this tag public
-(NSString*)editTag:(NSString*)tagName 
		publicOrNot:(BOOL)pub{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_TAG1];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:tagName];//add feed URI
	
	NSString* pubValue = nil;
	if (pub)
		pubValue = @"true";
	else {
		pubValue = @"false";
	}

	[paramSet setParameterForKey:EDIT_ARGS_PUBLIC withValue:pubValue];//make it public or not
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;
}

//to disable(remove) a tag
-(NSString*)disableTag:(NSString*)tagName{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_DISABLETAG];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:tagName];//add feed URI
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"disable-tags"];//add API action. Here is 'unsubscribe'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;
}

//add and/or remove tags for one item
-(NSString*)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove{
	//get complete feed URI in Google Reader
	NSString* url = [URI_PREFIXE_API stringByAppendingString:API_EDIT_TAG2];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:EDIT_ARGS_ITEM withValue:itemID];//add feed URI
	if (tagToAdd != nil)
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
	if (tagToRemove != nil)
		[paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];//tag name to remove
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"edit"];//add API action. Here is 'edit'
	
	NSString* result = (NSString*)[self readDataFromGoogleReader:url
												  withParameters:paramSet
														  parser:@selector(EDITParser:) 
														 APIType:API_EDIT];
	
	[paramSet release];
	return result;
}


//init and alloc
-(id)initWithDelegate:(id<GoogleReaderControllerDelegate>)_delegate{
	if (self = [super init]){
		NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
		self.connectionDataPool = dictionary;
		[dictionary release];
		self.delegate = _delegate;
	}
	return self;
}

-(void)dealloc{
	[connectionDataPool release];
	[super dealloc];
}

/////Private method

-(void)connectWithRequest:(NSURLRequest*)request{
	NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
	NSValue* key = [self keyForConnection:connection];
	[self.connectionDataPool setObject:[NSMutableData data] forKey:key];
}

-(void)parseLoadedData:(NSData*)data{
	NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	DebugLog(@"received data is: %@", str);
	//parse code here
	//
	//
	[str release];
}

-(NSValue*)keyForConnection:(NSURLConnection*)connection{
	return [NSValue valueWithNonretainedObject:connection];
}

-(BOOL)getValidToken{
	
	BOOL result = FALSE;
	
	NSError* error = nil;
	
	NSString* _token = [[GoogleAuthManager shared] getValidToken:&error];
	
	if (!error){
		self.token = _token;
		result = TRUE;
		[self.delegate didSuccessFinishedDataReceive:nil];
	}else {
		self.token = nil;
		self.errorMsg = ERROR_NETWORKFAILED;
		[self.delegate didReceiveErrorWhileRequestingData:error];
	}
	
	return result;
}

//the most important communicate method
-(id)readDataFromGoogleReader:(NSString*)urlString 
			   withParameters:(URLParameterSet*)parameters 
					   parser:(SEL)_parser
					  APIType:(NSString*)type{
	
	NSMutableURLRequest* request = [[GoogleAuthManager shared] URLRequestFromString:urlString];
	id result = nil;
	
	int retry = 0;
	do{
			
		if ([type isEqual:API_EDIT]){
			if (self.token == nil && ![self getValidToken]){
				//token is empty and get token failed, then return nil
				return nil;
			}
			[parameters setParameterForKey:EDIT_ARGS_TOKEN withValue:self.token];
			[request setHTTPMethod:@"POST"];//POST method for list api
			[request setHTTPBody:[[parameters parameterString] dataUsingEncoding:NSUTF8StringEncoding]];
			URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
			
			if (!retry){
				[additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
				[additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
				
				NSString* temp = [request.URL absoluteString];
				temp = [temp stringByAppendingString:@"?"];
				temp = [temp stringByAppendingString:[additionalParameters parameterString]];
				[request setURL:[NSURL URLWithString:temp]];
				 
				[additionalParameters release];
			}
		}else {
			[request setHTTPMethod:@"GET"];//GET method for others
			if (!retry){
				NSString* temp = [request.URL absoluteString];
				if (parameters){
					temp = [temp stringByAppendingString:@"?"];
					temp = [temp stringByAppendingString:[parameters parameterString]];
				}
				[request setURL:[NSURL URLWithString:temp]];
			}
		}
		
		DebugLog(@"url str is %@", [request.URL absoluteString]);
		
		UIApplication* app = [UIApplication sharedApplication]; 
		app.networkActivityIndicatorVisible = YES; // start network activity indicator
		
		NSError* error = nil;
		NSURLResponse* response = nil;
		
		NSData* returningData = [NSURLConnection sendSynchronousRequest:request
													  returningResponse:&response 
																  error:&error];
		
		app.networkActivityIndicatorVisible = NO; // stop network activity indicator
		
		if (error){
//			[self notifyError:error withResponse:response];
			[self.delegate didReceiveErrorWhileRequestingData:error];
			return nil;
		}
		[self.delegate didSuccessFinishedDataReceive:response];
		result = [self performSelector:_parser withObject:returningData];
		[[result retain] autorelease];
		if (result != nil){
			return result;
		}
		
		if ([type isEqual:API_EDIT]){
			retry++;
			//重新获取token
			[self getValidToken];
		}else {
			self.errorMsg = ERROR_NOLOGIN;
			return nil;
		}
	}while(retry<=1);

	self.errorMsg = ERROR_UNKNOWN;
	return nil;
}

-(id)EDITParser:(NSData*)source{
	return [GoogleMessageParsers EDITParser:source];
}

-(id)JSONParser:(NSData*)source{
	return [GoogleMessageParsers JSONParser:source];
}

-(id)ATOMParser:(NSData*)source{
	return [GoogleMessageParsers ATOMParser:source];
}

-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
								   continuation:(NSString*)continuationStr{
	URLParameterSet* parameterSet = nil;
	
	if (count||date||excludeString||continuationStr){
		parameterSet = [[[URLParameterSet alloc] init] autorelease];
		if (count)
			[parameterSet setParameterForKey:ATOM_ARGS_COUNT withValue:[count stringValue]];
		if (date)
			[parameterSet setParameterForKey:ATOM_ARGS_START_TIME withValue:[NSString stringWithFormat:@"%d", [date timeIntervalSince1970]]];
		if (excludeString)
			[parameterSet setParameterForKey:ATOM_ARGS_EXCLUDE_TARGET withValue:excludeString];
		if (continuationStr)
			[parameterSet setParameterForKey:ATOM_ARGS_CONTINUATION withValue:continuationStr];
	}
	
	return parameterSet;
}


-(void)notifyError:(NSError*)error withResponse:(NSURLResponse*)response{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ERROR_UNKNOWN object:nil userInfo:nil];
	
	NSArray* keys = [error.userInfo allKeys];
	for (NSString* key in keys){
		DebugLog(@"error key: %@", key);
		DebugLog(@"error value: %@", [error.userInfo objectForKey:key]);
	}
	
}

@end
						
						
