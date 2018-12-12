//
//  AddManualFlightViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "AddManualFlightViewController.h"
#import "FlightRoaster.h"
#import "AlertUtils.h"
#import "SynchronizationController.h"


@interface AddManualFlightViewController ()<SynchDelegate>
{
    NSMutableArray *companyArray;
    NSArray *materialArray;
    UIDatePicker *datePicker;
    UIPopoverController *popOverCont;
    NSIndexPath *deleteIndexPath_verify;
    NSIndexPath *deleteIndexPath;
    NSIndexPath *responderIndexPath;
    BOOL nextResponder;
    BOOL becomeResponder;
    int selectedIndex;
    CGFloat yPosition;
    NSString *errorMsg;
    NSMutableArray *flightNumberArray;
    NSMutableArray *flightTypeButtonArray;
    NSMutableArray *flightDateButtonArray;
    BOOL arrivalLessThanDeparture;
    BOOL differentDayOfDeparture;
    BOOL isGreaterThanEqualToLegDepDate;
    BOOL isLessThanEqualToDepartureDate;
}

@property (weak, nonatomic) IBOutlet UILabel *addFlightTitleLb;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *prefixLb;
@property (weak, nonatomic) IBOutlet UILabel *flightNumberLb;
@property (weak, nonatomic) IBOutlet UILabel *flightDateLb;
@property (weak, nonatomic) IBOutlet UIButton *getDataBtn;
@property (weak, nonatomic) IBOutlet UILabel *materialLb;
@property (weak, nonatomic) IBOutlet UILabel *matriculaLb;

@property (weak, nonatomic) IBOutlet UILabel *infoTitleLb;

@end

@implementation AddManualFlightViewController
@synthesize mode,legDataArray,flightDataDict;
-(void)setup{
    
    self.legDataArray = [[NSMutableArray alloc] init];
    if(!synch)
    synch = [[SynchronizationController alloc] init];
    
    if([self.legDataArray count] == 0){
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
        [self.legDataArray addObject:legDict];
        CGRect tableFrame = _legTableView.frame;
        _legTableView.frame = tableFrame;
    }
    self.legTableView.backgroundColor= [UIColor clearColor];
    
    if ([self.legDataArray count]+1 > 0) {
        
    }else{
        CGRect tableFrame = _legTableView.frame;
        _legTableView.frame = tableFrame;
    }
    [_legTableView setEditing:YES];
    
    
}
-(id)initWithFlightDataObject:(NSMutableDictionary *)flightDictionary WithMode:(enum flightAddMode)flightMode{
    
    self = [self initWithNibName:@"AddManualFlightViewController" bundle:nil];
    if(self){
        if (flightDictionary!=nil) {
            //**********Dont use flightRoaster object******
            flightDict = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)flightDictionary, kCFPropertyListMutableContainers));;
            NSArray *legArray = [flightDict objectForKey:@"legs"];
            for (NSMutableDictionary *legDict in legArray) {
                [legDict setObject:[legDict objectForKey:@"departureLocal"] forKey:@"legDepartureLocal"];
                [legDict setObject:[legDict objectForKey:@"arrivalLocal"] forKey:@"legArrivalLocal"];
                [legDict removeObjectForKey:@"departureLocal"];
                [legDict removeObjectForKey:@"arrivalLocal"];
                
            }
        }
        flightDataDict = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)flightDict, kCFPropertyListMutableContainers));
        
        
        mode = flightMode;
    }
    
    return self;
}

