//
//  LanPassTableViewCell.m
//  Nimbus2
//
//  Created by Palash on 13/11/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "LanPassTableViewCell.h"

@implementation LanPassTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headingLanPass.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:14
                                ];
    self.listOfPassengers.font = kseatMapLabelFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
