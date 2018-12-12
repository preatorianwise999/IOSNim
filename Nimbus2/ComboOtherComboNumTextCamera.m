//
//  ComboOtherComboNumTextCamera.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboOtherComboNumTextCamera.h"

@implementation ComboOtherComboNumTextCamera
@synthesize serviceLbl,optionLbl,reportLbl,amountLbl,observationLbl;
@synthesize serviceTxt,optionTxt,reportTxt,amountTxt,commentBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [super setSelected:selected animated:animated];
    serviceTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"SERVICE"]);
    optionTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"OPTION"]);
    
    reportTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);
    amountTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
    // Configure the view for the selected state
}

@end
