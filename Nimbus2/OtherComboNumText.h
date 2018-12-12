//
//  ElementAPVCell.h
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface OtherComboNumText : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *elementLbl;
@property (weak, nonatomic) IBOutlet UILabel *reportLbl;
@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet UILabel *observationLbl;
@property (weak, nonatomic) IBOutlet UITextField *amountTxt;

@property (weak, nonatomic) IBOutlet TestView *elementTxt;
@property (weak, nonatomic) IBOutlet TestView *reportTxt;
@property (weak, nonatomic) IBOutlet TestView *alertComboView;

@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

-(void)setTextFieldsDelegate:(id)sender;
@end
