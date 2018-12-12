//
//  CabinLabelComboObservationCell.m
//  LATAM
//
//  Created by Vishnu on 17/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "CabinLabelComboObservationCell.h"

@implementation CabinLabelComboObservationCell

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
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [super setSelected:selected animated:animated];
    
    _reasonCombobox.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);
    // Configure the view for the selected state
}

@end
