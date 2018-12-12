//
//  LTAddCustomerViewController.m
//  Nimbus2
//
//  Created by Dreamer on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "LTAddCustomerViewController.h"
#import "AppDelegate.h"
#import "DropDownViewController.h"
#import "AlertUtils.h"
#import "LTCUSDropdownData.h"
#import "Customer.h"
#import "LTSingleton.h"
#import "Legs.h"
#import "LTSaveCUSData.h"
#import "SaveSeatMap.h"

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface LTAddCustomerViewController (){
    UITextField *currentTextField;
    AppDelegate *appDel;
    Legs *currentleg;
    
}

@end

@implementation LTAddCustomerViewController
@synthesize seatNumber,allseats;

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirst = NO;
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    currentLegNumber = [LTSingleton getSharedSingletonInstance].legNumber;

    self.addCustomerView.layer.cornerRadius = 10.0f;
    
    NSString *origin = [[[[[LTSingleton getSharedSingletonInstance] flightRoasterDict] objectForKey:@"legs"] objectAtIndex:currentLegNumber] objectForKey:@"origin"];
    NSString *destination = [[[[[LTSingleton getSharedSingletonInstance] flightRoasterDict] objectForKey:@"legs"] objectAtIndex:currentLegNumber] objectForKey:@"destination"];
    NSString *departureLocal = [[[[[LTSingleton getSharedSingletonInstance] flightRoasterDict] objectForKey:@"legs"] objectAtIndex:currentLegNumber] objectForKey:@"departureLocal"];
    NSString *arrivalLocal = [[[[[LTSingleton getSharedSingletonInstance] flightRoasterDict] objectForKey:@"legs"] objectAtIndex:currentLegNumber] objectForKey:@"arrivalLocal"];


    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Legs"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination==%@ AND legDepartureLocal==%@ AND legArrivalLocal==%@",origin,destination,departureLocal,arrivalLocal];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [self.localMoc executeFetchRequest:request error:&error];
    
    currentleg = (Legs *)[result objectAtIndex:0];
    

    
    [self.addNewCustomerTitle setText:[appDel copyTextForKey:@"ADD_CUS_Title"]];
    
    self.seatNumberLabel.attributedText = [[[appDel copyTextForKey:@"SELECT_SEAT"] stringByAppendingString:@"*"] mandatoryString];
    self.firstNameLabel.attributedText = [[[appDel copyTextForKey:@"FIRST_NAME"] stringByAppendingString:@"*"] mandatoryString];
    self.firstNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameLabel.attributedText = [[[appDel copyTextForKey:@"LAST_NAME"] stringByAppendingString:@"*"] mandatoryString];
    self.secondLastNameLabel.text = [appDel copyTextForKey:@"SECOND_LAST_NAME"];
    self.docTypeLabel.attributedText = [[[appDel copyTextForKey:@"DOCUMENT_TYPE"] stringByAppendingString:@"*"] mandatoryString];
    self.docNumberLabel.attributedText = [[[appDel copyTextForKey:@"DOCUMENT_NUMBER"] stringByAppendingString:@"*"] mandatoryString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keboardDissmissed:) name:@"UIKeyboardWillHideNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    self.seatNumberTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    if(seatNumber) {
        self.seatNumberTextField.text = seatNumber;
        self.seatNumberTextField.enabled = false;
    }

    self.docTypeView.delegate = self;
    self.docTypeView.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"] forDocType:@"LAN"];
    self.docTypeView.typeOfDropDown = NormalDropDown;
    self.docTypeView.key =[appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"];
    self.docTypeView.dropDownButton.backgroundColor = [UIColor clearColor];
    self.docTypeView.selectedTextField.textAlignment = NSTextAlignmentRight;
  
    self.docTypeView.backgroundColor = [UIColor clearColor];
        self.docTypeView.selectedTextField.backgroundColor = [UIColor clearColor];
    self.docTypeView.dropDownButton.backgroundColor = [UIColor clearColor];
    
        self.firstNameTextField.font = KRobotoFontSize20;
    self.firstNameTextField.textColor = KRobotoFontColorGray;

    self.lastnameTextField.font = KRobotoFontSize20;
    self.lastnameTextField.textColor = KRobotoFontColorGray;
    
    self.secondLastNameTextField.font = KRobotoFontSize20;
    self.secondLastNameTextField.textColor = KRobotoFontColorGray;

    self.docTypeView.selectedTextField.font = KRobotoFontSize20;
    self.docTypeView.selectedTextField.textColor = KRobotoFontColorGray;

    self.docNumberTextField.font = KRobotoFontSize20;
    self.docNumberTextField.textColor = KRobotoFontColorGray;
    
    [self.doneButton setTitle:[appDel copyTextForKey:@"SAVE_LABEL"] forState:UIControlStateNormal];
    self.firstNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.secondLastNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastnameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self orientationChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

}

