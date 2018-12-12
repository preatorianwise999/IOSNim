//
//  CrewCPTableViewCell.m
//  Nimbus2
//
//  Created by 720368 on 7/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CrewCPTableViewCell.h"

@implementation CrewCPTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)clear {
    self.cptImageView.hidden = YES;
    self.cptBPIdLabel.text = @"";
    self.cptNameLabel.text = @"";
    
    self.cptSecondImageView.hidden = YES;
    self.cptSecondBPId.text = @"";
    self.cptSecondNameLabel.text = @"";
    
    self.cptThreeImageView.hidden = YES;
    self.cptthreeBPId.text = @"";
    self.cptThreeNameLabel.text = @"";
    
    self.designationLabel.text = @"";
    self.designationSecondLabel.text = @"";
    self.designationThreeLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
