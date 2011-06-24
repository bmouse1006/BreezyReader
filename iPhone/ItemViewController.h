//
//  ItemViewController.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GRFeed.h"
#import "GRItem.h"
#import "WebViewController.h"
#import "GRDataManager.h"
#import "UserPreferenceDefine.h"
#import "GRSubDownloader.h"
#import "ItemWebView.h"

@interface ItemViewController : UIViewController<UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
	GRItem* _grItem;
//	GRFeed* _grFeed;
	NSArray* _itemList;
	UIWebView* _webView;
	UIToolbar* _buttomToolbar;
	NSString* _contentFormatter;
	
	NSIndexPath* _indexPath;
	
	UIView* _actionMenu;
	
	UIButton* _starActionButton;
	UIButton* _broadcastActionButton;
	UIButton* _keptUnreadActionButton;
	
	UIBarItem* _previousBarItem;
	UIBarItem* _nextBarItem;
	
	UIBarButtonItem* _saveButton;
	
	BOOL _onlineMode;
	BOOL _fullscreen;
}

@property (nonatomic, retain) GRItem* grItem;
//@property (nonatomic, retain) GRFeed* grFeed;
@property (nonatomic, retain) NSArray* itemList;
@property (nonatomic, retain) NSString* contentFormatter;
@property (nonatomic, retain) NSIndexPath* indexPath;
@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIToolbar* buttomToolbar;
@property (nonatomic, retain) IBOutlet UIView* actionMenu;
@property (nonatomic, retain) IBOutlet UIButton* starActionButton;
@property (nonatomic, retain) IBOutlet UIButton* broadcastActionButton;
@property (nonatomic, retain) IBOutlet UIButton* keptUnreadActionButton;
@property (nonatomic, retain) IBOutlet UIBarItem* previousBarItem;
@property (nonatomic, retain) IBOutlet UIBarItem* nextBarItem;
@property (nonatomic, retain) UIBarButtonItem* saveButton;
@property (nonatomic, assign) BOOL onlineMode;
@property (nonatomic, assign) BOOL fullscreen;

-(id)initWithItems:(NSArray*)mItemList itemIndex:(NSIndexPath*)mIndexPath;

@end

@interface ItemViewController (private)

-(void)setItemToActionMenu:(GRItem*)mItem;

-(void)createButtomToolbar;
-(void)createNavigationBarButton:(GRItem*)mItem;
-(void)loadItemContentView:(GRItem*)mItem atIndex:(NSIndexPath*)index;

-(IBAction)loadOrigWebView;
-(IBAction)showHideActionMenu:(id)sender;

-(IBAction)readPreviousItem;
-(IBAction)readNextItem;

-(IBAction)changeStarStatesOfCurrentItem;
-(IBAction)changeBroadcastStatesOfCurrentItem;
-(IBAction)changeKeptUnreadStatesOfCurrentItem;
-(IBAction)emailCurrentItem;

-(NSString*)formatContentString:(GRItem*)item;

//web ui delegate
- (void)webViewDidStartLoad:(UIWebView *)mWebView;
- (void)webViewDidFinishLoad:(UIWebView *)mWebView;
- (void)webView:(UIWebView *)mWebView didFailLoadWithError:(NSError *)error;

-(void)showActionMenu;
-(void)hideActionMenu;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
-(void)composeActionMenu;

-(void)processTouchEvent:(NSString*)event;
-(void)switchFullScreenModeAnimated:(BOOL)animated;
-(void)hideToolBar:(BOOL)hide animated:(BOOL)animated;
-(void)fullscreenWebView;

@end