//
//  UserPreferenceTableViewCell.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceTableViewCell.h"


@implementation UserPreferenceTableViewCell

@synthesize key = _key;
@synthesize delegate = _delegate;

-(void)setKeyString:(NSString*)keyStr attributes:(NSArray*)attributes{
	
	self.key = keyStr;
	
	self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.textLabel.text = NSLocalizedString(keyStr, nil);
	self.textLabel.adjustsFontSizeToFitWidth = YES;
	self.textLabel.minimumFontSize = 8.0f;
	self.textLabel.numberOfLines = 2;
	self.accessoryView = [self viewForItem:attributes key:keyStr];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
}


-(UIView*)viewForItem:(NSArray*)itemAttributes key:(NSString*)key{
	
	if ([itemAttributes count] < 2){
		return nil;
	}
	
	id view = nil;
	
	NSNumber* defaultValue = [itemAttributes objectAtIndex:0];
	NSString* viewType = [itemAttributes objectAtIndex:1];	
	
	NSNumber* actualValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	
	if (!actualValue){
		actualValue = defaultValue;
	}
	
	if ([viewType isEqualToString:@"UISwitch"]){
		view = [[[UISwitch alloc] init] autorelease];
		
		[view addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
		
		if ([actualValue intValue]){
			[view setOn:YES animated:NO];
		}else {
			[view setOn:NO	animated:NO];
		}
		
	}else if ([viewType isEqualToString:@"UIPicker"]){
		
	}
	
	return view;
}

-(void)valueChanged:(id)sender{
	[self.delegate valueChangedForKey:self.key sender:sender];
}

-(void)dealloc{
	[self.key release];
	[super dealloc];
}

@end
