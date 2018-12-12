//
//  UILabel+Border.m
//  Nimbus2
//
//  Created by 720368 on 7/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "UILabel+Border.h"

@implementation UILabel (Border)

- (void)createArcPathFromstart:(int)from end:(int)end withDistance:(int)dist {
    
    if(end == 0) {
        return;
    }
    
    double angle = (double)(360 * from/end)+270;
    self.text=[@(from) stringValue];
    
    
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.lineWidth   = 6;
    ring.path = [UIBezierPath bezierPathWithArcCenter:self.center
                                               radius:(self.frame.size.width/2+dist)
                                           startAngle:DEGREES_TO_RADIANS(270)
                                             endAngle:DEGREES_TO_RADIANS(angle)
                                            clockwise:YES].CGPath;
    ring.strokeColor=[UIColor colorWithRed:143.0f green:163.0f blue:183.0f alpha:0.6f].CGColor;
    ring.fillColor = [UIColor clearColor].CGColor;
    
    [self.superview.layer addSublayer:ring];
}






@end
