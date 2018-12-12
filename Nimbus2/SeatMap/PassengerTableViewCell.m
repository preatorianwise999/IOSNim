//
//  PassengerTableViewCell.m
//  SeatMapSample
//
//  Created by Rajashekar on 14/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import "PassengerTableViewCell.h"

@implementation PassengerTableViewCell
@synthesize seatNumber,firstName;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
