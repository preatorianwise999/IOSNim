//
//  LTAddGADViewController.m
//  LATAM
//
//  Created by Madhu on 5/15/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTAddGADViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LTSelectRankViewController.h"
#import "AppDelegate.h"
#import "LTGetLightData.h"
#import "LTSingleton.h"

@interface LTAddGADViewController ()
{
  AppDelegate *appDel;
    
    
}
@end
@implementation LTAddGADViewController
@synthesize firstNameField=_firstNameField;
@synthesize lastNameField=_lastNameField;
@synthesize bpField=_bpField;
@synthesize delegate=_delegate;
@synthesize activeArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self orientationChanged];
    // self.view.superview.layer.cornerRadius = 0;
      [self.currentView.layer setCornerRadius:20.0f];
    //[self.headerView.layer setCornerRadius:10.0f];
   // [self.footerView.layer setCornerRadius:10.0f];

    DLog(@" activeRankArray %@",self.activeArray);
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];

    //[self.view setFrame:CGRectMake(250, 250, 542, 360)];
    
}
-(void)orientationChanged{
    dispatch_async(dispatch_get_main_queue(), ^{

    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.topConstraint.constant=200;
        self.leadingSpaceConstraint.constant=250;
        
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        self.topConstraint.constant=200;
        self.leadingSpaceConstraint.constant=100;
    }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view from its nib.
   // self.view.layer.cornerRadius = 0.5;
    
    self.firstNameFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
    self.firstNameFieldBGView.layer.borderWidth = 1.0;
    self.firstNameFieldBGView.backgroundColor = [UIColor whiteColor];
    
    self.lastNameFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
    self.lastNameFieldBGView.layer.borderWidth = 1.0;
    self.lastNameFieldBGView.backgroundColor = [UIColor whiteColor];
    
    self.bpFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
    self.bpFieldBGView.layer.borderWidth = 1.0;
    self.bpFieldBGView.backgroundColor = [UIColor whiteColor];
    
    self.rankBGViewBGView.layer.borderColor = [UIColor clearColor].CGColor;
    self.rankBGViewBGView.layer.borderWidth = 1.0;
    self.rankBGViewBGView.backgroundColor = [UIColor whiteColor];
    
    appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;

    self.firstNameLabel.attributedText =[[[appDel copyTextForKey:@"FIRST_NAME"] stringByAppendingString:@"*"] mandatoryString];
    self.lastNameLabel.attributedText =[[[appDel copyTextForKey:@"LAST_NAME"]stringByAppendingString:@"*"] mandatoryString];
    self.bpLabel.attributedText =[[[appDel copyTextForKey:@"BP"]stringByAppendingString:@"*"] mandatoryString];
    self.rankLabel.attributedText =[[[appDel copyTextForKey:@"Rank"]stringByAppendingString:@"*"] mandatoryString];

    self.addCrewMemberLabel.text =[appDel copyTextForKey:@"Add_CREW_MEMBER"];
    [self.saveBtn setTitle:[appDel copyTextForKey:@"SAVE_LABEL"]forState:UIControlStateNormal];
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"rankValue"];
    if (savedValue) {
        [self.rankBtn setTitle:savedValue forState:UIControlStateNormal];
    }
    else {
        [self.rankBtn setTitle:[self.activeArray firstObject] forState:UIControlStateNormal];
    }

    DLog(@" activeRankArray %@",self.activeArray);
}

-(IBAction)closeButtonClicked:(id)sender {

    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
}

