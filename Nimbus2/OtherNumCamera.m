//
//  OtherNum.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "OtherNumCamera.h"

@implementation OtherNumCamera

@synthesize reasonLbl, observationLbl, amountLbl;
@synthesize reasonTxt, amountTxt;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        reasonTxt.selectedTextField.placeholder=@"Motivo";
//        amountTxt.placeholder=@"Cantidad";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    reasonTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REASON"]);
    amountTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);

    // Configure the view for the selected state
}

@end
