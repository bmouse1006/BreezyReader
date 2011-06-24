//
//  ItemWebView.m
//  SmallReader
//
//  Created by Jin Jin on 10-12-15.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "ItemWebView.h"


@implementation ItemWebView

#pragma mark --
#pragma mark touch event
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	DebugLog(@"touch ended");
	[[self nextResponder] touchesEnded:touches 
							 withEvent:event];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	DebugLog(@"touch began");
	[[self nextResponder] touchesBegan:touches
							 withEvent:event];
}

@end
