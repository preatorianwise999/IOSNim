//
//  LeftOtherCell.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface LeftOtherCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *reasonLbl;

@property (weak, nonatomic) IBOutlet TestView *reasonTxt;

@end

