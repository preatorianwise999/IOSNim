//
//  SeatNum.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"
#import "SeatNumViewController.h"

@protocol SeatNumDelegate <NSObject>

-(void)valuesSelectedInPopOver:(UITextField*)textFields;

@end
@interface SeatNum : OffsetCustomCell <UIPopoverControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,SeatNumSelectionDelegates>{
    UIPopoverController *pop;
    UIPickerView *picker;
    NSArray *array1;
    NSArray *array2;
    NSArray *array3;
}

@property (weak, nonatomic) IBOutlet UITextField *seatRowTxt;
@property (weak, nonatomic) IBOutlet UITextField *seatLetterTxt;
@property (nonatomic,weak) id <SeatNumDelegate>delegate;
@property (nonatomic,weak) IBOutlet UIButton *button;

-(IBAction)onClickSeatRow:(UIButton *)sender;
@end
