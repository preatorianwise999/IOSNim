//
//  CaptureView.h
//  printPOC
//
//  Created by 720368 on 6/23/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>

@interface CaptureView : UIView{
@private
UIImage *_imageCapture;
}

@property(nonatomic, retain) UIImage *imageCapture;

// Init
- (id)initWithView:(UIView *)view;

@end
