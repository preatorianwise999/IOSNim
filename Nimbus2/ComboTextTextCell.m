//
//  ComboTextTextCell.m
//  LATAM
//
//  Created by Vishnu on 14/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboTextTextCell.h"

@implementation ComboTextTextCell
@synthesize alertComboView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        _comboView.selectedTextField.placeholder=@"Documento";
//        _textField.placeholder=@"Cantidad";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    _comboView.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"DOCUMENTO"]);
    _textField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
    // Configure the view for the selected state
}


@end
