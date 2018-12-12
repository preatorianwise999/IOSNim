//
//  ComboTextTextCell.h
//  LATAM
//
//  Created by Vishnu on 14/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface ComboTextTextCell : OffsetCustomCell
@property(nonatomic,weak) IBOutlet TestView *comboView;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(weak,nonatomic) IBOutlet UILabel *documentLabel;
@property(weak,nonatomic) IBOutlet UILabel *quantityLabel;
@property(weak,nonatomic) IBOutlet UILabel *observationLabel;
@end
