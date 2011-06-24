//
//  AddNewFeedViewController.h
//  SmallReader
//
//  Created by Jin Jin on 10-12-11.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseLabelForSubController.h"

@interface AddNewFeedViewController : UITableViewController<ChooseLabelForSubDelegate> {
	UITableView* _theTableView;
	
	UITableViewCell* _URLInputCell;
	UITableViewCell* _labelCell;
	UITableViewCell* _subscribeCell;
	UILabel* _subscribeLabel;
	UILabel* _URLLabel;
	UILabel* _tagLabel;
	
	UITextField* _URLText;
	UILabel* _selectedTagsLabel;
	UIBarButtonItem* _cancelButton;
	UIActivityIndicatorView* _activeIndicator;
	
	NSMutableArray* _selectedTags;
}

@property (nonatomic, retain) IBOutlet UITableView* theTableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* URLInputCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* labelCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* subscribeCell;
@property (nonatomic, retain) IBOutlet UILabel* subscribeLabel;
@property (nonatomic, retain) IBOutlet UILabel* URLLabel;
@property (nonatomic, retain) IBOutlet UILabel* tagLabel;
@property (nonatomic, retain) IBOutlet UITextField* URLText;
@property (nonatomic, retain) IBOutlet UILabel* selectedTagsLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* cancelButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activeIndicator;

@property (nonatomic, retain) NSMutableArray* selectedTags;

-(IBAction)cancelAction;
-(void)localizeUI;
-(void)confirmSubscribe;
-(void)releaseOutlet;
-(void)showAllSelectedTags;

@end
