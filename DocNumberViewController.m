//
//  DocNumberCPopoverControllerViewController.m
//  Nimbus2
//
//  Created by vishal on 12/1/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import "DocNumberViewController.h"
#import "AppDelegate.h"
#import "LTCUSDropdownData.h"
#import "AlertUtils.h"

@interface DocNumberViewController () {
}

@end

@implementation DocNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _docNumberField.delegate = self;
    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _docNumberField.placeholder =[appDel copyTextForKey:@"DOC_NUMBER"];
    _docNumberLabel.text = [appDel copyTextForKey:@"DOC_LABEL_TEXT"];
    
    [self.doneButton setTitle:[appDel copyTextForKey:@"ACCEPT"]forState:UIControlStateNormal];
    [self.cancelBtn setTitle:[appDel copyTextForKey:@"CANCEL"]forState:UIControlStateNormal];
    self.docTypeLabel.text = [appDel copyTextForKey:@"DOCUMENT_TYPE"];

    self.docTypeView.delegate = self;
    self.docTypeView.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"] forDocType:@"LAN"];
    self.docTypeView.typeOfDropDown = NormalDropDown;
    self.docTypeView.key = [appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"];
    self.docTypeView.dropDownButton.backgroundColor = [UIColor clearColor];
    self.docTypeView.selectedTextField.textAlignment = NSTextAlignmentRight;
    
    self.docTypeView.backgroundColor = [UIColor clearColor];
    self.docTypeView.selectedTextField.backgroundColor = [UIColor clearColor];
    self.docTypeView.selectedTextField.borderStyle = UITextBorderStyleLine;

    self.docTypeView.dropDownButton.backgroundColor = [UIColor clearColor];
    self.docTypeView.selectedTextField.font = KRobotoFontSize20;
    self.docTypeView.selectedTextField.textColor = KRobotoFontColorGray;
    //_doneButton.titleLabel.text = [appDel copyTextForKey:@"ACCEPT"];
   // _cancelBtn.titleLabel.text = [appDel copyTextForKey:@"CANCEL"];

    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    // @NOTE(diego_cath): LAN requested that document type be always set to "Otro"
    self.docTypeView.selectedTextField.text = @"Otro";
    for(UIView *view in self.docTypeView.subviews) {
        view.hidden = YES;
    }
}

- (void)orientationChanged {
    if (self.activeTestView != nil) {
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self.activeTestView willRotateToOrientation:toInterfaceOrientation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    id sender;
  //  [_delegate doneBtnTapped];
    
}
#pragma mark - Popover Delegate Methods
-(void)valueSelectedInPopover:(TestView *)testView {
    
    docValidationDict =  [LTCUSDropdownData getDictForKey:testView.selectedTextField.text];
    if ([self.docTypeView.selectedTextField.text isEqualToString:@"Otro"])
        self.doneButton.enabled = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _doneButton.enabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if(textField == _docNumberField) {
        
        if([self.docTypeView.selectedTextField.text isEqualToString:@"Otro"])
            return YES;
        
        NSString *string1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if([docValidationDict allKeys] > 0) {
            
            if([string1 validateStringWithRegExprestion:[[[docValidationDict objectForKey:@"RegExpression"] allKeys] objectAtIndex:0] ]) {
                
            }
            else {
                
            }
        }
    }
    
    if ([_docNumberField.text isEqualToString:@""])
        _doneButton.enabled = NO;
    else
        _doneButton.enabled = YES;
    
    return YES;
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [_delegate cancelBtnTapped];
}

- (IBAction)doneButtonTapped:(id)sender {
    if ([self validateAllFields]) {
        [_delegate doneBtnTapped];
    }
}

-(BOOL)validateAllFields {
    
    BOOL isValid = YES;
    
    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([_docNumberField.text length] == 0) {
        _docNumberField.layer.borderColor = [[UIColor redColor] CGColor];
        isValid = NO;
    }
    
    if([self.docTypeView.selectedTextField.text length] == 0) {
        self.docTypeView.selectedTextField.layer.borderColor = [[UIColor redColor] CGColor];
        isValid = NO;
    }
    
    if ([self.docTypeView.selectedTextField.text isEqualToString:@"Otro"]) {
        self.doneButton.enabled = YES;
        return YES;
    }
    
    if(!isValid) {
        if ([AlertUtils checkAlertExist]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_MANDATORY_FIELDS"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil, nil];
            [alert show];
            isValid = YES;
            return NO;

        }
    } else {
        
        if([docValidationDict allKeys] > 0) {
            if(![self.docTypeView.selectedTextField.text isEqualToString:@"Otro"]) {
                
                if([_docNumberField.text validateStringWithRegExprestion:[[[docValidationDict objectForKey:@"RegExpression"] allKeys] objectAtIndex:0]]) {
                    return isValid;
                } else {
                    [AlertUtils showErrorAlertWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_VALID_DOCUMENT_NUMBER"]];
                    _docNumberField.placeholder = [[[docValidationDict objectForKey:@"Example"] allKeys]objectAtIndex:0];
                    return NO;
                }
            }
        } else {
            return isValid;
        }
    }
    return isValid;
}

@end
