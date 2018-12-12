//
//  ComboComboComboNumCamera.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboComboComboNumCamera.h"

@implementation ComboComboComboNumCamera
@synthesize serviceLbl,optionLbl,reportLbl,amountLbl,observationLbl;
@synthesize serviceTxt,optionTxt,reportTxt;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
