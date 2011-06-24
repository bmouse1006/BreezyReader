//
//  URLParameterSet.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLParameterSet : NSObject {
	
	NSMutableDictionary* _parameters;
}

@property (nonatomic, retain) NSMutableDictionary* parameters;

-(NSString*)parameterString;

-(void)setParameterForKey:(NSString*)key withValue:(NSObject*)value;

@end
