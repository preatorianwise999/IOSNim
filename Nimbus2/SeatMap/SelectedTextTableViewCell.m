//
//  SelectedTextTableViewCell.m
//  Nimbus2
//
//  Created by Dreamer on 10/23/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SelectedTextTableViewCell.h"

@implementation SelectedTextTableViewCell
@synthesize lname_Label,bc_Label,presilver_Label,selectedPassengerImage;
- (void)awakeFromNib {
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [presilver_Label setFont:kseatMapLabelFont];
}

@end
