//
//  OnlyDropDownCell.m
//  LATAM
//
//  Created by Vishnu on 11/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "OnlyDropDownCell.h"

@implementation OnlyDropDownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //_comboView.selectedTextField.placeholder=@"Motivo";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    _comboView.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REASON"]);

    // Configure the view for the selected state
}

@end
