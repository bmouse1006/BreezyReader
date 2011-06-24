//
//  GoogleAppConstants.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleAppConstants.h"

NSString* const LOGIN_NOTIN					= @"0";		
NSString* const LOGIN_SUCCESSFUL			= @"1";	
NSString* const LOGIN_FAILED				= @"2";
NSString* const LOGIN_INPROGRESS			= @"3";

NSString * const CLIENT_IDENTIFIER			= @"BREEZYREADER-1.0.0";

NSString * const GOOGLE_SCHEME				= @"http://www.google.com/";
NSString * const GOOGLE_SCHEME_SSL			= @"https://www.google.com/";

NSString * const COOKIE_DOMAIN				= @".google.com";
NSString * const COOKIE_SID					= @"SID";
NSString * const COOKIE_AUTH				= @"Auth";
NSString * const COOKIE_PATH				= @"/";

NSString * const URI_LOGIN					= @"https://www.google.com/accounts/ClientLogin";

NSString * const URI_PREFIXE_READER			= @"reader/";
NSString * const URI_PREFIXE_ATOM			= @"reader/atom/";
NSString * const URI_PREFIXE_API			= @"reader/api/0/";
NSString * const URI_PREFIXE_VIEW			= @"reader/view/";

NSString * const ATOM_GET_FEED				= @"feed/";

NSString * const ATOM_PREFIXE_USER			= @"user/-/";
NSString * const ATOM_PREFIXE_USER_NUMBER	= @"user/00000000000000000000/";
NSString * const ATOM_PREFIXE_LABEL			= @"user/-/label/";
NSString * const ATOM_PREFIXE_STATE_GOOGLE	= @"user/-/state/com.google/";

NSString * const ATOM_STATE_READ			= @"read";
NSString * const ATOM_STATE_UNREAD			= @"kept-unread";
NSString * const ATOM_STATE_FRESH			= @"fresh";
NSString * const ATOM_STATE_READING_LIST	= @"reading-list";
NSString * const ATOM_STATE_BROADCAST		= @"broadcast";
NSString * const ATOM_STATE_STARRED			= @"starred";
NSString * const ATOM_SUBSCRIPTIONS			= @"subscriptions";

NSString * const API_EDIT_SUBSCRIPTION		= @"subscription/edit";
NSString * const API_EDIT_TAG1				= @"tag/edit";
NSString * const API_EDIT_TAG2				= @"edit-tag";
NSString * const API_EDIT_DISABLETAG		= @"disable-tag";

NSString * const API_EDIT_MARK_ALL_AS_READ  = @"mark-all-as-read";

NSString * const API_LIST_RECOMMENDATION	= @"recommendation/list";
NSString * const API_LIST_PREFERENCE		= @"preference/list";
NSString * const API_LIST_SUBSCRIPTION		= @"subscription/list";
NSString * const API_LIST_TAG				= @"tag/list";
NSString * const API_LIST_UNREAD_COUNT		= @"unread-count";
NSString * const API_TOKEN					= @"token";

NSString * const URI_QUICKADD				= @"http://www.google.com/reader/quickadd";

NSString * const OUTPUT_XML					= @"xml";
NSString * const OUTPUT_JSON				= @"json";

NSString * const AGENT						= @"BreezyReader-1.0";

NSString * const LOGIN_REQUEST_BODY_STRING	= @"accountType=HOSTED_OR_GOOGLE&Email=%@&Passwd=%@"
												"&service=reader&source=BREEZYREADER-1.0.0&continue=http://www.google.com";
NSString * const LOGIN_TOKEN_STRING			= @"&logintoken=%@@logincaptcha=%@";

NSString * const ATOM_ARGS_START_TIME		= @"ot";
NSString * const ATOM_ARGS_ORDER			= @"r";
NSString * const ATOM_ARGS_EXCLUDE_TARGET	= @"xt";
NSString * const ATOM_ARGS_COUNT			= @"n";
NSString * const ATOM_ARGS_CONTINUATION		= @"c";
NSString * const ATOM_ARGS_CLIENT			= @"client";
NSString * const ATOM_ARGS_TIMESTAMP		= @"ck";

NSString * const EDIT_ARGS_FEED				= @"s";
NSString * const EDIT_ARGS_ITEM			    = @"i";
NSString * const EDIT_ARGS_ADD				= @"a";		
NSString * const EDIT_ARGS_TITLE			= @"t";
NSString * const EDIT_ARGS_REMOVE			= @"r";
NSString * const EDIT_ARGS_ACTION			= @"ac";
NSString * const EDIT_ARGS_TOKEN			= @"T";
NSString * const EDIT_ARGS_PUBLIC			= @"pub";
NSString * const EDIT_ARGS_CLIENT			= @"client";
NSString * const EDIT_ARGS_SOURCE			= @"source";
NSString * const EDIT_ARGS_SOURCE_RECOMMENDATION = @"RECOMMENDATION";
NSString * const EDIT_ARGS_SOURCE_SEARCH	= @"SEARCH";

NSString * const LIST_ARGS_OUTPUT			= @"output";
NSString * const LIST_ARGS_CLIENT			= @"client";
NSString * const LIST_ARGS_TIMESTAMP		= @"ck";
NSString * const LIST_ARGS_ALL				= @"all";

NSString * const ARGS_CLIENT				= @"client";

NSString * const QUICKADD_ARGS_URL			= @"quickadd";
NSString * const QUICKADD_ARGS_TOKEN		= @"T";

NSString * const ORDER_REVERSE				= @"o";
NSString * const ACTION_REVERSE				= @"o";

NSString * const API_ATOM					= @"API_ATOM";
NSString * const API_LIST					= @"API_LIST";
NSString * const API_EDIT					= @"API_EDIT";

//error message
NSString * const ERROR_NOLOGIN				= @"ERROR_NOLOGIN";
NSString * const ERROR_NETWORKFAILED		= @"ERROR_NETWORKFAILED";
NSString * const ERROR_NEEDRELOGIN			= @"ERROR_NEEDRELOGIN";
NSString * const ERROR_TOKENERROR			= @"ERROR_TOKENERROR";
NSString * const ERROR_UNKNOWN				= @"ERROR_UNKNOWN";

@implementation GoogleAppConstants

@end