-(void)prePopulateData {
    [self.flightTypeButton setTitle:[[flightDataDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] forState:UIControlStateNormal];
    self.flightNumberTextView.text = [[flightDataDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
    [self.flightDateButton setTitle:[dateFormatter stringFromDate:[[flightDataDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]] forState:UIControlStateNormal];
    if ([[flightDataDict objectForKey:@"legs"] count] > 0) {

       // NSMutableDictionary *crewDict = [[legDict objectForKey:@"crew"] objectAtIndex:0];
     }
    
    [self.materialButton setTitle:[flightDataDict objectForKey:@"material"] forState:UIControlStateNormal];
    
    self.matriculaTextView.text = [flightDataDict objectForKey:@"tailNumber"];
    self.legDataArray = [flightDataDict objectForKey:@"legs"];
    dateFormatter  = nil;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!flightDict) {
        flightDict = [[NSMutableDictionary alloc] init];
    }
    if (mode==Modify) {
        [self.trashBtn setHidden:NO];
    }
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //texts
    
    self.addFlightTitleLb.text = [appDel copyTextForKey:@"MF_ADD_TITLE"];
    self.prefixLb.text = [appDel copyTextForKey:@"MF_PREFIX"];
    self.flightNumberLb.text = [appDel copyTextForKey:@"MF_FLIGHT_NUMBER"];
    self.flightDateLb.text = [appDel copyTextForKey:@"MF_DATE"];
    [self.getDataBtn setTitle:[appDel copyTextForKey:@"MF_GET_DATA"] forState:UIControlStateNormal];
    self.materialLb.text = [appDel copyTextForKey:@"MF_MATERIAL"];
    self.matriculaLb.text = [appDel copyTextForKey:@"MF_LICENSE"];
    
    self.infoTitleLb.text = [appDel copyTextForKey:@"MF_LEG_INFO"];
    
    [self.addBtn setTitle:[appDel copyTextForKey:@"MF_ADD_BTN"] forState:UIControlStateNormal];
    
    yPosition = 0.0;
    arrivalLessThanDeparture = NO;
    differentDayOfDeparture = YES;
    isGreaterThanEqualToLegDepDate = NO;
    deleteIndexPath = [NSIndexPath indexPathForItem:-1 inSection:-1];
    deleteIndexPath_verify= [NSIndexPath indexPathForItem:-1 inSection:-1];
    departDateManually = YES;
    manualEnter = YES;
    selectedIndex = -1;
    nextResponder = NO;
    becomeResponder = NO;
    flightDictSave = [[NSMutableDictionary alloc] init];
    self.legDataArray = [[NSMutableArray alloc] init];
    if(flightDataDict) {
        [self prePopulateData];
    }
    else {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
//        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
//        self.flightDateButton.titleLabel.text = [dateFormatter stringFromDate:[NSDate date]];
//        dateFormatter = nil;
//        flightDate = [NSDate date];
    }
    if([self.legDataArray count] == 0){
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
        [self.legDataArray addObject:legDict];
        CGRect tableFrame = _legTableView.frame;
        _legTableView.frame = tableFrame;
    }
    [self.legTableView setEditing:YES];
    
    if ([self.legDataArray count] + 1 > 0) {
        
    } else {
        CGRect tableFrame = _legTableView.frame;
        _legTableView.frame = tableFrame;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    companyArray = [[NSMutableArray alloc] initWithObjects:@"LA",@"4M",@"XL",@"JJ",@"PZ", nil];
    materialArray = MATERIAL_ARR;
    self.legTableView.delegate=self;
    self.legTableView.dataSource=self;
    [self.legTableView setEditing:YES];
    self.legTableView.backgroundColor= [UIColor clearColor];
    //[self.legTableView reloadData];
    [self.containerView.layer setCornerRadius:20.0f];
    flightTypeButtonArray=[[NSMutableArray alloc]init];
    flightDateButtonArray=[[NSMutableArray alloc]init];
    flightJsonData=[[NSMutableDictionary alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged)  name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
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
#pragma mark - Navigate Field for Segment Control

-(void)navigateField:(UISegmentedControl *)segControl {
    // OffsetCustomCell *cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
    
    OffsetCustomCell *cell;
    if(ISiOS8) {
        cell = ((OffsetCustomCell *)[[currentTxtField superview] superview]);
    }
    else {
        cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
    }
    
    id view;
    selectedIndex = segControl.selectedSegmentIndex;
    if(segControl.selectedSegmentIndex == 0) {
        view = [cell viewWithTag:currentTxtField.tag - 1];
        
    }
    else {
        view = [cell viewWithTag:currentTxtField.tag + 1];
    }
    
    if(view == nil) {
        if(segControl.selectedSegmentIndex == 0) {
            for(int i = cell.indexPath.row - 1; i > 0; i--) {
                becomeResponder = YES;
                nextResponder = YES;
                responderIndexPath = [NSIndexPath indexPathForItem:i inSection:cell.indexPath.section];
                OffsetCustomCell *cell = (OffsetCustomCell *)[self.legTableView cellForRowAtIndexPath:responderIndexPath];
                if(cell == nil) {
                    [self.legTableView scrollToRowAtIndexPath:responderIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                else {
                    becomeResponder = NO;
                    [self.legTableView scrollToRowAtIndexPath:responderIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                    [((LegInformationCell *)cell).destination becomeFirstResponder];
                }
                
                break;
            }
        }
        else {
            for(int i = cell.indexPath.row + 1; i < [self.legDataArray count] + 1; i++) {
                becomeResponder = YES;
                nextResponder = YES;
                responderIndexPath = [NSIndexPath indexPathForItem:i inSection:cell.indexPath.section];
                
                OffsetCustomCell *cell = (OffsetCustomCell *)[self.legTableView cellForRowAtIndexPath:responderIndexPath];
                if(cell == nil) {
                    [self.legTableView scrollToRowAtIndexPath:responderIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                else {
                    becomeResponder = NO;
                    [self.legTableView scrollToRowAtIndexPath:responderIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                    [((LegInformationCell *)cell).origin becomeFirstResponder];
                }
                
                break;
            }
        }
    } else {
        nextResponder = YES;
        [view becomeFirstResponder];
        
    }
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - textfield delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (!string.length) {
        if (textField == self.matriculaTextView) {
            if([textField.text length] == 3 ) {
                textField.text = [textField.text substringWithRange:NSMakeRange(0, 1)];
                return NO;
            }
        }
        return YES;
    }
    
    if(textField == self.flightNumberTextView) {
        
        if([textField.text length] == FLIGHTNUMBERLENGTH) return NO;
        
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
            return NO;
        }
    }
    
    else if(textField == self.matriculaTextView) {
        if([textField.text length] == 7) return NO;
        
        if([textField.text length] == 2) {
            if(![string isEqualToString:@"-"]) {
                return NO;
            }
        }
        
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
            return NO;
            
        }
        
        NSRange lowercaseCharRange;
        lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        if (lowercaseCharRange.location != NSNotFound) {
            
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            if ([textField.text length] == 2 && [textField.text substringWithRange:NSMakeRange(1, 1)] ) {
                textField.text = [[textField.text uppercaseString] stringByAppendingString:@"-"];
                return NO;
            }
            
            return NO;
        }
    }
    
    // NSIndexPath *indexPath;
    if(ISiOS8) {
        if([[[textField superview] superview] isKindOfClass:[UITableViewCell class]]) {
            if(textField.tag == 100 || textField.tag == 101) {
                if ([string rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet]].location != NSNotFound || [textField.text length] == 3) {
                    return NO;
                }
                NSRange lowercaseCharRange;
                lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
                if (lowercaseCharRange.location != NSNotFound) {
                    
                    textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                             withString:[string uppercaseString]];
                    return NO;
                }
            }
        }
    }
    
    else {
        if([[[[textField superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
            if(textField.tag == 100 || textField.tag == 101) {
                if ([string rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet]].location != NSNotFound || [textField.text length] == 3) {
                    return NO;
                }
                NSRange lowercaseCharRange;
                lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
                if (lowercaseCharRange.location != NSNotFound) {
                    
                    textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                             withString:[string uppercaseString]];
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(ISiOS8){
        if(![[[textField superview] superview] isKindOfClass:[UITableViewCell class]]){
            
        }
        else{
            nextResponder = YES;
        }
    }
    else {
        if(![[[[textField superview] superview] superview] isKindOfClass:[UITableViewCell class]]){
            
        }
        else{
            nextResponder = YES;
        }
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    presentTxtFld = textField;
    
    if(![(ISiOS8)?([[textField superview] superview]):([[[textField superview] superview] superview]) isKindOfClass:[UITableViewCell class]]){
        
        if (textField == self.matriculaTextView){
            [UIView beginAnimations:@"tableviewAnimation" context:nil];
            [UIView setAnimationDuration:0.5];
            [self.view setFrame:CGRectMake(0,- 40,self.view.frame.size.width,self.view.frame.size.height)];
            [UIView commitAnimations];
        }
        
    }
    else{
        nextResponder = NO;
        currentTxtField = textField;
        if(becomeResponder){
            becomeResponder = NO;
        }
        else{
            
            CGPoint pointInView = [textField.superview.superview convertPoint:textField.frame.origin toView:self.view];
            CGPoint offset = CGPointMake(0, 0);
            if (yPosition != pointInView.y)
            {
                offset.y = (pointInView.y +  69 - (self.view.frame.size.height - 352 - kTableViewScrollOffset+100));
                if(offset.y > 0)
                {
                    [UIView beginAnimations:@"tableviewAnimation" context:nil];
                    [UIView setAnimationDuration:0.5];
                    CGRect frame = self.view.frame;
                    frame.origin.y -= offset.y;
                    [self.view setFrame:frame];
                    [UIView commitAnimations];
                }
            }
            else{
                offset.y = (pointInView.y +  69 - (self.view.frame.size.height - 352 - kTableViewScrollOffset+100));
                if(offset.y > 0)
                {
                    CGRect frame = self.view.frame;
                    frame.origin.y -= offset.y;
                    [self.view setFrame:frame];
                }
            }
            yPosition  = pointInView.y;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(![(ISiOS8)?([[textField superview] superview]):([[[textField superview] superview] superview]) isKindOfClass:[UITableViewCell class]]){
        [textField resignFirstResponder];
    }
    else{
        
        
        NSIndexPath *indexPath;
        if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[textField superview] superview]).indexPath;
        else
        indexPath = ((OffsetCustomCell *)[[[textField superview] superview] superview]).indexPath;
        
        if (deleteIndexPath_verify && [deleteIndexPath_verify compare:indexPath] == NSOrderedSame)
        {
            deleteIndexPath_verify = [NSIndexPath indexPathForItem:-1 inSection:-1];
            return;
        }
        //Legs *leg = [self.legDataArray objectAtIndex:indexPath.row-1];
        NSMutableDictionary *legDict = [self.legDataArray objectAtIndex:indexPath.row];
        if(textField.tag == 100){
            [legDict setObject:textField.text forKey:@"origin"];
            
        }
        else if(textField.tag == 101){
            [legDict setObject:textField.text forKey:@"destination"];
        }
        [self.legDataArray replaceObjectAtIndex:indexPath.row withObject:legDict];
        
        if(!nextResponder){
            if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
            {
                [UIView beginAnimations:@"tableAnimation" context:nil];
                [UIView setAnimationDuration:0.5];
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                [UIView commitAnimations];
            }
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    [UIView beginAnimations:@"tableAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    return YES;
}




- (IBAction)cancelTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(closePopOverforObject:)]) {
        [self.delegate closePopOverforObject:self];
    }
    
}

#pragma mark - popover methods for top view
    

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}



- (IBAction)popoverTap:(UIButton *)sender {
    if (presentTxtFld) {
        [presentTxtFld resignFirstResponder];
        [UIView beginAnimations:@"tableviewAnimation" context:nil];
        [UIView setAnimationDuration:0.5];
        [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        [UIView commitAnimations];
    }else{
    }
    [(UIResponder *)[[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)] resignFirstResponder];
    
    if(sender.tag == 1 || sender.tag == 3){
        
        FlightTypePopoverController *flightTypePopoverController = [[FlightTypePopoverController alloc] initWithNibName:@"FlightTypePopoverController" bundle:nil];
        if(sender.tag == 1){
            flightTypePopoverController.dataSource = companyArray;
            flightTypePopoverController.prevText = self.flightTypeButton.titleLabel.text;
            
        }
        else if(sender.tag == 3){
            flightTypePopoverController.dataSource = materialArray;
            flightTypePopoverController.prevText = self.materialButton.titleLabel.text;
            
        }
        
        flightTypePopoverController.delegate = self;
        flightTypePopoverController.btnTag = sender.tag;
        
        popOverCont = [[UIPopoverController alloc]initWithContentViewController:flightTypePopoverController];
        if([flightTypePopoverController.dataSource count]<6){
            [popOverCont setPopoverContentSize:CGSizeMake(flightTypePopoverController.view.frame.size.width,[flightTypePopoverController.dataSource count]*44)];
        }else{
            [popOverCont setPopoverContentSize:CGSizeMake(flightTypePopoverController.view.frame.size.width, flightTypePopoverController.view.frame.size.height)];
        }
        
        if(![popOverCont isPopoverVisible])
        {
            [popOverCont presentPopoverFromRect:sender.frame inView:self.containerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else{
        
        if(!datePicker){
            datePicker = nil;
        }
        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        //[datePicker setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        [datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        [datePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:3*60*60*24]];
        [datePicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:(-7*60*60*24)]];
        NSString *dateString = self.flightDateButton.titleLabel.text;
        if ([dateString length]> 0 && ![dateString isEqualToString:@""]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
            [dateFormatter setDateFormat:@"dd MMMM yyyy"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            flightDate = [dateFormatter dateFromString:dateString];
            [datePicker setDate:flightDate];
            dateFormatter = nil;
        }
        else{
            [datePicker setDate:[NSDate date]];
        }
        
        
        UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
        [popoverContent.view addSubview:datePicker];
        
        UINavigationController *dropDownNav = [[UINavigationController alloc] initWithRootViewController:popoverContent];
        //[appDel copyTextForKey:@"CANCEL"]
        UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"                                       style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(cancelButtonTapped:)];
        popoverContent.navigationItem.leftBarButtonItem = CancelButton;
        //[appDel copyTextForKey:@"DONE"]//[appDel copyTextForKey:@"DONE"]
        UIBarButtonItem *DoneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(doneButtonTapped:)];
        popoverContent.navigationItem.rightBarButtonItem = DoneButton;
        popoverContent.title = [appDel copyTextForKey:@"DATE"];
        
        popOverCont = [[UIPopoverController alloc] initWithContentViewController:dropDownNav];
        popOverCont.delegate =self;
        [popOverCont setPopoverContentSize:CGSizeMake(320, 265) animated:NO];
        
        if(![popOverCont isPopoverVisible])
        {
            [popOverCont presentPopoverFromRect:sender.frame inView:self.containerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}
- (void)keyboardDidShow:(id)notification{
    
}
- (void)keyboardDidHide:(id)notification{
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [UIView commitAnimations];
}




-(NSString *)getHost
{
    
    if([PORT isEqualToString:@"80"])
    return [NSString stringWithFormat:@"%@",HOSTNAME];
    else
    return [NSString stringWithFormat:@"%@:%@",HOSTNAME,PORT];
    
}



- (void)doneButtonTapped:(id)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMMM yyyy"];
    [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
    //    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    //    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    
    NSString *dt = [outputFormatter stringFromDate:datePicker.date];
    [self.flightDateButton setTitle:dt forState:UIControlStateNormal];
    //    Legs *leg = [self.legDataArray firstObject];
    //    if(leg.legDepartureLocal){
    //        [self validateDestinationAndDepartureWith:picker.date Time:leg.legDepartureLocal];
    //    }
    outputFormatter = nil;
    [popOverCont dismissPopoverAnimated:YES];
}
- (void)cancelButtonTapped:(id)sender
{
    
    [popOverCont dismissPopoverAnimated:YES];
    
    
}


-(void)pickerChanged:(UIDatePicker *)picker{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMMM yyyy"];
    [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
    //    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    //    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    
    NSString *dt = [outputFormatter stringFromDate:picker.date];
    [self.flightDateButton setTitle:dt forState:UIControlStateNormal];
    
    outputFormatter = nil;
}

-(void)setSelectedValue:(NSString *)selectedValue forViewWithTag:(int)btnTag{
    if ([selectedValue isEqualToString:@"<null>"]) {
        return;
    }
    if(btnTag == 1){
        [self.flightTypeButton setTitle:selectedValue forState:UIControlStateNormal];
    }
    else if(btnTag == 2){
        [self.flightDateButton setTitle:selectedValue forState:UIControlStateNormal];
    }
    else{
        [self.materialButton setTitle:selectedValue forState:UIControlStateNormal];
    }
    [popOverCont dismissPopoverAnimated:YES];
}

- (IBAction)getDataButtonClicked:(id)sender {
    /////////////////
    //in this method validate only first three feilds and if validated call the obtainData.json and populate the other feilds.
    departDateManually = NO;
    manualEnter = NO;
    if (presentTxtFld) {
        [presentTxtFld resignFirstResponder];
    } else {
        [(UIResponder *)[[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)] resignFirstResponder];
    }
    
    if([_flightTypeButton.titleLabel.text isEqualToString:@""] || [_flightNumberTextView.text isEqualToString:@""] || [_flightDateButton.titleLabel.text isEqualToString:@""] || _flightDateButton.titleLabel.text == nil || _flightTypeButton.titleLabel.text == nil) {
        
        alertMessage = [appDel copyTextForKey:@"ALERT_FILL"];
        if ([_flightDateButton.titleLabel.text isEqualToString:@""] || _flightDateButton.titleLabel.text == nil) {
            self.flightDateLb.textColor = [UIColor redColor];
        }
        
        if ([_flightTypeButton.titleLabel.text isEqualToString:@""] || _flightTypeButton.titleLabel.text == nil) {
            self.prefixLb.textColor = [UIColor redColor];
        }
        
        if ([_flightNumberTextView.text isEqualToString:@""] || _flightNumberTextView.text == nil) {
            self.flightNumberLb.textColor=[UIColor redColor];
        }
        
        
        if([_flightNumberTextView.text length] >= 5) {
            alertMessage = [appDel copyTextForKey:@"ALERT_MATRICULA"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            
            return;
            
        }
        
        if([_flightTypeButton.titleLabel.text isEqualToString:@""] || [_flightNumberTextView.text isEqualToString:@""] || [_flightDateButton.titleLabel.text isEqualToString:@""] ||  _flightDateButton.titleLabel.text == nil || _flightTypeButton.titleLabel.text == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            
            return;
        }
        
    }
    else {
        
        self.flightDateLb.textColor = KRobotoFontColorForManualflightLabel;
        self.prefixLb.textColor = KRobotoFontColorForManualflightLabel;
        self.flightNumberLb.textColor = KRobotoFontColorForManualflightLabel;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        
        // NSDate *legDepartureLocalStr = [self dateFromString:[self.flightDateButton.titleLabel.text] dateFormatType:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
        
        NSDate *fdate = [dateFormatter dateFromString:self.flightDateButton.titleLabel.text];
        if(!flightInfoDict) {
            flightInfoDict = [[NSMutableDictionary alloc] init];
        }
        
        if (mode == Modify) {
            [flightInfoDict removeAllObjects];
        }
        
        [flightInfoDict setObject:self.flightTypeButton.titleLabel.text forKey:@"airlineCode"];
        [flightInfoDict setObject:self.flightNumberTextView.text forKey:@"flightNumber"];
        NSString *str = [fdate dateFormat:DATE_FORMAT_dd_MM_yyyy];
        NSDictionary *flightDateDict = @{
                                         @"departureDateCondition":@"REAL",
                                         @"requestTimeStandard":@"UTC",
                                         @"departureDate":str
                                         };
        [flightInfoDict setObject:flightDateDict forKey:@"flightDate"];
        
        ActivityIndicatorView *ac = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
        synch.delegate = self;
        
        __block BOOL ShouldAdd = YES;
        
        if ([synch checkForInternetAvailability]) {
            
            [ac startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"ADDING_FLIGHT"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSDictionary *flightInfoDataDict = [synch fetchFlightInformation:flightInfoDict];
                if (flightInfoDataDict == nil || [[flightInfoDataDict allKeys] count] == 0 || [flightInfoDataDict[@"code"] intValue] < 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"MANUAL_FLIGHT_NO_DATA"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
        
                        [ac stopAnimation];
                    });
                    
                } else {
                    // Use the dictionary
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ac stopAnimation];
                        NSDictionary *legDict = [flightInfoDataDict objectForKey:@"getInfoFlightLegs"];
                        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                        [outputFormatter setDateFormat:@"dd MMMM HH:mm"];
                        NSDateFormatter *outputFormatter3 = [[NSDateFormatter alloc] init];
                        [outputFormatter3 setDateFormat:@"yyyy MM dd'T'HH:mm"];
                        
                        if(![[legDict objectForKey:@"material"] isEqual:[NSNull null]]) {
                            [self setSelectedValue:[legDict objectForKey:@"material"] forViewWithTag:3];
                            self.matriculaTextView.text = [legDict objectForKey:@"tailNumber"];
                        }
                        
                        if ([[legDict objectForKey:@"legs"] count] > 0) {
                            self.legDataArray = [legDict objectForKey:@"legs"];
                            for (int i = 0; i < [self.legDataArray count]; i++) {   // preprocess dict
                                NSMutableDictionary *dict = [self.legDataArray objectAtIndex:i];
                                [dict removeObjectForKey:@"businessUnit"];
                                [dict removeObjectForKey:@"cabinsOccupancies"];
                                [dict removeObjectForKey:@"crewMembers"];
                                [dict removeObjectForKey:@"gateNumber"];
                                
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                df.dateFormat = @"dd-MM-yyyy HH:mm";
                                
                                NSString *strDepartureLocal = [dict objectForKey:@"legDepartureLocal"];
                                NSString *strArrivalLocal = [dict objectForKey:@"legArrivalLocal"];
                                
                                [dict setObject:[df dateFromString:strDepartureLocal] forKey:@"legDepartureLocal"];
                                [dict setObject:[df dateFromString:strArrivalLocal] forKey:@"legArrivalLocal"];
                            }
                            [self.legTableView reloadData];
                        } else {
                            manualEnter = YES;
                        }
                    });
                }
            });
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[appDel copyTextForKey:@"ALERT_MSG_NO_INTERNET"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            ShouldAdd = YES;
        }
        
        dateFormatter = nil;
    }
}

#pragma mark - form closing methods

-(BOOL)validateFields {
    // TODO need to change
    //[self.materialLabel.text isEqualToString:kMaterialPlaceholder]
    if([_flightTypeButton.titleLabel.text isEqualToString:@""] || [_flightNumberTextView.text isEqualToString:@""] || [_flightDateButton.titleLabel.text isEqualToString:@""] ||  [_matriculaTextView.text isEqualToString:@""]  ||  [_materialButton.titleLabel.text isEqualToString:@""] || _flightDateButton.titleLabel.text == nil || _flightTypeButton.titleLabel.text == nil) {
        
        if ([_flightDateButton.titleLabel.text isEqualToString:@""] || _flightDateButton.titleLabel.text == nil) {
            self.flightDateLb.textColor = [UIColor redColor];
        }
        
        if ([_flightTypeButton.titleLabel.text isEqualToString:@""] || _flightTypeButton.titleLabel.text == nil) {
            self.prefixLb.textColor = [UIColor redColor];
        }
        
        if ([_flightNumberTextView.text isEqualToString:@""] || _flightNumberTextView.text == nil) {
            self.flightNumberLb.textColor=[UIColor redColor];
        }
        if ([self.materialButton.titleLabel.text isEqualToString:@""] || self.materialButton.titleLabel.text==nil){
            self.materialLb.textColor = [UIColor redColor];
        }
        if ([self.matriculaTextView.text isEqualToString:@""]|| self.matriculaTextView.text==nil) {
            self.matriculaLb.textColor = [UIColor redColor];
        }
        
        
                return NO;
    }
    BOOL ret = YES;
    int i=0;
    for(NSMutableDictionary *legDict in self.legDataArray){
        NSString *originText=[legDict objectForKey:@"origin"];
        NSString *destinationText=[legDict objectForKey:@"destination"];
        if([[legDict objectForKey:@"Origin"] isEqualToString:@""] || [[legDict objectForKey:@"Destination"] isEqualToString:@""] || ![legDict objectForKey:@"legDepartureLocal"] || ![legDict objectForKey:@"legArrivalLocal"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_FILL"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            
            UITableViewCell *cell  = [self.legTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.layer.borderWidth = 1.0f;
            cell.layer.borderColor = [UIColor redColor].CGColor;
            i++;
            
            return NO;
            
        }
        
        
        
        else if ([originText length] < 3 ||  [destinationText length] < 3){
            // orgin less than 3 char
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_3CHAR_ORIGIN_DESTINATION"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            return NO;
        }
        [self validateDates:[legDict objectForKey:@"legDepartureLocal"] withArrival:[legDict objectForKey:@"legArrivalLocal"]];
        if(arrivalLessThanDeparture){
            return NO;
        }
                if (isLessThanEqualToDepartureDate) {
                    return NO;
                }
    
    
    if ([self.legDataArray count] > 0) {
        
        // legs madatory Present
        NSMutableDictionary *legDict = [self.legDataArray firstObject];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
//        if (departDateManually==NO) {
//            NSDate *legDepartureLocalStr = [self dateFromString:[legDict objectForKey:@"legArrivalLocal"]dateFormatType:DATE_FORMAT_dd_mm_yyyy_new];
//            [self validateDestinationAndDepartureWith:[dateFormatter dateFromString:self.flightDateButton.titleLabel.text] Time:legDepartureLocalStr];
//
//        }
//        else
        [self validateDestinationAndDepartureWith:[dateFormatter dateFromString:self.flightDateButton.titleLabel.text] Time:[legDict objectForKey:@"legDepartureLocal"]];
        dateFormatter = nil;
    }
    if ([self.legDataArray count]==0 && (mode==Modify || mode==Delete)) {
        return YES;
    }
    
    if(differentDayOfDeparture){
        return NO;
    }

    }
    
    if (ret == NO) {
        return NO;
    }else{
        for (int i=0; i<[self.legDataArray count]; i++) {
            UITableViewCell *cell  = [self.legTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.layer.borderWidth = 1.0f;
            cell.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    
    
    self.flightDateLb.textColor = KRobotoFontColorForManualflightLabel;
    self.prefixLb.textColor = KRobotoFontColorForManualflightLabel;
    self.flightNumberLb.textColor = KRobotoFontColorForManualflightLabel;
    self.materialLb.textColor = KRobotoFontColorForManualflightLabel;
    self.matriculaLb.textColor = KRobotoFontColorForManualflightLabel;
    
    return YES;
}

- (IBAction)saveButtonTapped:(id)sender {
   // [self getDataButtonClicked:sender];
        //manualEnter=YES;
        
    if (presentTxtFld) {
        [presentTxtFld resignFirstResponder];
    } else {
        [(UIResponder *)[[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)] resignFirstResponder];
    }
    
    if(![self validateFields]) {
        alertMessage = [appDel copyTextForKey:@"ALERT_FILL"];
        if([_flightTypeButton.titleLabel.text isEqualToString:@""] || [_flightNumberTextView.text isEqualToString:@""] || [_flightDateButton.titleLabel.text isEqualToString:@""] ||  [_matriculaTextView.text isEqualToString:@""]  ||  [_materialButton.titleLabel.text isEqualToString:@""] ){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            return;
        }
        if([_flightNumberTextView.text length]>5){
            alertMessage = [appDel copyTextForKey:@"ALERT_MATRICULA"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            return;
            
        }
        
        if([_matriculaTextView.text length] < 5){
            alertMessage = [appDel copyTextForKey:@"ALERT_MATRICULA"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            if ([AlertUtils checkAlertExist]) {
                [alert show];
            }
            return;
        }
    }

    else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        flightDate = [dateFormatter dateFromString:self.flightDateButton.titleLabel.text];
        
        if(!flightInfoDict)
        flightInfoDict = [[NSMutableDictionary alloc] init];
        
        [flightJsonData setObject:self.flightTypeButton.titleLabel.text forKey:@"airlineCode"];
        
        [flightJsonData setObject:self.flightNumberTextView.text forKey:@"flightNumber"];
        
        [flightJsonData setObject:flightDate forKey:@"flightDate"];
        
        [flightJsonData setObject:self.materialButton.titleLabel.text forKey:@"materialType"];
        [flightJsonData setObject:self.matriculaTextView.text forKey:@"matricularText"];
        
        [flightJsonData setObject:self.legDataArray forKey:@"legs"];
        
        ActivityIndicatorView *ac = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
        
        AddManualFlightViewController __weak *weakSelf = self;
        
        if ([LTSingleton getSharedSingletonInstance].synchStatus) {
            switch (mode) {
                case Add:
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"NOT_ADD_FlIGHT"]];
                    break;
                case Modify:
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"NOT_MODIFY_FLIGHT"]];
                    break;
                case Delete:
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"NOT_DELETE_FLIGHT"]];
                    break;
                default:
                    break;
            }
            return;
        }
        if (mode==Delete) {
            [ac startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"FLIGHT_DELETE"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while (1) {
                    NSLog(@"spin wait");
                    if (![LTSingleton getSharedSingletonInstance].synchStatus) {
                        break;
                    }
                }
                ///check if any report submitted in the flight
                NSDictionary *flightKey = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
                NSMutableArray *statArray = [UserInformationParser getStatusForAllFlights];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"airlineCode == %@ AND flightDate==%@ AND flightNumber==%@",[flightKey objectForKey:@"airlineCode"],[flightKey objectForKey:@"flightDate"],[flightKey objectForKey:@"flightNumber"]];
                statArray=[[statArray filteredArrayUsingPredicate:predicate] mutableCopy];
                BOOL shouldDelete = YES;
                if([statArray count]>0) {
                    NSDictionary *statDict = [statArray firstObject];
                    
                    if([[statDict objectForKey:@"flightStatus"] integerValue]==draft || [[statDict objectForKey:@"flightStatus"] integerValue]==eror || [[statDict objectForKey:@"flightStatus"] integerValue]==ee)
                        shouldDelete=NO;
                    for (NSDictionary *cusDict in [statDict objectForKey:@"CUS"]) {
                        if([[cusDict objectForKey:@"status"] integerValue]==draft || [[cusDict objectForKey:@"status"] integerValue]==eror || [[cusDict objectForKey:@"status"] integerValue]==ee)
                        shouldDelete=NO;
                    }
                    for (NSDictionary *GADDict in [statDict objectForKey:@"GAD"]) {
                        if([[GADDict objectForKey:@"status"] integerValue]==draft || [[GADDict objectForKey:@"status"] integerValue]==eror || [[GADDict objectForKey:@"status"] integerValue]==ee)
                        shouldDelete=NO;
                    }
                    
                }
                if (shouldDelete) {
                    [synch addSingleManualFlight:flightJsonData withOldFlight:flightDataDict forMode:mode Oncomplete:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ac stopAnimation];
                            [weakSelf.delegate closePopOverforObject:weakSelf];
                            if ([weakSelf.delegate respondsToSelector:@selector(updateCarousal)]) {
                                [weakSelf.delegate updateCarousal];
                            }
                        });
                    }];
                }else{
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ERROR_LABEL"] message:[appDel copyTextForKey:@"DONT_DELETE"]];
                    return ;
                }
            });
        }
 
        else if (mode == Add) {
            BOOL success =  [UserInformationParser checkFlightExist:flightJsonData];
            if(success){
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ERROR_LABEL"] message:[appDel copyTextForKey:@"FLIGHT_EXISTS"]];
                return ;
            }
        
            [ac startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"ADDING_FLIGHT"]];
            
            NSDictionary *flightJsonDict = [flightJsonData copy];
            
            [synch addSingleManualFlight:flightJsonData withOldFlight:nil forMode:mode Oncomplete:^{
                [ac stopAnimation];
                [weakSelf.delegate closePopOverforObject:weakSelf];
                
                if ([weakSelf.delegate respondsToSelector:@selector(manualFlightAdded:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf.delegate manualFlightAdded:flightJsonDict];
                    });
                }
            }];
  
        } else if(mode == Modify) {
            BOOL success =  [UserInformationParser checkFlightExist:flightJsonData];
            if(success) {
                if ([UserInformationParser checkKeysSameBetween:flightJsonData and:flightDataDict]) {
                    
                } else {
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ERROR_LABEL"] message:[appDel copyTextForKey:@"FLIGHT_EXISTS"]];
                    return ;
                }
                
            }
            
            [ac startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"ADDING_FLIGHT"]];
            
            NSDictionary *flightJsonDict = [flightJsonData copy];
            
            [synch addSingleManualFlight:flightJsonData withOldFlight:flightDataDict forMode:mode Oncomplete:^{
                [ac stopAnimation];
                [weakSelf.delegate closePopOverforObject:weakSelf];
                if ([weakSelf.delegate respondsToSelector:@selector(manualFlightAdded:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate manualFlightAdded:flightJsonDict];
                    });
                }
            }];
        }
    }
}

- (IBAction)trashButtonClicked:(id)sender {
    mode=Delete;
    NSString *alertmsg = [appDel copyTextForKey:@"ALERT_MSG"];
    NSString *alertString = [appDel copyTextForKey:@"DELETE_MANUAL_FLIGHT"];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertmsg message:alertString delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ALERT_OK"],nil];
    alertView.tag = 101;
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self saveButtonTapped:nil];
    }
}

-(void)addUpdateDB:(BOOL)ShouldAdd{
    BOOL success=FALSE;
    if (mode==Add && ShouldAdd) {
        success =  [self addModifyDeleteManualFlight:flightJsonData forFlight:nil forMode:mode];
    }
    ActivityIndicatorView *ac = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
    [ac stopAnimation];
}

-(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)fMode{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if (results>0) {
        
    }
    if (fMode == Add) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND material == %@ AND flightNumber == %@ AND airlineCode == %@ AND materialType == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"tailNumber"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"],[newflight objectForKey:@"material"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        NSMutableArray *legArr = [newflight objectForKey:@"legs"];

        if ([legArr count]>0) {//checking if any legs exist in new flight
            //if exist add new leg to old object
            for (NSMutableDictionary *legDict in legArr) {
                Legs *leg = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:managedObjectContext];
                leg.destination = [legDict objectForKey:@"Destination"];
                leg.origin = [legDict objectForKey:@"Origin"];
                leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                predicate = [NSPredicate predicateWithFormat:@"origin==%@ AND destination==%@ AND legArrivalUTC==%@ AND  legDepartureUTC==%@",leg.origin,leg.destination,leg.legArrivalLocal,leg.legDepartureLocal];
        
            }
        }
        if ([results count]>0) {
            return NO;
        } else{
            FlightRoaster *flight = [self getFlightObjectFromDict:newflight forManageObjectContext:managedObjectContext];
            [currentUser addFlightRostersObject:flight];
            if(![managedObjectContext save:&error]) {
                NSLog(@"Failed to save flightroster");
            }
            
        }

        return NO;
    }
    return YES;
}

#pragma mark - tableview methods


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1+[self.legDataArray count];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *headingIdentifier = @"HeaderCell";
    static NSString *legInformationIdentifier = @"LegInformationCell";
    AddRowCell *headingCell;
    OffsetCustomCell *cell;
    LegInformationCell *legCell;
    
    if(indexPath.row == [self.legDataArray count]){
        headingCell = [tableView dequeueReusableCellWithIdentifier:headingIdentifier];
        if (headingCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            headingCell = [topLevelObjects objectAtIndex:0];
            headingCell.viewController = self;
            headingCell.tag=111;
            headingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [[headingCell controlButton] setImage:[UIImage imageNamed:@"N__0002_plus.png"]];
            [[headingCell controlButton] setFrame:CGRectMake(10, 28, 23, 23)];
        
        }
        headingCell.headingLbl.textColor = [UIColor blackColor];
        headingCell.headingLbl.text = [appDel copyTextForKey:@"ADD_LEG"];
        cell = headingCell;
        cell.backgroundColor=[UIColor clearColor];
    }
    else{
        legCell = [tableView dequeueReusableCellWithIdentifier:legInformationIdentifier];
        if(legCell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LegInformationCell" owner:self options:nil];
            legCell = [topLevelObjects objectAtIndex:0];
            legCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [[legCell controlButton] setImage:[UIImage imageNamed:@"N__0001_minus.png"]];
            //legCell.origin.inputAccessoryView = [self keyboardToolBar];
            //legCell.destination.inputAccessoryView = [self keyboardToolBar];95
            legCell.origin.delegate = self;
            legCell.destination.delegate = self;
            legCell.departureTime.addFlight = YES;
            legCell.destinationTime.addFlight = YES;
            legCell.departureTime.delegate = self;
            legCell.origin.placeholder = [[[[appDel copyTextForKey:@"ORIGIN"] stringByAppendingString:@"*"] mandatoryString] string];
            legCell.departureTime.selectedTextField.placeholder = [[[[appDel copyTextForKey:@"DEPARTURETIME"] stringByAppendingString:@"*"] mandatoryString] string];
            legCell.destination.placeholder = [[[[appDel copyTextForKey:@"DESTINATION"] stringByAppendingString:@"*"] mandatoryString] string];
            legCell.destinationTime.selectedTextField.placeholder = [[[[appDel copyTextForKey:@"DESTINATIONTIME"] stringByAppendingString:@"*"] mandatoryString] string];
            
            legCell.destinationTime.delegate = self;
            legCell.departureTime.typeOfDropDown = DateDropDown;
            legCell.destinationTime.typeOfDropDown = DateDropDown;
            legCell.destinationTime.dateHeaderTitle  = [appDel copyTextForKey:@"DATE"];
            legCell.departureTime.dateHeaderTitle  = [appDel copyTextForKey:@"DATE"];
            
            legCell.departureTime.tag = 111;
            legCell.destinationTime.tag = 222;
        }
        
        NSMutableDictionary *legDict = [self.legDataArray objectAtIndex:indexPath.row];
        legCell.origin.text = [legDict objectForKey:@"origin"];
        legCell.destination.text = [legDict objectForKey:@"destination"];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"dd MMMM HH:mm"];
        [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        
        NSDateFormatter *outputFormatter2 = [[NSDateFormatter alloc] init];
        [outputFormatter2 setDateFormat:@"dd MMMM HH:mm"];
        [outputFormatter2 setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        
        NSDateFormatter *outputFormatter3 = [[NSDateFormatter alloc] init];
        [outputFormatter3 setDateFormat:@"yyyy MM dd'T'HH:mm"];
        [outputFormatter3 setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        
        
        //TODO:Need to uncomment this code
        //        NSString *legDepartureLocalStr = [legDict objectForKey:@"legDepartureLocal"];
        //        NSString *legArrivalLocalStr = [legDict objectForKey:@"legArrivalLocal"];
        // Now Converting sting to date
        
        if(manualEnter == NO) {
            if (legDict != nil && [[legDict allKeys] count] > 0) {
                NSDateFormatter *outputFormatter3 = [[NSDateFormatter alloc] init];
                [outputFormatter3 setDateFormat:@"yyyy MM dd'T'HH:mm"];
                [outputFormatter3 setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
                
                NSDate *legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                NSDate *legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                
                NSString *dateDeparture1 = [outputFormatter stringFromDate:legDepartureLocal];
                NSString *dateDeparture2 = [outputFormatter3 stringFromDate:legDepartureLocal];
                NSString *dateArrival1 = [outputFormatter2 stringFromDate:legArrivalLocal];
                NSString *dateArrival2 = [outputFormatter3 stringFromDate:legArrivalLocal];
                
                legCell.departureTime.selectedValue = dateDeparture2;
                legCell.destinationTime.selectedValue = dateArrival2;
                
                legCell.departureTime.selectedTextField.text = dateDeparture1;
                legCell.destinationTime.selectedTextField.text = dateArrival1;
            }
       } else {
           legCell.departureTime.selectedValue =[outputFormatter3 stringFromDate:[legDict objectForKey:@"legDepartureLocal"]];
           legCell.destinationTime.selectedValue = [outputFormatter3 stringFromDate:[legDict objectForKey:@"legArrivalLocal"]];
        
        
           legCell.departureTime.selectedTextField.text = [outputFormatter stringFromDate:[legDict objectForKey:@"legDepartureLocal"]];
        legCell.destinationTime.selectedTextField.text = [outputFormatter2 stringFromDate:[legDict objectForKey:@"legArrivalLocal"]];
            }
        cell = legCell;

        outputFormatter = nil;
        outputFormatter2 = nil;
        outputFormatter3 = nil;
    }
    
    cell.indexPath = indexPath;
    cell.userInteractionEnabled=TRUE;
    
    cell.tag = kCusTag;
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (NSDate *)dateFromString:(NSString *)dateStr dateFormatType:(DATE_FORMAT_TYPE)dateFormatType{
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    NSString *dateFormat;
    
    switch (dateFormatType) {
            
        case DATE_FORMAT_yyyy_MM_dd_HH_mm_ss:
            dateFormat = @"yyyy-MM-dd HH:mm:ss";
            break;
            
        case DATE_FORMAT_dd_MMM_yyyy:
            
            //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
            dateFormat = @"dd MMM yyyy";
            break;
            
        case DATE_FORMAT_HH_mm:
            dateFormat = @"HH:mm";
            break;
            
//        case DATE_FORMAT_dd_MM_yyyy_HH__mm_ss_new:
//            dateFormat =  @"dd-MM-yyyy HH:mm"; //23-04-2015 22:35
//            break;
//            
        case DATE_FORMAT_dd_MM_yyyy_HH_mm_ss:
            dateFormat =  @"dd-MM-yyyy HH:mm:ss Z"; //23-04-2015 22:35:00 +0000
            break;
        case DATE_FORMAT_dd_mm_yyyy_new:
            dateFormat =  @"dd-MM-yyyy HH:mm"; //23-04-2015 22:35
            break;
       case DATE_FORMAT_dd_MM_yyyy:
            dateFormat =  @"dd-MM-yy"; //23-04-2015
            break;
        default:
            break;
    }
    
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];   //rajesh
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *formattedDate =[formatter dateFromString:dateStr];
    
    
    return formattedDate;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //    if([NSStringFromClass([cell class]) isEqualToString:@"LegInformationCell"] && responderIndexPath.row == indexPath.row && responderIndexPath.section == indexPath.section && becomeResponder){
    //        becomeResponder = YES;
    //        responderIndexPath = [NSIndexPath indexPathForItem:-1 inSection:-1];
    //        (selectedIndex)?[((LegInformationCell *)cell).origin becomeFirstResponder]:[((LegInformationCell *)cell).destination becomeFirstResponder];
    //    }
    //    cell.backgroundColor = [UIColor clearColor];
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return 100.0;
    if (indexPath.row<[legDataArray count]) {
        return 69.0;
    }else{
        return 49.0;
    }
    //return (indexPath.row)?69.0:64.0;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<[legDataArray count]) {
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleInsert;
    }
}
//- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path{
//    return nil;
//}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (mode==Delete && editingStyle==UITableViewCellEditingStyleInsert)
    {
        mode=Modify;
    }
    if(editingStyle == UITableViewCellEditingStyleInsert){
        if([self.legDataArray count] < 5){
            NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
            //[self.legDataArray insertObject:leg atIndex:0];
            //[self.legDataArray addObject:leg];
            [self.legDataArray addObject:legDict];
                       if([self.legDataArray count] <= 3 ){
                           CGRect tableFrame = _legTableView.frame;
            //                // tableFrame.size.height += kFlightLegHeight;
            //
                            [UIView animateWithDuration:0.15 animations:^{
                               _legTableView.frame = tableFrame;}];
                        }
            
                        [tableView beginUpdates];
                        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:[self.legDataArray count]inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];
            [tableView reloadData];
            legDict = nil;
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.legDataArray count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    else{
        deleteIndexPath_verify = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
        deleteIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
        
        LegInformationCell *cell_leg = (LegInformationCell*)[self.legTableView cellForRowAtIndexPath:deleteIndexPath_verify];
        if ([cell_leg.origin isFirstResponder]|| [cell_leg.destination isFirstResponder]) {
            
        }else
        {
            deleteIndexPath_verify = [NSIndexPath indexPathForItem:-1 inSection:-1];
        }
        if([self.legDataArray count] == 1 && mode == Modify){
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"LAST_LEG_DEL"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            //            if ([AlertUtils checkAlertExist]) {
            //                [alert show];
            //            }
            return;
        }
        //        else if(mode == Modify){
        //            [AlertUtils showErrorAlertWithTitle:@"Warning!" message:@"Deleteing this leg will delete saved data for this leg"];
        //        }
        //Legs *leg = [self.legDataArray objectAtIndex:indexPath.row-1];
        NSMutableDictionary *legDict = [self.legDataArray objectAtIndex:indexPath.row];
        if (!self.deleteLegaArray) {
            self.deleteLegaArray=[[NSMutableArray alloc] init];
        }
        
        [self.deleteLegaArray addObject:legDict];
        [self.legDataArray removeObjectAtIndex:indexPath.row];
        
        
        //        if([self.legDataArray count] <= 2){
        //            CGRect tableFrame = _legTableView.frame;
        //            // tableFrame.size.height -= kFlightLegHeight;
        //            [UIView animateWithDuration:0.20 animations:^{
        //                UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        //                cell.hidden = YES;
        //                _legTableView.frame = tableFrame;}];
        //        }
        
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [tableView reloadData];
        legDict = nil;
    }
}
#pragma mark - Date popover delegate fro tableview

-(void)validateDates:(NSDate *)departureString withArrival:(NSDate *)arrivalString{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    //[outputFormatter setDateFormat:@"dd MMMM HH:mm"];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    //    NSDate *departure = departureString;//[outputFormatter dateFromString:departureString];
    //    NSDate *arrival = arrivalString;//[outputFormatter dateFromString:arrivalString];
    
    NSString *departureStr = [outputFormatter stringFromDate:departureString];
    NSString *arrivalStr = [outputFormatter stringFromDate:arrivalString];
    
    //As per new CR - validate only dates excluding times
    NSDate *departure = [outputFormatter dateFromString:departureStr];
    NSDate *arrival = [outputFormatter dateFromString:arrivalStr];
    
    
    
    //The receiver is later in time than anotherDate, NSOrderedDescending
    //if(([departure compare:arrival] == NSOrderedDescending) || [departure compare:arrival] == NSOrderedSame )
    //&& !([departure compare:arrival] == NSOrderedAscending)
    // if (!([departure compare:arrival] == NSOrderedAscending))
    if (([departure compare:arrival] == NSOrderedDescending))
    {
        arrivalLessThanDeparture = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_ARRIVAL_DEST"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [AlertUtils showErrorAlertWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_ARRIVAL_DEST"]];
    }
    else{
        arrivalLessThanDeparture = NO;
    }

    outputFormatter = nil;
    departure = nil;
    arrival = nil;
    
}

-(void)validateDateWhereDepartureTime_leg:(NSDate *)leg_date shouldBeGreaterThanOrEqualToDepartureDate:(NSDate *)departureTime {
    
    if(!([departureTime compare:leg_date] == NSOrderedAscending)) {
        isGreaterThanEqualToLegDepDate = YES;
    } else {
        isGreaterThanEqualToLegDepDate = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_DIFF_DAY"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if ([AlertUtils checkAlertExist]) {
            [alert show];
        }
    }
}

-(void)validateDestinationAndDepartureWith:(NSDate *)departureDate Time:(NSDate *)departureTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: departureTime];
    NSDate *onlyDepartureDate = [calendar dateFromComponents:components];
    components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                             fromDate: departureDate];
    
    //    @NOTE(diego_cath): Cristobal (LATAM) asked us to remove this check because of an issue on their side. The 2 lines below this comment should be removed if they decide to add this check again. (Feb 25, 2016)
    
    differentDayOfDeparture = NO;
    return;
    
    if(([[calendar dateFromComponents:components] compare:onlyDepartureDate] == NSOrderedAscending) || [[calendar dateFromComponents:components] compare:onlyDepartureDate] == NSOrderedSame){
        differentDayOfDeparture = NO;
    }
    else {
        differentDayOfDeparture = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMsg message:[appDel copyTextForKey:@"ALERT_DIFF_DAY"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if ([AlertUtils checkAlertExist]) {
            [alert show];
        }
    }
}