-(void)closePopOver{
    
    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
}
-(IBAction)saveButtonClicked:(id)sender {
    
    _firstNameField.text = [_firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _lastNameField.text = [_lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _bpField.text = [_bpField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    BOOL fieldsEmpty = NO;
    BOOL crewExists = NO;
    
    if ([_firstNameField.text isEqualToString:@""]) {
        fieldsEmpty = YES;
        self.firstNameFieldBGView.layer.borderColor = [UIColor redColor].CGColor;
    }
    if ([_lastNameField.text isEqualToString:@""]) {
        fieldsEmpty = YES;
         self.lastNameFieldBGView.layer.borderColor = [UIColor redColor].CGColor;
    }
    if ([_bpField.text isEqualToString:@""]) {
        fieldsEmpty = YES;
        self.bpFieldBGView.layer.borderColor = [UIColor redColor].CGColor;
    }
    
    NSArray *crewMembersArray = (NSMutableArray *)[LTGetLightData getFlightCrewForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:self.currentLeg];
    for(NSDictionary *dict in crewMembersArray) {
        if([dict[@"bp"] intValue] == [_bpField.text intValue]) {
            crewExists = YES;
        }
    }
    
    if (fieldsEmpty) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[appDel copyTextForKey:@"Add_CREW_MEMBER"] message:[appDel copyTextForKey:@"REQUIRED_FIELD_IS_EMPTY"] delegate:nil cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil];
        [alert show];
    }
    
    else if (crewExists) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[appDel copyTextForKey:@"Add_CREW_MEMBER"] message:[appDel copyTextForKey:@"CREW_EXISTS_ERROR"] delegate:nil cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil];
        [alert show];
        
        self.bpFieldBGView.layer.borderColor = [UIColor redColor].CGColor;
    }
    
    else {
        
        [self closePopOver];
        BOOL isSuccess =  [_delegate flightCrewFirstName:_firstNameField.text amdLastName:_lastNameField.text andbpNumber:_bpField.text rankValue:self.rankBtn.titleLabel.text];
        if (isSuccess) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


-(IBAction)selectRank:(id)sender {
    
     float height = 50 * [self.activeArray count];
    
    self.selectRankViewController=[[LTSelectRankViewController alloc] initWithNibName:@"LTSelectRankViewController" bundle:nil];
   // self.selectRankViewController.view.frame = CGRectMake(400, 400, 150, 200);
    self.selectRankViewController.activeRankArray =self.activeArray;

    _selectRankPopOverController = [[UIPopoverController alloc] initWithContentViewController: self.selectRankViewController];
    self.selectRankViewController.presentedPopOverController = _selectRankPopOverController;

    _selectRankPopOverController.popoverContentSize = CGSizeMake(150, height);
    
     self.selectRankViewController.delegate = self;
    CGRect  frame =   CGRectMake(500, 470, 150, 200);
    
   // [_selectRankPopOverController presentPopoverFromRect:_rankBGViewBGView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    [_selectRankPopOverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if([textField isEqual:self.bpField]) {
        
        if(concatText.length > 8) {
            textField.text = [concatText substringToIndex:8];
            return NO;
        }
        else if(![concatText validateNumeric]) {
            return NO;
        }
    }
    if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    return YES;
}


#pragma mark- textFeild delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    __block CGRect frame = self.view.frame;
    if (textField==self.lastNameField) {
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y= -30;
            frame.origin.x = 0;
            [self.view setFrame:frame];
        }];

    } else if (textField==self.bpField) {
        frame.origin.y = -80;
        frame.origin.x = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setFrame:frame];
        }];
    }
    return TRUE;
}

// return NO to disallow editing.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    CGRect frame = self.view.frame;
    if (textField==self.lastNameField) {
        [self.bpField becomeFirstResponder];
    } else if (textField==self.bpField) {
        frame.origin.y = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setFrame:frame];
        }];
        [textField resignFirstResponder];
    }
    return TRUE;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    if (textField==self.lastNameField) {
        [self.bpField becomeFirstResponder];
    }else if (textField==self.bpField){
        frame.origin.y = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setFrame:frame];
        }];
        [textField resignFirstResponder];
    }
    
    _firstNameField.text = [_firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _lastNameField.text = [_lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _bpField.text = [_bpField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    

    if ([_firstNameField.text length]>0)
        self.firstNameFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
    if ([_lastNameField.text length]>0)
        self.lastNameFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
    if ([_bpField.text length]>0)
        self.bpFieldBGView.layer.borderColor = [UIColor clearColor].CGColor;
}

# pragma mark rank delegate
-(void)selectedRankString:(NSString *)rank
{
    [self.rankBtn setTitle:rank forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
