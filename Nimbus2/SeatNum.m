//
//  SeatNum.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "SeatNum.h"
#import "SeatNumViewController.h"
@implementation SeatNum


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}
-(void)awakeFromNib {
    self.seatLetterTxt.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.seatLetterTxt.layer.borderWidth = 1.0f;
    self.seatLetterTxt.backgroundColor = [UIColor whiteColor];
    
    self.seatRowTxt.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.seatRowTxt.layer.borderWidth = 1.0f;
    self.seatRowTxt.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)onClickSeatRow:(UIButton *)sender {
    
    SeatNumViewController *testViewController = [[SeatNumViewController alloc] initWithNibName:@"SeatNumViewController" bundle:nil];
    testViewController.tempCell = self;
    testViewController.delgate = self;
    array1 =  @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    array2 =  @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    array3 = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L"];
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, 320, 216.0)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    
    pop = [[UIPopoverController alloc] initWithContentViewController:testViewController];
    [testViewController.view addSubview:picker];
    [pop setDelegate:self];
    [pop presentPopoverFromRect:CGRectMake(0, 0, self.button.frame.size.width, 50 )
                         inView:self.button permittedArrowDirections:UIPopoverArrowDirectionDown
                       animated:YES];
    
    [pop setPopoverContentSize:CGSizeMake(320, 300) animated:NO];
    
    if([self.seatRowTxt.text length]>0){
        int seatValue =  [self.seatRowTxt.text intValue];
        
        int temp1 = seatValue/10;
        int temp2 = seatValue%10;
        
        [picker selectRow:temp1 inComponent:0 animated:NO];
        [picker selectRow:temp2 inComponent:1 animated:NO];
        
    }
    else {
        [picker selectRow:1 inComponent:0 animated:NO];
        [picker selectRow:1 inComponent:1 animated:NO];

    }
    if([self.seatLetterTxt.text length]>0) {
        NSString *seatLetter = self.seatLetterTxt.text;
        
        int index = [array3 indexOfObject:seatLetter];
        
        [picker selectRow:index inComponent:2 animated:NO];
        
    }
    
}

- (void) seatnumSelectionDone {
    int seatIndex1 = [picker selectedRowInComponent:0];
    
    if(seatIndex1 < 0)
        seatIndex1 = 0;
    int seatIndex2 = [picker selectedRowInComponent:1];
    if(seatIndex2 < 0)
        seatIndex2 = 0;
    int seatIndex3 = [picker selectedRowInComponent:2];
    if(seatIndex3 < 0)
        seatIndex3 = 0;
    
    if(seatIndex1 == 0 && seatIndex2 == 0) {
        self.seatRowTxt.text = @"01";
    }
    else {
        self.seatRowTxt.text = [NSString stringWithFormat:@"%@%@",[array1 objectAtIndex:seatIndex1], [array2 objectAtIndex:seatIndex2]];
    }
    
    self.seatLetterTxt.text = [NSString stringWithFormat:@"%@",[array3 objectAtIndex:seatIndex3]];
    if([self.delegate respondsToSelector:@selector(valueSelectedInPopover:)]) {
        [self.delegate valuesSelectedInPopOver:self.seatRowTxt];
        [self.delegate valuesSelectedInPopOver:self.seatLetterTxt];
    }
    [pop dismissPopoverAnimated:YES];
}

-(void) seatnumSelectionCanceled {
    [pop dismissPopoverAnimated:YES];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover{
    [self seatnumSelectionDone];
    
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int seatIndex1 = [pickerView selectedRowInComponent:0];
    int seatIndex2 = [pickerView selectedRowInComponent:1];

    if(seatIndex1 == 0 && seatIndex2 == 0){
        [picker selectRow:0 inComponent:0 animated:NO];
        [picker selectRow:1 inComponent:1 animated:NO];
    }
}

@end
