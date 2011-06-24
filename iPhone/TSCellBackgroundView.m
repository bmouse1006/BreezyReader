//
//  TSCellBackgroundView.m
//  RoundShadowGradientCellView
//
//  Created by song teng on 10-7-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 *	Any problem please email to shawnt22@gmail.com	=]
 */

#import "TSCellBackgroundView.h"

@interface TSCellBackgroundView(Private)

- (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations count:(int)count;
- (void)contextTopPathWith:(CGContextRef)_context Rect:(CGRect)_rect;
- (void)contextMiddlePathWith:(CGContextRef)_context Rect:(CGRect)_rect;
- (void)contextBottomPathWith:(CGContextRef)_context Rect:(CGRect)_rect;
- (void)contextSinglePathWith:(CGContextRef)_context Rect:(CGRect)_rect;
- (void)drawRoundShadowWith:(CGContextRef)_context Rect:(CGRect)_rect CellStyle:(CellStyle)_style;
- (void)drawGradientWith:(CGContextRef)_context Rect:(CGRect)_rect CellStyle:(CellStyle)_style;

@end

@implementation TSCellBackgroundView
@synthesize theCellStyle;

#define ROUND_SIZE 10
#define SHADOW_BLUR 2.0
#define SHADOW_OFFSET_X 2.0
#define SHADOW_OFFSET_Y 3.0

#pragma mark -
#pragma mark init & dealloc
- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing
- (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations
								 count:(int)count {
	CGFloat* components = malloc(sizeof(CGFloat)*4*count);
	for (int i = 0; i < count; ++i) {
		UIColor* color = colors[i];
		size_t n = CGColorGetNumberOfComponents(color.CGColor);
		const CGFloat* rgba = CGColorGetComponents(color.CGColor);
		if (n == 2) {
			components[i*4] = rgba[0];
			components[i*4+1] = rgba[0];
			components[i*4+2] = rgba[0];
			components[i*4+3] = rgba[1];
		} else if (n == 4) {
			components[i*4] = rgba[0];
			components[i*4+1] = rgba[1];
			components[i*4+2] = rgba[2];
			components[i*4+3] = rgba[3];
		}
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	CGGradientRef _gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
	free(components);
	return _gradient;
}

- (void)contextTopPathWith:(CGContextRef)_context Rect:(CGRect)_rect
{
	_rect = CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width - SHADOW_OFFSET_X, _rect.size.height - 1.0);
	
	CGFloat minx = CGRectGetMinX(_rect) , midx = CGRectGetMidX(_rect), maxx = CGRectGetMaxX(_rect) ;
	CGFloat miny = CGRectGetMinY(_rect) , maxy = CGRectGetMaxY(_rect) ;	
	
	CGContextMoveToPoint(_context, minx, maxy);
	CGContextAddArcToPoint(_context, minx, miny, midx, miny, ROUND_SIZE);
	CGContextAddArcToPoint(_context, maxx, miny, maxx, maxy, ROUND_SIZE);
	CGContextAddLineToPoint(_context, maxx, maxy);
	
	CGContextClosePath(_context);
}
- (void)contextMiddlePathWith:(CGContextRef)_context Rect:(CGRect)_rect
{
//	_rect = CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width - SHADOW_OFFSET_X, _rect.size.height - 1.0);
	_rect = CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width, _rect.size.height);
	
	CGFloat minx = CGRectGetMinX(_rect) , maxx = CGRectGetMaxX(_rect) ;
	CGFloat miny = CGRectGetMinY(_rect) , maxy = CGRectGetMaxY(_rect) ;
	
	CGContextMoveToPoint(_context, minx, miny);
	CGContextAddLineToPoint(_context, maxx, miny);
	CGContextAddLineToPoint(_context, maxx, maxy);
	CGContextAddLineToPoint(_context, minx, maxy);
	
	CGContextClosePath(_context);
}
- (void)contextBottomPathWith:(CGContextRef)_context Rect:(CGRect)_rect
{
	_rect = CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width - SHADOW_OFFSET_X, _rect.size.height - SHADOW_OFFSET_Y);
	
	CGFloat minx = CGRectGetMinX(_rect) , midx = CGRectGetMidX(_rect), maxx = CGRectGetMaxX(_rect) ;
	CGFloat miny = CGRectGetMinY(_rect) , maxy = CGRectGetMaxY(_rect) ;
	
	CGContextMoveToPoint(_context, minx, miny);
	CGContextAddArcToPoint(_context, minx, maxy, midx, maxy, ROUND_SIZE);
	CGContextAddArcToPoint(_context, maxx, maxy, maxx, miny, ROUND_SIZE);
	CGContextAddLineToPoint(_context, maxx, miny);
	
	CGContextClosePath(_context);
}
- (void)contextSinglePathWith:(CGContextRef)_context Rect:(CGRect)_rect
{
	_rect = CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width - SHADOW_OFFSET_X, _rect.size.height - SHADOW_OFFSET_Y);
	
	CGFloat minx = CGRectGetMinX(_rect) , midx = CGRectGetMidX(_rect), maxx = CGRectGetMaxX(_rect) ;
	CGFloat miny = CGRectGetMinY(_rect) , midy = CGRectGetMidY(_rect) , maxy = CGRectGetMaxY(_rect) ;
	
	CGContextMoveToPoint(_context, minx, midy);
	CGContextAddArcToPoint(_context, minx, miny, midx, miny, ROUND_SIZE);
	CGContextAddArcToPoint(_context, maxx, miny, maxx, midy, ROUND_SIZE);
	CGContextAddArcToPoint(_context, maxx, maxy, midx, maxy, ROUND_SIZE);
	CGContextAddArcToPoint(_context, minx, maxy, minx, midy, ROUND_SIZE);
	
	CGContextClosePath(_context);
}
- (void)drawRoundShadowWith:(CGContextRef)_context Rect:(CGRect)_rect CellStyle:(CellStyle)_style
{
	CGContextSaveGState(_context);
	
	CGContextSetFillColorWithColor(_context, [UIColor colorWithRed:250/255.0 green:175/255.0 blue:64/255.0 alpha:1.0].CGColor);
	// Shadow
	CGContextSetShadowWithColor(_context, CGSizeMake(SHADOW_OFFSET_X, -SHADOW_OFFSET_Y), SHADOW_BLUR, [UIColor blackColor].CGColor);
	
	switch (_style) {
		case CellStyle_Top:
			[self contextTopPathWith:_context Rect:_rect];
			break;
		case CellStyle_Middle:
			[self contextMiddlePathWith:_context Rect:_rect];
			break;
		case CellStyle_Bottom:
			[self contextBottomPathWith:_context Rect:_rect];
			break;
		case CellStyle_Single:
			[self contextSinglePathWith:_context Rect:_rect];
			break;
		default:
			CGContextRestoreGState(_context);
			return;
	}
	// Draw Fill Path
	CGContextDrawPath(_context, kCGPathFill);
	
	CGContextRestoreGState(_context);
}
- (void)drawGradientWith:(CGContextRef)_context Rect:(CGRect)_rect CellStyle:(CellStyle)_style
{
	CGContextSaveGState(_context);
	
	switch (_style) {
		case CellStyle_Top:
			[self contextTopPathWith:_context Rect:_rect];
			break;
		case CellStyle_Middle:
			[self contextMiddlePathWith:_context Rect:_rect];
			break;
		case CellStyle_Bottom:
			[self contextBottomPathWith:_context Rect:_rect];
			break;
		case CellStyle_Single:
			[self contextSinglePathWith:_context Rect:_rect];
			break;
		default:
			CGContextRestoreGState(_context);
			return;
	}
	
	CGContextClip(_context);
	
	UIColor* colors[] = {[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0], [UIColor colorWithRed:0.486 green:0.659 blue:0.851 alpha:1.0]};
	CGGradientRef _gradient = [self newGradientWithColors:colors locations:nil count:2];
	CGContextDrawLinearGradient(_context, _gradient, CGPointZero, CGPointMake(_rect.origin.x, _rect.origin.y+_rect.size.height), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(_gradient);
	
	CGContextRestoreGState(_context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
	
//	[self drawRoundShadowWith:c Rect:rect CellStyle:self.theCellStyle];
	[self drawGradientWith:c Rect:rect CellStyle:self.theCellStyle];
}

@end
