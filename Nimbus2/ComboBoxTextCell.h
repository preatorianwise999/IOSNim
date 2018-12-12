//
//  ComboBoxTextCell.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface ComboBoxTextCell : OffsetCustomCell

@property(nonatomic,weak) IBOutlet TestView *comboView;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;
@property(weak,nonatomic) IBOutlet UILabel *reportLabel;
@property(weak,nonatomic) IBOutlet UILabel *observationLabel;
@property(weak,nonatomic) IBOutlet UIView *sideView;


@end
