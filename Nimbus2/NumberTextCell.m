//
//  NumberTextCell.m
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "NumberTextCell.h"

@implementation NumberTextCell
@synthesize reportLabel,observationsLabel,alertComboView,commentBtn;

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
    _valueLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"N__0005_plus_minus_bg"]];

    
    // Configure the view for the selected state
}

- (IBAction)minusButtonTap:(UIButton *)sender {
    
    if([_valueLabel.text isEqualToString:@"0"]){
        return;
    }
//Nimbus@2    [LTSingleton getSharedSingletonInstance].isDataChanged=TRUE;
    _valueLabel.text = [NSString stringWithFormat:@"%d",[_valueLabel.text intValue]-1];
}

- (IBAction)plusButtonTap:(UIButton *)sender {
//    if([_valueLabel.text isEqualToString:@"20"]){
//        return;
//    }
//Nimbus@2    [LTSingleton getSharedSingletonInstance].isDataChanged=TRUE;
    _valueLabel.text = [NSString stringWithFormat:@"%d",[_valueLabel.text intValue]+1];
}
@end
