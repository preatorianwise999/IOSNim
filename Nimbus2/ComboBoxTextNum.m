//
//  ComboBoxTextNum.m
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ComboBoxTextNum.h"

@implementation ComboBoxTextNum


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        _seatRowTxt.placeholder=@"Service";
//        _seatLetterTxt.placeholder=@"Service";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [super setSelected:selected animated:animated];
    _seatRowTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"SERVICE"]);
    _seatLetterTxt.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"SERVICE"]);
    _comboView.selectedTextField.attributedPlaceholder=kDarkPlaceholder(@"Selecciona la razon");

    // Configure the view for the selected state
}
-(void)onClickSeatRow:(UIButton *)sender {
    
    self.testViewController = [[SeatNumViewController alloc] initWithNibName:@"SeatNumViewController" bundle:nil];
    self.testViewController.tempCell = self;
    self.testViewController.delgate = self;
    array1 =  @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    array2 =  @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    array3 = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L"];
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, 320, 216.0)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    
    pop = [[UIPopoverController alloc] initWithContentViewController:self.testViewController];
    [self.testViewController.view addSubview:picker];
    [pop setDelegate:self];
    [pop presentPopoverFromRect:CGRectMake( 0, 0, 139, 50 )
                         inView:sender permittedArrowDirections:UIPopoverArrowDirectionDown
                       animated:YES];
    
    [pop setPopoverContentSize:CGSizeMake(320, 300) animated:NO];
    
    if([self.seatRowTxt.text length]>0){
        int seatValue =  [self.seatRowTxt.text intValue];
        
        int temp1 = seatValue/10;
        int temp2 = seatValue%10;
        
        [picker selectRow:temp1 inComponent:0 animated:NO];
        [picker selectRow:temp2 inComponent:1 animated:NO];
        
    }
    else{
        [picker selectRow:1 inComponent:0 animated:NO];
        [picker selectRow:1 inComponent:1 animated:NO];
        
    }
    if([self.seatLetterTxt.text length]>0) {
        NSString *seatLetter = self.seatLetterTxt.text;
        
        int index = [array3 indexOfObject:seatLetter];
        
        [picker selectRow:index inComponent:2 animated:NO];
        
    }
    
}
-(void) seatnumSelectionDone {
    int seatIndex1 = [picker selectedRowInComponent:0];
    
    if(!(seatIndex1>=0))
        seatIndex1=0;
    int seatIndex2 = [picker selectedRowInComponent:1];
    if(!(seatIndex2>=0))
        seatIndex2=0;
    int seatIndex3 = [picker selectedRowInComponent:2];
    if(!(seatIndex3>=0))
        seatIndex3=0;
    if(seatIndex1 == 0 && seatIndex2 == 0) {
        
        self.seatRowTxt.text = @"01";
        
    }   
    else{
    
    self.seatRowTxt.text = [NSString stringWithFormat:@"%@%@",[array1 objectAtIndex:seatIndex1],[array2 objectAtIndex:seatIndex2]];
    
    
    }
    self.seatLetterTxt.text = [NSString stringWithFormat:@"%@",[array3 objectAtIndex:seatIndex3]];
    if([self.delegate respondsToSelector:@selector(valueSelectedInPopover:)])
    {
        [self.delegate valuesSelectedInPopOver:self.seatRowTxt];
        [self.delegate valuesSelectedInPopOver:self.seatLetterTxt];
    }
    [pop dismissPopoverAnimated:NO];
}
-(void) seatnumSelectionCanceled {
    [pop dismissPopoverAnimated:YES];
    
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover{
    [self seatnumSelectionDone];
    
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}
-(void)valuesSelectedInPopOver:(UITextField *)textFields{
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    int count = 0;
    switch (component) {
        case 0:
            count = [array1 count];
            break;
        case 1:
            count = [array2 count];
            break;
        case 2:
            count = [array3 count];
            break;
            
        default:
            break;
    }
    return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *array = nil;
    
    switch (component) {
        case 0:
            array =  array1;
            break;
        case 1:
            array =  array2;
            break;
        case 2:
            array =  array3;
            break;
            
        default:
            break;
    }
    return [array objectAtIndex:row];
}

@end
