//
//  OtherNum.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface OtherCamera : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *reportLbl;
@property (weak, nonatomic) IBOutlet UILabel *observationLbl;
@property (weak, nonatomic) IBOutlet TestView *reportTxt;

@end
