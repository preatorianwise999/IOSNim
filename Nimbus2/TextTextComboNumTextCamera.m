//
//  TextTextComboNumTextCamera.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TextTextComboNumTextCamera.h"

@implementation TextTextComboNumTextCamera
@synthesize serviceLbl,optionLbl,reportLbl,amountLbl,observationLbl;
@synthesize serviceTxt,optionTxt,reportTxt,amountTxt, alertComboView, commentBtn;

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
    serviceTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"SERVICE"]);
    optionTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"OPTION"]);
    amountTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
    reportTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);

    // Configure the view for the selected state
}

@end
