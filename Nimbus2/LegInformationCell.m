//
//  LegInformationCell.m
//  LATAM
//
//  Created by Vishnu on 02/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LegInformationCell.h"

@implementation LegInformationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.departureTime.selectedTextField.textColor = [UIColor grayColor];
    self.destinationTime.selectedTextField.textColor = [UIColor grayColor];
    self.departureTime.selectedTextField.font = KRobotoFontSize18;
    self.destinationTime.selectedTextField.font = KRobotoFontSize18;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
