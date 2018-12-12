//
//  NSImage+Shapes.m
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/13/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "UIImage+Shapes.h"

@implementation UIImage (Shapes)

+ (UIImage*)fillRoundRectWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)fillRectWithLeftRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    CGRect sharpRect = CGRectMake(w/2, 0, w/2, h);
    
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    [path appendPath:[UIBezierPath bezierPathWithRect:sharpRect]];
    
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)fillRectWithRightRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    CGRect sharpRect = CGRectMake(0, 0, w/2, h);
    
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    [path appendPath:[UIBezierPath bezierPathWithRect:sharpRect]];
    
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)fillRectWithTopRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    CGRect sharpRect = CGRectMake(0, h/2, w, h/2);
    
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    [path appendPath:[UIBezierPath bezierPathWithRect:sharpRect]];
    
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)fillRectWithBottomRoundCornersWithWidth:(int)w height:(int)h radius:(int)r fillColor:(UIColor*)fillColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    CGRect sharpRect = CGRectMake(0, 0, w, h/2);
    
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    [path appendPath:[UIBezierPath bezierPathWithRect:sharpRect]];
    
    [path fill];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)drawCircleWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, thickness, thickness);
    
    CGRect rect = CGRectMake(0, 0, w, h);
    rect = CGRectInset(rect, thickness + 1, thickness + 1);
    
    [borderColor setStroke];
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [path fill];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}


@end