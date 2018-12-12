//
//  EmptySeatTableViewCell.m
//  Nimbus2
//
//  Created by Palash on 12/11/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "EmptySeatTableViewCell.h"

@implementation EmptySeatTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.seats.font =KRobotoFontSize14;
    [self.seatType setFont:[UIFont fontWithName:@"RobotoCondensed-Light" size:12
                            ]];
    
    self.seats.textColor=[UIColor whiteColor];
    self.seatType.textColor=[UIColor whiteColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