-(void)valueSelectedWhenDismissPopover:(TestView*)testView {
}

-(void)valueSelectedInPopover:(TestView *)testView {
    
    NSIndexPath *indexPath;
    if(ISiOS8)
    indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
    indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    NSMutableDictionary *legDict = [self.legDataArray objectAtIndex:indexPath.row];//humeera -1
    if(testView.tag == 111) {
        //Leg Destination date//
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy MM dd'T'HH:mm"]; //"yyyy-MM-dd" //dd MM yyyy
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        //leg.legDepartureLocal = [formatter dateFromString:testView.selectedValue];
        [legDict setObject:[formatter dateFromString:testView.selectedValue] forKey:@"legDepartureLocal"];
        
        if(![self.flightDateButton.titleLabel.text isEqualToString: @""] && indexPath.row == 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd MMMM yyyy"];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
            [self validateDestinationAndDepartureWith:[dateFormatter dateFromString:self.flightDateButton.titleLabel.text] Time:[legDict objectForKey:@"legDepartureLocal"]];
            dateFormatter = nil;
        }
        if([legDict objectForKey:@"legArrivalLocal"] != nil) {
            [self validateDates:[legDict objectForKey:@"legDepartureLocal"] withArrival:[legDict objectForKey:@"legArrivalLocal"]];
        }
        
        formatter = nil;
        
    }
    else if(testView.tag == 222) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy MM dd'T'HH:mm"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        //leg.legArrivalLocal = [formatter dateFromString:testView.selectedValue];
        [legDict setObject:[formatter dateFromString:testView.selectedValue] forKey:@"legArrivalLocal"];
        if([legDict objectForKey:@"legDepartureLocal"] != nil) {
            [self validateDates:[legDict objectForKey:@"legDepartureLocal"] withArrival:[legDict objectForKey:@"legArrivalLocal"]];
        }
        formatter = nil;
    }
    [self.legDataArray replaceObjectAtIndex:indexPath.row withObject:legDict];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UIView *view = (UIView *) [[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)];
    if([view isFirstResponder]) {
        [view resignFirstResponder];
    }
}

@end
