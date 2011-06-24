//
//  GRRecFeed.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-3.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"

@interface GRRecFeed : NSObject<GRBaseProtocol> {
	NSString* _title;
	NSString* _snippet;
	NSString* _streamID;
	NSString* _impressionTime;
	
	BOOL isSucscribing;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* snippet;
@property (nonatomic, retain) NSString* streamID;
@property (nonatomic, retain) NSString* impressionTime;

@property (nonatomic, assign) BOOL isSucscribing;

+(GRRecFeed*)recFeedsWithJSONObject:(NSDictionary*)JSONObj;

@end
