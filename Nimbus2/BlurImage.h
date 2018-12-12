//
//  BlurImage.h
//  Nimbus2
//
//  Created by 720368 on 7/27/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "CaptureView.h"
@interface BlurImage : NSObject
- (UIImage*)blur:(UIView*)view;
@end
