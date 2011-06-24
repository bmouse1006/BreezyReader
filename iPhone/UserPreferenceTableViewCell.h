//
//  UserPreferenceTableViewCell.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserPreferenceTableViewCellDelegate

@required

-(void)valueChangedForKey:(NSString*)key sender:(id)sender;

@end

@interface UserPreferenceTableViewCell : UITableViewCell {
	NSString* _key;
	
	id<UserPreferenceTableViewCellDelegate> _delegate;
}

@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) id<UserPreferenceTableViewCellDelegate> delegate;

-(void)setKeyString:(NSString*)keyStr attributes:(NSArray*)attributes;
-(UIView*)viewForItem:(NSArray*)itemAttributes key:(NSString*)key;

@end

