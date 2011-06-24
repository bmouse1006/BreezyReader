//
//  TSCellBackgroundView.h
//  RoundShadowGradientCellView
//
//  Created by song teng on 10-7-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CellStyleT {
	CellStyle_None,
	CellStyle_Top,
	CellStyle_Middle,
	CellStyle_Bottom,
	CellStyle_Single
} CellStyle;

@interface TSCellBackgroundView : UIView {
	CellStyle theCellStyle;
}
@property (nonatomic, assign)CellStyle theCellStyle;

@end
