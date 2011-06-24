//
//  UserPreferenceDefine.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceDefine.h"

#define PREFERENCEBUNDLENAME_PHONE	@"ConfigBundle_phone"
#define PREFERENCEBUNDLENAME_PAD	@"ConfigBundle_pad"

#define KEY_AUTOROTATION	@"AutoRotation"
#define KEY_ENABLESSL		@"EnableSSL"
#define KEY_AUTOHIDESUBWITHNOITEM	@"AutoHideForNoItem"
#define KEY_ARTICLEPREVIEW	@"ArticlePreview"
#define KEY_MARKDOWNLOADEDASREAD	@"MarkDownloadedAsRead"
#define KEY_SHOWUNREADFIRST @"ShowUnreadFirst"
#define KEY_TAPTOFULLSCREEN @"TapToFullscreen"

@implementation UserPreferenceDefine

static NSDictionary* preferenceBundle = nil;

+(void)valueChangedForKey:(NSString*)key value:(id)value{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+(void)resetPreference{
	DebugLog(@"use defaults are reseted");
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:KEY_AUTOROTATION];
	[userDefaults removeObjectForKey:KEY_ENABLESSL];
	[userDefaults removeObjectForKey:KEY_AUTOHIDESUBWITHNOITEM];
	[userDefaults removeObjectForKey:KEY_ARTICLEPREVIEW];
	[userDefaults removeObjectForKey:KEY_MARKDOWNLOADEDASREAD];
	[userDefaults removeObjectForKey:KEY_SHOWUNREADFIRST];
}

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	BOOL shouldRotate = (interfaceOrientation == UIDeviceOrientationPortrait);
	
	if ([self iPadMode]){
		shouldRotate = YES;
	}else if ([(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:KEY_AUTOROTATION] boolValue]){
		shouldRotate = (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
	}
	
	return shouldRotate;
}

+(BOOL)shouldAutoHideSubAndTagWithNoNewItems{
	NSString* key = KEY_AUTOHIDESUBWITHNOITEM;
	return [self boolValueForKey:key];
}

+(BOOL)shouldUseSSLConnection{
	NSString* key = KEY_ENABLESSL;
	return [self boolValueForKey:key];
	
}

+(BOOL)markDownloadedItemsAsRead{
	NSString* key = KEY_MARKDOWNLOADEDASREAD;
	return [self boolValueForKey:key];
}

+(BOOL)shouldShowPreviewOfArticle{
	NSString* key = KEY_ARTICLEPREVIEW;
	return [self boolValueForKey:key];
}

+(BOOL)shouldShowUnreadFirst{
	NSString* key = KEY_SHOWUNREADFIRST;
	return [self boolValueForKey:key];
}
		
+(BOOL)shouldTapToFullscreen{
	NSString* key = KEY_TAPTOFULLSCREEN;
	return [self boolValueForKey:key];
}

+(BOOL)boolValueForKey:(NSString*)key{
	NSNumber* value = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (!value){
		value = [self preferenceObjectForKey:key];
	}
	
	return [value boolValue];
}

+(NSUInteger)maxDownloadConcurrency{
	return 1;
}

+(NSUInteger)defaultNumberOfDownloaderItems{
	return [self iPadMode]?13:10;
}

+(NSDictionary*)userPreferenceBundle{
	if (!preferenceBundle){
		
		NSString* bundleName = PREFERENCEBUNDLENAME_PHONE;
		
		if ([self iPadMode]){
			bundleName = PREFERENCEBUNDLENAME_PAD;
		}
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"plist"];
		
		preferenceBundle = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	}
	
	return preferenceBundle;
}

+(id)preferenceObjectForKey:(NSString*)key{
	NSDictionary* preference = [self userPreferenceBundle];
	
	NSEnumerator* enumerator = [preference objectEnumerator];
	
	NSDictionary* section = nil;
	
	NSArray* attributes = nil;
	
	while (section = [enumerator nextObject]) {
		attributes = [section objectForKey:key];
		if (attributes){
			break;
		}
	}
	
	
	if ([attributes count] < 2){
		return nil;
	}
	
	return [attributes objectAtIndex:0];
}

//max image width in item view
+(NSInteger)imageWidth{
	NSInteger width;
	if ([self iPadMode]){
		width = 700;
	}else {
		width = 300;
	}

	return width;
}

+(BOOL)iPadMode{
	
	BOOL iPad = NO;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {      
		iPad = YES;
	}
	
	return iPad;
}

@end
