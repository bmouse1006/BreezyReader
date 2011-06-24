//
//  JJSplitViewController.h
//  SmallReader
//
//  Created by Jin Jin on 10-9-5.
//  Copyright 2010 com.jinjin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JJSplitViewController : UISplitViewController {
	NSArray* _viewControllers;
}

//@property (nonatomic, retain) NSArray* viewControllers;

-(void)layoutViews:(UIInterfaceOrientation)interfaceOrientation;

@end
