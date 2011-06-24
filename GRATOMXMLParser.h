//
//  GRATOMXMLParser.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRFeed.h"
#import "GRItem.h"

@interface GRATOMXMLParser : NSObject<NSXMLParserDelegate> {
	
	NSData* _XMLSource;
	NSMutableString* _currentParsedCharacterData;
	
	GRFeed*	_parsedFeed;
	GRItem*	_currentEntry;

	BOOL accumulatingParsedCharacterData;
	BOOL feedLevel;
	BOOL entryLevel;
	BOOL sourceLevel;
	
	NSDateFormatter* _dateFormatter;
	
}

@property (nonatomic, retain) NSData* XMLSource;
@property (nonatomic, retain) GRItem* currentEntry;
@property (nonatomic, retain) GRFeed*	parsedFeed;
@property (nonatomic, retain) NSMutableString* currentParsedCharacterData;

@property (nonatomic, retain) NSDateFormatter* dateFormatter;

-(id)initWithXMLData:(NSData*)data;

-(id)parse;

@end
