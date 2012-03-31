//
//  GoogleMessageParsers.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleMessageParsers.h"

@implementation GoogleMessageParsers

//Parser for JSON message
+(NSDictionary*)JSONParser:(NSData*)source{
	NSString * sourceStr = [[NSString alloc] initWithData:source 
												  encoding:NSUTF8StringEncoding];
	NSDictionary* JSONDic = (NSDictionary*)[sourceStr JSONValue];
	DebugLog(@"sourceStr is %@", sourceStr);
	[sourceStr release];
//	[GoogleMessageParsers printJSONObject:JSONDic level:0];
	[[JSONDic retain] autorelease];
	return JSONDic;
}

//Parser for EDIT response message
+(NSString*)EDITParser:(NSData*)source{
	NSString * sourceStr = [[[NSString alloc] initWithData:source 
												  encoding:NSUTF8StringEncoding] autorelease];
	NSString* result = nil;
	DebugLog(@"return result is %@", sourceStr);
	if ([[sourceStr lowercaseString] isEqual:@"ok"])
		result = [sourceStr lowercaseString];
	[[result retain] autorelease];
	return result;
}

//Parser for ATOM response message
+(id)ATOMParser:(NSData*)source{
//	GRATOMXMLParser* parser = [[GRATOMXMLParser alloc] initWithXMLData:source];
	GRATOMXMLParser_new* parser = [[GRATOMXMLParser_new alloc] initWithXMLData:source];
	id result = [parser parse];
	[parser release];
	
	[[result retain] autorelease];
	
	return result;
}

+(void)printJSONObject:(NSDictionary*)JSONObject level:(int)l{
	NSArray* keys = [JSONObject allKeys];
	
	for(NSObject* key in keys){
		NSObject* value = [JSONObject objectForKey:key];
		if (![value isKindOfClass:[NSArray class]]){
			NSMutableString* str = [[NSMutableString alloc] init];
			for(int i = 0;i<l;i++){
				[str appendString:@"   "];
			}
			[str appendString:(NSString*)key];
			[str appendString:@": "];
			if ([value isKindOfClass:[NSString class]]){
				[str appendString:(NSString*)value];
			}
			if ([value isKindOfClass:[NSNumber class]]){
				[str appendString:[(NSNumber*)value stringValue]];
			}
			DebugLog(@"%@", (NSString*)str);
			[str release];
		}else {
			for (NSObject* subKey in (NSArray*)value){
				DebugLog(@"this key is: %@", key);
				[self printJSONObject:(NSDictionary*)subKey level:l+1];
			}
		}
	}
	DebugLog(@"\n");
}

@end
