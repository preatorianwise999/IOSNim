//
//  ComboNumTextText.h
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"
#import "SeatNumViewController.h"

@protocol ComboNumTextTextDelegate <NSObject>

-(void)valuesSelectedInPopOver:(UITextField*)textFields;

@end
@interface ComboNumTextText : OffsetCustomCell<SeatNumSelectionDelegates,UIPopoverControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
    UIPopoverController *pop;
    UIPickerView *picker;
    NSArray *array1;
    NSArray *array2;
    NSArray *array3;
}
@property (weak, nonatomic) IBOutlet UILabel *failureLbl;
@property (weak, nonatomic) IBOutlet UILabel *seatRowLbl;
@property (weak, nonatomic) IBOutlet UILabel *seatLetterLbl;
@property (weak, nonatomic) IBOutlet UILabel *observationLbl;
@property (weak, nonatomic) IBOutlet TestView *failureTxt;
@property (weak, nonatomic) IBOutlet UITextField *seatRowTxt;
@property (weak, nonatomic) IBOutlet UITextField *seatLetterTxt;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

@property (nonatomic,weak) id <ComboNumTextTextDelegate>delegate;
- (IBAction)onClickSeatRow:(UIButton *)sender;

@end
