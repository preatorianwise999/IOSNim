//
//  SideMenuSectionTableViewCell.m
//  Nimbus2
//
//  Created by Palash on 29/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SideMenuSectionTableViewCell.h"

@implementation SideMenuSectionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
