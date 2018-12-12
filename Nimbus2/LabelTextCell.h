//
//  LableTextCell.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface LabelTextCell : OffsetCustomCell
@property(nonatomic,weak) IBOutlet UITextField *textField;
@property(weak,nonatomic) IBOutlet UILabel *reportLabel;
@property(nonatomic,weak) IBOutlet UIImageView *rightIndicator;



@end
