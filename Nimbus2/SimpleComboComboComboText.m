//
//  SimpleComboComboComboText.m
//  LATAM
//
//  Created by Durga Madamanchi on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "SimpleComboComboComboText.h"

@implementation SimpleComboComboComboText
@synthesize serviceLbl,optionLbl,reportLbl,amountLbl;

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