-(void) orientationChanged {
    dispatch_async(dispatch_get_main_queue(), ^{

    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
            
            self.addcustomerLeadingConstraint.constant=100;
            self.addcustomerTopConstraint.constant=324;
            self.view.frame=CGRectMake(0, 0,768, 1024);
        }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            self.view.frame=CGRectMake(0, 0,1024, 768);
            self.addcustomerLeadingConstraint.constant=197;
            self.addcustomerTopConstraint.constant=210;
        }
        if (self.activeTestView != nil) {
            UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            [self.activeTestView willRotateToOrientation:toInterfaceOrientation];
        }
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)closeButtonTapped:(id)sender {
    
    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
}

- (IBAction)doneButtonTapped:(id)sender {
    
    if ([self validateAllTextfieds]){
        [self.view removeFromSuperview];
        
        NSArray *array;
        if([array count] > 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_CUS_EXITSTS"] delegate:nil cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
        }
        else {
            
            NSString *docType = [NSString stringWithFormat:@"%d||%@",self.docTypeView.selectedIndex,self.docTypeView.selectedTextField.text];
            
            customerDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.firstNameTextField.text,@"FIRST_NAME",self.lastnameTextField.text,@"LAST_NAME",self.secondLastNameTextField.text,@"SECOND_LAST_NAME",docType,@"DOCUMENT_TYPE",self.docNumberTextField.text,@"DOCUMENT_NUMBER",[NSNumber numberWithInt:draft],@"STATUS",[NSDate date],@"DATE", self.seatNumberTextField.text,@"SEAT_NUMBER",[NSNumber numberWithBool:_seatMapExists],@"SEATMAP_EXIST", nil];
            
            NSString *temp = [SaveSeatMap customerExists:[LTSingleton getSharedSingletonInstance].flightRoasterDict andCustomerDict:customerDict legNumber:[LTSingleton getSharedSingletonInstance].legNumber];
            
            if (temp==nil) {
                [SaveSeatMap saveCustomerForFlight:[LTSingleton getSharedSingletonInstance].flightRoasterDict andCustomerDict:customerDict legNumber:[LTSingleton getSharedSingletonInstance].legNumber];
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[appDel copyTextForKey:@"SEAT"],self.seatNumberTextField.text,[appDel copyTextForKey:@"OCCUPIED_BY_PASSENGER"],temp,[appDel copyTextForKey:@"DO_YOU_WANT_TO_REPLACE"]] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ACCEPT"], nil];
                alert.tag = 850;
                [alert show];
            }
            
            [currentTextField resignFirstResponder];
            [self.view setBackgroundColor:[UIColor clearColor]];
            
            if([self.delegate respondsToSelector:@selector(finishedEnteringNewCustomer)])
                [self.delegate finishedEnteringNewCustomer];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     if(alertView.tag == 850) {
         if(buttonIndex == 1) {
             [SaveSeatMap saveCustomerForFlight:[LTSingleton getSharedSingletonInstance].flightRoasterDict andCustomerDict:customerDict legNumber:[LTSingleton getSharedSingletonInstance].legNumber];
             
             if([self.delegate respondsToSelector:@selector(finishedEnteringNewCustomer)])
                 [self.delegate finishedEnteringNewCustomer];
         }
    }
}

