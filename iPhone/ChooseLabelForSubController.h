//
//  ChooseLabelForSubController.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-6.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRTag.h"

@protocol ChooseLabelForSubDelegate

-(void)didCancelSubscribeForFeed:(NSString*)streamID;
-(void)didChooseLabelForFeed:(NSString*)streamID labels:(NSArray*)labels withTitle:(NSString*)title;
-(void)didFinishLabelChoose:(NSString*)streamID;

@end


@interface ChooseLabelForSubController : UITableViewController {
	UITableView* _theTableView;
	
	NSMutableArray* _tags;
	
	NSMutableDictionary* _selectedTags;
	NSMutableDictionary* _cellForTag;
	
	NSString* _subscriptionTitle;
	NSString* _streamID;
	
	id<ChooseLabelForSubDelegate> _delegate;
	
	BOOL _chooseDone;
}

@property (nonatomic, retain) NSMutableArray* tags;
@property (nonatomic, retain) NSMutableDictionary* selectedTags;
@property (nonatomic, retain) NSMutableDictionary* cellForTag;
@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) NSString* subscriptionTitle;
@property (nonatomic, retain) NSString* streamID;
@property (nonatomic, assign) id<ChooseLabelForSubDelegate> delegate;
@property (nonatomic, assign) BOOL chooseDone;

-(id)initWithSubTitle:(NSString*)subTitle andStreamID:(NSString*)streamID;
-(id)initWithSelectedTags:(NSArray*)mSelectedTags;

-(BOOL)isListSection:(NSInteger)section;
-(UITableViewCell*)createCellForTag:(GRTag*)tag;
-(void)checkMarkAllCell;
-(void)changeTagInSelectedList:(GRTag*)tag;
-(void)createCells;

-(void)cancel;
-(void)done;

@end
