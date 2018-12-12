//
//  ElementAPVCameraCell.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboComboComboNumTextCamera.h"

@implementation ComboComboComboNumTextCamera
@synthesize serviceLbl,optionLbl,reportLbl,amountLbl,observationLbl;
@synthesize serviceTxt,optionTxt,reportTxt,amountTxt, alertComboView,commentBtn;
@synthesize cameraImageView,cameraView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       // amountTxt.placeholder=@"Amount";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    amountTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
    serviceTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"SERVICE"]);
    optionTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"OPTION"]);
    reportTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);
    // Configure the view for the selected state
}

@end
