//
//  detailTableViewCell.m
//  Nimbus2
//
//  Created by Dreamer on 10/19/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "detailTableViewCell.h"

@implementation detailTableViewCell
@synthesize name,Cumpleanos_Label,NumeraFFP_Label,Categoria_Label,Kms_Label,bday_Label,Comodoro_Label,KM_Label,docNum_Label;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [name setFont:kseatMapLabelFont];
    [Cumpleanos_Label setFont:kseatMapLabelFont];
    [NumeraFFP_Label setFont:kseatMapLabelFont];
    [Categoria_Label setFont:kseatMapLabelFont];
    [KM_Label setFont:kseatMapLabelFont];
    [bday_Label setFont:kseatMapLabelFont];
    [docNum_Label setFont:kseatMapLabelFont];
    [Comodoro_Label setFont:kseatMapLabelFont];
    [KM_Label setFont:kseatMapLabelFont];

    // Configure the view for the selected state
}

@end
