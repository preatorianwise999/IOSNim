//
//  NumberTextCell.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface NumberTextCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *reportLabel;
@property (weak, nonatomic) IBOutlet UILabel *observationsLabel;

- (IBAction)minusButtonTap:(UIButton *)sender;
- (IBAction)plusButtonTap:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;
@property(weak,nonatomic) IBOutlet TestView *alertComboView;
@end
