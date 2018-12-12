//
//  TextTextComboNumTextCamera.h
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface TextTextComboNumTextCamera :OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *serviceLbl;
@property (weak, nonatomic) IBOutlet UILabel *optionLbl;
@property (weak, nonatomic) IBOutlet UILabel *reportLbl;
@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet UILabel *observationLbl;
@property (weak, nonatomic) IBOutlet UITextField *serviceTxt;
@property (weak, nonatomic) IBOutlet UITextField *optionTxt;
@property (weak, nonatomic) IBOutlet TestView *reportTxt;

@property (weak, nonatomic) IBOutlet UITextField *amountTxt;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;

@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;


@property(nonatomic,weak) IBOutlet TestView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@end
