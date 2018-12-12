//
//  UILabel+Border.h
//  Nimbus2
//
//  Created by 720368 on 7/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
@interface UILabel (Border){
}
- (void)createArcPathFromstart:(int)from end:(int)end withDistance:(int)dist;
@end
