//
//  CabinLabelComboObservationCell
//  LATAM
//
//  Created by Vishnu on 17/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface CabinLabelComboObservationCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *reasonLbl;

@property (weak, nonatomic) IBOutlet TestView *reasonCombobox;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

@end
