//
//  UserPreferenceDataSouce.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceDataSouce.h"
#import "UserPreferenceDefine.h"

@implementation UserPreferenceDataSouce

@synthesize userPreferenceBundle = _userPreferenceBundle;
@synthesize itemsForPreference = _itemsForPreference;
@synthesize bundleName = _bundleName;

-(id)init{

	if (self = [super init]){
		
		self.userPreferenceBundle = [UserPreferenceDefine userPreferenceBundle];
		
		self.itemsForPreference = [NSMutableDictionary dictionaryWithCapacity:0];
	}
	
	return self;
}

-(void)dealloc{
	[self.userPreferenceBundle release];
	[self.bundleName release];
	[self.itemsForPreference release];
	[super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return [self.userPreferenceBundle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSArray* keys = [self.userPreferenceBundle allKeys];
	
	NSDictionary* theSection = [self.userPreferenceBundle objectForKey:[keys objectAtIndex:section]];
	return [theSection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSArray* keys = [self.userPreferenceBundle allKeys];
	NSString* keyName = [keys objectAtIndex:section];
	return NSLocalizedString(keyName, nil);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
	
    static NSString *CellIdentifier = @"FeedCell";
	
	UserPreferenceTableViewCell* cell = (UserPreferenceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil){
		cell = [[[UserPreferenceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSArray* sectionKeys = [self.userPreferenceBundle allKeys];
	NSDictionary* theSection = [self.userPreferenceBundle objectForKey:[sectionKeys objectAtIndex:[indexPath section]]];
	
	NSArray* rowKeys = [theSection allKeys];
	NSString* key = [rowKeys objectAtIndex:indexPath.row];
	
	cell.delegate = self;
	[cell setKeyString:key attributes:[theSection objectForKey:key]];
	
	return cell;
}

-(void)valueChangedForKey:(NSString*)key sender:(id)sender{
	DebugLog(@"%@ is changed", key);
	
	NSNumber* value = nil;
	
	if ([sender isKindOfClass:[UISwitch class]]){
		UISwitch* theSwitch = (UISwitch*)sender;
		value = [NSNumber numberWithBool:theSwitch.on];
	}
	
	if (value){
		[UserPreferenceDefine valueChangedForKey:key
												  value:value];
	}
}

@end
