//
//  ComboNum.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboNum.h"

@implementation ComboNum

@synthesize reportLbl;

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
//[_plusButton setImage:[UIImage imageNamed:@"N__0004_plus_btn_1"]];

    // Configure the view for the selected state
}


- (IBAction)minusButtonTap:(UIButton *)sender {
    if([_valueLabel.text isEqualToString:@"0"]){
        return;
    }
    _valueLabel.text = [NSString stringWithFormat:@"%d",[_valueLabel.text intValue]-1];
}

- (IBAction)plusButtonTap:(UIButton *)sender {
    //    if([_valueLabel.text isEqualToString:@"20"]){
    //        return;
    //    }
    _valueLabel.text = [NSString stringWithFormat:@"%d",[_valueLabel.text intValue]+1];
}

@end
