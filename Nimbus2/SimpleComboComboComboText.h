//
//  SimpleComboComboComboText.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface SimpleComboComboComboText :OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *serviceLbl;
@property (weak, nonatomic) IBOutlet UILabel *optionLbl;
@property (weak, nonatomic) IBOutlet UILabel *reportLbl;
@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet TestView *serviceTxt;
@property (weak, nonatomic) IBOutlet TestView *optionTxt;
@property (weak, nonatomic) IBOutlet TestView *reportTxt;
@property (weak, nonatomic) IBOutlet UITextField *amountTxt;

@end
