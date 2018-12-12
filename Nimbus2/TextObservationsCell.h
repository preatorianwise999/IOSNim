//
//  TextObservationsCell.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface TextObservationsCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *observationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

@end
