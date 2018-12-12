//
//  AcompanantesTableViewCell.m
//  Nimbus2
//
//  Created by Dreamer on 10/19/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "AcompanantesTableViewCell.h"

@implementation AcompanantesTableViewCell
//@synthesize Acompanantes_Label,A_Label,
@synthesize Acompanantes_Label,A_Label,Maria_Label,C_Label,Fernando;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_Acompanies_buton_label setFont:kseatMapLabelFont];
    [Acompanantes_Label setFont:kseatMapLabelFont];
    [A_Label setFont:kseatMapLabelFont];
    [Maria_Label setFont:kseatMapLabelFont];
    [C_Label setFont:kseatMapLabelFont];
    [Fernando setFont:kseatMapLabelFont];

    // Configure the view for the selected state
}
@end
