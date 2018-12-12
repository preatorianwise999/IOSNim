//
//  TextTextCell.m
//  LATAM
//
//  Created by Vishnu on 12/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TextTextCell.h"

#import "AppDelegate.h"

@implementation TextTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIColor *color = [UIColor blackColor];
        
        AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        _quantityTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[appDel copyTextForKey:@"AMOUNT"] attributes:@{NSForegroundColorAttributeName: color}];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
     _productTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"CODIGO_PRODUCTO"]);
    _quantityTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
}

@end
