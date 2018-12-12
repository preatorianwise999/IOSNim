//
//  OtherText.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface OtherText : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *reportLbl;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLbl;
    
@property (weak, nonatomic) IBOutlet TestView *reportTxt;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTxt;

@end
