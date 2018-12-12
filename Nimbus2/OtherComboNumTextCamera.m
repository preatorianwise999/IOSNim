
//
//  ElementAPVCameraCell.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "OtherComboNumTextCamera.h"

@implementation OtherComboNumTextCamera
@synthesize elementLbl,reportLbl,amountLbl,observationLbl,elementTxt,reportTxt,amountTxt,alertComboView,commentBtn;
@synthesize cameraImageView,cameraView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        elementTxt.selectedTextField.placeholder=@"Elemento";
//        reportTxt.selectedTextField.placeholder=@"Reporte";
//        amountTxt.placeholder=@"Cantidad";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    elementTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"ELEMENT"]);
    reportTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);
    amountTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"AMOUNT"]);
    // Configure the view for the selected state
}

@end
