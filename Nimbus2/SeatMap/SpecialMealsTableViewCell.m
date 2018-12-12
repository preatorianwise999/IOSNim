//
//  SpecialMealsTableViewCell.m
//  Nimbus2
//
//  Created by Palash on 12/11/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SpecialMealsTableViewCell.h"

@implementation SpecialMealsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.serviceCode.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:12
                             ];
    self.mealsListString.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:14
                                 ];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
