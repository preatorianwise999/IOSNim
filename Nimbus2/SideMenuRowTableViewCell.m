//
//  SideMenuRowTableViewCell.m
//  Nimbus2
//
//  Created by Palash on 29/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SideMenuRowTableViewCell.h"

@implementation SideMenuRowTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.50f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [_rowBackgroundImg setImage:[UIImage imageNamed:@"N__0001_sel_bg.png"]];
        [_rowBackgroundImg.layer addAnimation:transition forKey:nil];
        
    }else{
        [_rowBackgroundImg setImage:nil];

    }
}

@end
