//
//  LabelTextViewCell.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface LabelTextViewCell : OffsetCustomCell

@property(nonatomic,weak) IBOutlet UITextView *textField;
@property(weak,nonatomic) IBOutlet UILabel *reportLabel;

@end
