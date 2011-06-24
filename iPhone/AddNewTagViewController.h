//
//  AddNewTagViewController.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-8.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddNewTagViewController : UITableViewController {

	UIBarButtonItem* _cancelButton;
	UIBarButtonItem* _doneButton;
	
	UITableViewCell* _cell;
	
	UITextField* _tagName;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem* cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* doneButton;
@property (nonatomic, retain) IBOutlet UITableViewCell* cell;
@property (nonatomic, retain) IBOutlet UITextField* tagName;

-(IBAction)cancel;
-(IBAction)done;
-(IBAction)tagNameChanges:(id)sender;

@end
