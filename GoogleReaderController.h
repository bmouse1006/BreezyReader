//
//  GoogleAPPCommunicator.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAuthManager.h"
#import	"GoogleMessageParsers.h"
#import "URLParameterSet.h"
#import "GRFeed.h"
#import "JSON.h"

#define RECEIVED_DATA @"receivedData"

@protocol GoogleReaderControllerDelegate

-(void)didReceiveErrorWhileRequestingData:(NSError*)error;
-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response;

@end

@interface GoogleReaderController : NSObject{
	
	NSMutableDictionary* connectionDataPool;
	NSString* token;
	NSString* errorMsg;
	
	id<GoogleReaderControllerDelegate> delegate;

}

@property (retain) NSMutableDictionary* connectionDataPool;
@property (retain) NSString* token;
@property (retain) NSString* errorMsg;
@property (assign) id<GoogleReaderControllerDelegate> delegate;


//Google Reader interface
//ATOM API, return nil if fail
-(GRFeed*)getFeedForURL:(NSString*)URLString 
				count:(NSNumber*)count 
			startFrom:(NSDate*)date 
			  exclude:(NSString*)excludeString 
		 continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForLabel:(NSString*)labelName
				  count:(NSNumber*)count 
			  startFrom:(NSDate*)date 
				exclude:(NSString*)excludeString 
		   continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForStates:(NSString*)state
				   count:(NSNumber*)count 
			   startFrom:(NSDate*)date 
				 exclude:(NSString*)excludeString 
			continuation:(NSString*)continuationStr;

-(GRFeed*)getFeedForID:(NSString*)ID
				 count:(NSNumber*)count
			 startFrom:(NSDate*)date 
			   exclude:(NSString*)excludeString 
		  continuation:(NSString*)continuationStr;

//EDIT API, return nil if fail
//subscribe a feed with title and tag name
-(NSString*)addSubscription:(NSString*)subscription 
				  withTitle:(NSString*)title 
					  toTag:(NSString*)tags;

//unsubscribe a feed
-(NSString*)removeSubscription:(NSString*)subscription;

//mark all as read for a subscription
-(NSString*)markAllAsReadForSubscription:(NSString*)subscription;

//add/remove tag to one subscription
-(NSString*)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove;

//make a tag public or not
-(NSString*)editTag:(NSString*)tagName 
		publicOrNot:(BOOL)pub;

//disable a tag
-(NSString*)disableTag:(NSString*)tagName;

//change tag/states set for one specific item. Use this to mark item as read/unread
-(NSString*)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove;

//LIST API, return nil if fail
-(NSDictionary*)allRecommendationFeeds;
-(NSDictionary*)allSubscriptions;
-(NSDictionary*)allTags;
-(NSDictionary*)unreadCount;
//API



-(void)testGoogleAPIwithURL:(NSString*)urlString;


-(id)initWithDelegate:(id<GoogleReaderControllerDelegate>)_delegate;

@end

@interface GoogleReaderController (private)

-(void)connectWithRequest:(NSURLRequest*)request;
-(void)parseLoadedData:(NSData*)data;
-(NSValue*)keyForConnection:(NSURLConnection*)connection;

-(BOOL)getValidToken;

-(id)readDataFromGoogleReader:(NSString*)urlString 
			   withParameters:(URLParameterSet*)parameters 
					   parser:(SEL)parser 
					  APIType:(NSString*)type;
-(NSMutableURLRequest*)addCookiesToURLRequest:(NSMutableURLRequest*)request;

-(NSDictionary*)JSONParser:(NSData*)source;//parser for JSON message
-(NSString*)EDITParser:(NSData*)source;//Parser for Edit return message

-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
								   continuation:(NSString*)continuationStr;


-(NSMutableURLRequest*)URLRequestFromString:(NSString*)str;
-(void)notifyError:(NSError*)error withResponse:(NSURLResponse*)response;

@end


