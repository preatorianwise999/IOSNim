//
//  ComboBoxTextNum.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"
#import "ComboNumTextText.h"
#import "SeatNumViewController.h"

@interface ComboBoxTextNum : OffsetCustomCell<ComboNumTextTextDelegate,SeatNumSelectionDelegates,UIPickerViewDataSource,UIPickerViewDelegate,UIPopoverControllerDelegate>
{
    UIPopoverController *pop;
    UIPickerView *picker;
    NSArray *array1;
    NSArray *array2;
    NSArray *array3;
}

@property(nonatomic,weak) IBOutlet TestView *comboView;

@property(weak,nonatomic) IBOutlet UILabel *comboViewlabel;

@property (weak, nonatomic) IBOutlet UILabel *seatRowLbl;
@property (weak, nonatomic) IBOutlet UILabel *seatLetterLbl;
@property (weak, nonatomic) IBOutlet UITextField *seatRowTxt;
@property (weak, nonatomic) IBOutlet UITextField *seatLetterTxt;
@property (strong, nonatomic)SeatNumViewController *testViewController;

@property (nonatomic,weak) id <ComboNumTextTextDelegate>delegate;
- (IBAction)onClickSeatRow:(UIButton *)sender;
-(void)seatnumSelectionDone;


@end
