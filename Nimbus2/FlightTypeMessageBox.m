//
//  FlightTypeMessageBox.m
//  LATAM
//
//  Created by Ankush Jain on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "FlightTypeMessageBox.h"
#import "FlightTypePopoverController.h"
//#import "LTFlightRoaster.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "AlertUtils.h"

@interface FlightTypeMessageBox ()
{
    NSArray *flightTypeContentArr;
    NSArray *businessTypeArr;
    NSArray *materialTypeArr;
    UIPopoverController *popOverCont;
    IBOutlet UILabel *businessTypeLbl;
    IBOutlet UILabel *materialLbl;
    __weak IBOutlet UIButton *cancelBtn;
    
    __weak IBOutlet UILabel *businessUnitLbl;

    __weak IBOutlet UIButton *submitBtn;
    __weak IBOutlet UILabel *headingLbl;
}
@end

@implementation FlightTypeMessageBox
@synthesize flightType, delegate,airlineCode,bUnit,materialVal;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [cancelBtn setTitle:[apDel copyTextForKey:@"CANCEL"] forState:UIControlStateNormal];
    [submitBtn setTitle:[apDel copyTextForKey:@"SUBMIT"] forState:UIControlStateNormal];
    headingLbl.text = [apDel copyTextForKey:@"SELECT_FLIGHTTYPE"];
    businessUnitLbl.attributedText = [[apDel copyTextForKey:@"BUSINESSUNIT"] mandatoryString];
    if(bUnit)
        businessTypeLbl.text = bUnit;

    if(materialVal)
        materialLbl.text = materialVal;
    
    flightTypeContentArr = [[NSArray alloc ]initWithObjects:@"Business Type",@"Material", nil];
//    businessTypeArr = [[NSArray alloc] initWithObjects:[@"INT" stringByAppendingFormat:@"%@",airlineCode],[@"REG" stringByAppendingFormat:@"%@",airlineCode],[@"DOM" stringByAppendingFormat:@"%@",airlineCode], nil];
    businessTypeArr = [[NSArray alloc] initWithObjects:LONGHAUL, SHORTHAUL, DOMESTIC,nil];
    materialTypeArr = MATERIAL_ARR;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)businessTypeBtnClicked:(UIButton *)sender
{
    FlightTypePopoverController *flightTypePopoverController = [[FlightTypePopoverController alloc] initWithNibName:@"FlightTypePopoverController" bundle:nil];
    flightTypePopoverController.dataSource = businessTypeArr;
    flightTypePopoverController.delegate = self;
    flightTypePopoverController.btnTag = 1;
    flightTypePopoverController.prevText = businessTypeLbl.text;
    popOverCont = [[UIPopoverController alloc]initWithContentViewController:flightTypePopoverController];
    [popOverCont setPopoverContentSize:CGSizeMake(flightTypePopoverController.view.frame.size.width, flightTypePopoverController.view.frame.size.height)];
    
    if(![popOverCont isPopoverVisible])
    {
        [popOverCont presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (IBAction)materialBtnClicked:(UIButton *)sender
{
    FlightTypePopoverController *flightTypePopoverController = [[FlightTypePopoverController alloc] initWithNibName:@"FlightTypePopoverController" bundle:nil];
    flightTypePopoverController.dataSource = materialTypeArr;
    flightTypePopoverController.delegate = self;
    flightTypePopoverController.btnTag = 2;
    flightTypePopoverController.prevText = materialLbl.text;
    popOverCont = [[UIPopoverController alloc]initWithContentViewController:flightTypePopoverController];
    [popOverCont setPopoverContentSize:CGSizeMake(flightTypePopoverController.view.frame.size.width, flightTypePopoverController.view.frame.size.height)];
    
    if(![popOverCont isPopoverVisible])
    {
        [popOverCont presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (BOOL)isDataComplete
{
    if([businessTypeLbl.text isEqualToString:@""] || [materialLbl.text isEqualToString:@""])
    {
        return NO;
        
    }
    return YES;
}

-(IBAction)submitBtnClicked:(id)sender
{
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(![self isDataComplete])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[apDel copyTextForKey:@"FLIGHT_TYPE"] message:[apDel copyTextForKey:@"ALERT_FILL"] delegate:self cancelButtonTitle:[apDel copyTextForKey:@"ALERT_OK"] otherButtonTitles:nil, nil];
        if ([AlertUtils checkAlertExist]) {
            [alert show];
        }
    }
    else
    {
        NSString *businessUnitStr = @"";
        if([businessTypeLbl.text isEqualToString:LONGHAUL])
        {
            businessUnitStr = [@"INT" stringByAppendingFormat:@"%@",airlineCode];
        }
        else if([businessTypeLbl.text isEqualToString:SHORTHAUL])
        {
            businessUnitStr = [@"REG" stringByAppendingFormat:@"%@",airlineCode];
        }
        else if([businessTypeLbl.text isEqualToString:DOMESTIC])
        {
            businessUnitStr = [@"DOM" stringByAppendingFormat:@"%@",airlineCode];
        }
        flightType = [UserInformationParser getFlightTypeFromMeterial:materialLbl.text BusinessUnit:businessUnitStr AirlineCode:self.airlineCode];
        
        [delegate setFlightTypeManually:flightType andBusinessUnit:businessUnitStr andMaterialType:materialLbl.text];
    }
}

#pragma mark - Delegate Methods

-(void)setSelectedValue:(NSString *)selectedValue forViewWithTag:(int)btnTag
{
    if(btnTag == 1)
        businessTypeLbl.text = selectedValue;
    else
        materialLbl.text = selectedValue;
    
    [popOverCont dismissPopoverAnimated:YES];
}


#pragma mark - Internal Methods
- (IBAction)cancelBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
