//
//  FlightDetailsCell.m
//  Nimbus2
//
//  Created by Rajashekar on 03/12/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import "FlightDetailsCell.h"

@implementation FlightDetailsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateConstraints {
       [super updateConstraints];
}

- (void)layoutSubviews {
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        _bar1Width.constant = _bar2Width.constant = _bar3Width.constant = _bar4Width.constant = 80;
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        _bar1Width.constant = _bar2Width.constant = _bar3Width.constant = _bar4Width.constant = 120;

    }
    [super layoutSubviews];
}

@end
