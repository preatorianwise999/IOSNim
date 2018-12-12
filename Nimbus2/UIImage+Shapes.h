//
//  NSImage+Shapes.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/13/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Shapes)

+ (UIImage*)fillRoundRectWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor;

// return a UIImage that represents a rectangle whose left, right, top, or bottom side corners are rounded
+ (UIImage*)fillRectWithLeftRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor;

+ (UIImage*)fillRectWithRightRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor;

+ (UIImage*)fillRectWithTopRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor;

+ (UIImage*)fillRectWithBottomRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor;

+ (UIImage*)drawCircleWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor;

@end