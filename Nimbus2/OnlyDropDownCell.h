//
//  OnlyDropDownCell.h
//  LATAM
//
//  Created by Vishnu on 11/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"
#import  "AppDelegate.h"
@interface OnlyDropDownCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *motivoLabel;
@property(nonatomic,weak) IBOutlet TestView *comboView;
@end
