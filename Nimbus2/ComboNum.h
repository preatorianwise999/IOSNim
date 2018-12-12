//
//  ComboNum.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface ComboNum : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *reportLbl;

@property (weak, nonatomic) IBOutlet TestView *reportTxt;

@property (weak, nonatomic) IBOutlet UILabel *amountLbl;

@property (weak, nonatomic) IBOutlet UITextField *amountTxt;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;


- (IBAction)minusButtonTap:(UIButton *)sender;
- (IBAction)plusButtonTap:(UIButton *)sender;
@end
