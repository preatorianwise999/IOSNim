//
//  TextObservationsCell.m
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TextObservationsCell.h"

@implementation TextObservationsCell
@synthesize alertComboView,commentBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //_textField.placeholder = @"Indicar Número da poltrona";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    _textField.attributedPlaceholder=kDarkPlaceholder(@"Indicar Número da poltrona");
    // Configure the view for the selected state
}

@end