-(BOOL)validateAllTextfieds {
    [self.firstNameTextField resignFirstResponder];
    [self.lastnameTextField resignFirstResponder];
    [self.docNumberTextField resignFirstResponder];
    [self.secondLastNameTextField resignFirstResponder];
    isFirst = YES;
    BOOL isValid= YES;
    
    if (!seatNumber) {
    
    if(![self validateSeatNumber:self.seatNumberTextField.text]) {
        isValid = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"INVALID_SEAT"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return isValid;

        
    }
    }
    
    if([self.firstNameTextField.text length] == 0) {
        
        self.firstNameTextField.layer.borderColor = [[UIColor redColor] CGColor] ;
        
        isValid = NO;
    }
    if([self.lastnameTextField.text length] == 0) {
        
        self.lastnameTextField.layer.borderColor = [[UIColor redColor] CGColor];
        isValid = NO;
    }
    
    if([self.docNumberTextField.text length] == 0){
        
        self.docNumberTextField.layer.borderColor = [[UIColor redColor] CGColor];
        
        isValid = NO;
        
    }
    if([self.docTypeView.selectedTextField.text length] == 0){
        self.docTypeView.selectedTextField.layer.borderColor = [[UIColor redColor] CGColor];
        isValid = NO;
        
    }
    if(!isValid) {
        if ([AlertUtils checkAlertExist]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_MANDATORY_FIELDS"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
        }
    } else {
        
        if([docValidationDict allKeys] > 0) {
            if(![self.docTypeView.selectedTextField.text isEqualToString:@"Otro"]) {
                
                if([self.docNumberTextField.text validateStringWithRegExprestion:[[[docValidationDict objectForKey:@"RegExpression"] allKeys] objectAtIndex:0]]) {
                    return isValid;
                }
                else {
                    self.docTypeHelpLabel.text = [NSString stringWithFormat:@"%@ (%@%@)",[appDel copyTextForKey:@"SAMPLE_DOCUMENT_TYPE"],[appDel copyTextForKey:@"EXAMPLE"],[[[docValidationDict objectForKey:@"Example"] allKeys] objectAtIndex:0] ];
                    
                    [AlertUtils showErrorAlertWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_VALID_DOCUMENT_NUMBER"]];
                    return NO;
                }
            }
        } else {
            return isValid;
        }
    }
    return isValid;
}

-(BOOL)validateSeatNumber:(NSString *)seatno {
    
    if(!seatno || seatno.length < 2) {
        return NO;
    }
    
    if ([allseats indexOfObject:seatno] != NSNotFound) {
        _seatMapExists = YES;
        return YES;
    }
    if ((!_seatMapExists && seatno.length != 0 ) || [allseats count] == 0) {
        NSCharacterSet *alphanumericSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        _seatMapExists = NO;
        NSString *column = [seatno substringFromIndex:seatno.length - 1] ;
        NSString *trimmedString = [[seatno substringToIndex:seatno.length - 1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        NSInteger len = seatno.length;
        NSString * first;
        if (len == 2) {
            first = [seatno substringToIndex:seatno.length - 1];
        } else if (len == 3) {
            first = [seatno substringToIndex:seatno.length - 2];
        }
        if ([first isEqualToString:@"0"]) {
            return NO;
        }
        //  NSString * seatRow = [seatno substringToIndex:seatno.length-1] ;
        if (trimmedString.length == 0 && [alphanumericSet characterIsMember:[column characterAtIndex:0]])
            return YES;
    }
    
    return NO;
}

- (IBAction)documentTypeButtonTapped:(id)sender {
    
}

#pragma mark - Popover Delegate Methods
-(void)valueSelectedInPopover:(TestView *)testView {
    
    docValidationDict =  [LTCUSDropdownData getDictForKey:testView.selectedTextField.text];
    
    if(nil != docValidationDict){
        self.docNumberTextField.placeholder = [[[docValidationDict objectForKey:@"Example"] allKeys] objectAtIndex:0];
        self.docTypeHelpLabel.text = @"";
        [self.docNumberTextField becomeFirstResponder];
    }
    
}

#pragma mark - Textfield Delegates

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    
//    return YES;
//}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    currentTextField = textField;
    CGRect frame = self.view.frame;
    
    if (textField == self.firstNameTextField)
        frame.origin.y = -30;
    else if (textField == self.lastnameTextField)
        frame.origin.y = -70;
    else if (textField == self.secondLastNameTextField)
             frame.origin.y = -110;
    else if (textField == self.docNumberTextField)
        frame.origin.y = -180;

    [UIView animateWithDuration:0.2 animations:^{
        [self.view setFrame:frame];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    currentTextField = textField;
    CGRect frame = self.view.frame;

    
    if (textField == self.secondLastNameTextField)
        frame.origin.y = 0;
    else if (textField == self.docNumberTextField)
        frame.origin.y = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setFrame:frame];
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if([string length] == 0 && range.location == 0 && isFirst  && textField.tag == MANDATORYTAG){
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    if(textField == self.docNumberTextField) {
        
        if([self.docTypeView.selectedTextField.text isEqualToString:@"Otro"])
            return YES;
        
        NSString *string1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if([docValidationDict allKeys] > 0) {
            
            if([string1 validateStringWithRegExprestion:[[[docValidationDict objectForKey:@"RegExpression"] allKeys] objectAtIndex:0] ]) {
                self.docTypeHelpLabel.text = @"";
            }
            else {
                
            }
        }
    }
    
    if(textField == self.seatNumberTextField) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];

        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if (![string isEqualToString:filtered]) {
            return false;
        }
        
        NSRange lowercaseCharRange;
        lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        
        int length = (int)[textField.text length] ;
        
        if (lowercaseCharRange.location != NSNotFound || (length >= 3 && ![string isEqualToString:@""])) {
            
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            if ([textField.text length] > 3)
            textField.text = [textField.text substringToIndex:3];

            return NO;
        }
    }
    
    return YES;
}

static CGFloat leftMargin = 15;

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    
    return bounds;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    return YES;
}

-(void)navigateField:(UISegmentedControl *)segControl
{
    if(segControl.selectedSegmentIndex ==1) {
        if(currentTextField == self.firstNameTextField){
            [self.lastnameTextField becomeFirstResponder];
        }else if(currentTextField == self.lastnameTextField){
            [self.secondLastNameTextField becomeFirstResponder];
        }else if(currentTextField == self.secondLastNameTextField){
            [self.docNumberTextField becomeFirstResponder];
        }
    }else {
        if(currentTextField == self.lastnameTextField){
            [self.firstNameTextField becomeFirstResponder];
        }else if(currentTextField == self.secondLastNameTextField){
            [self.lastnameTextField becomeFirstResponder];
        }
        else if(currentTextField == self.docNumberTextField){
            [self.secondLastNameTextField becomeFirstResponder];
        }
    }
}

-(void)keboardWillShow:(id)sender {

}

-(void)keboardDissmissed:(id)sender {
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setFrame:frame];
    }];

    
    
}

@end
