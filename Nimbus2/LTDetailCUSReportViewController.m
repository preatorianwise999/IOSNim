//
//  LTDetailCUSReportViewController.m
//  LATAM
//
//  Created by Durga Madamanchi on 5/13/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTDetailCUSReportViewController.h"
#import "OffsetCustomCell.h"
#import "TwoButtonCell.h"
#import "OnlyTextViewCell.h"
#import "AppDelegate.h"
#import "AddRowCell.h"
#import "SeatNum.h"
#import "SwitchCell.h"
#import "LeftOtherCell.h"
#import "Constants.h"
#import "LabelTextCell.h"
#import "LTSingleton.h"
#import "TextTextTextTextOther.h"
#import "OtherCell.h"
#import "LTGetLightData.h"
#import "FlightRoaster.h"
#import "Legs.h"
#import "CUSCutomerDetailCell.h"
#import "LabelTextViewCell.h"
#import "LTCUSDropdownData.h"
#import "FullOtherCell.h"
#import "LTCUSData.h"
#import "CUSSwitchCell.h"
#import "NSString+Validation.h"

@interface LTDetailCUSReportViewController () <SeatNumDelegate,PopoverDelegate>{
    NSDictionary *sourceDictionary;
    AppDelegate *appDel;
    int switchValue;
    UITextField *currentTxtField;
    BOOL lanPassSwitch;
    BOOL medicalAssinstace;
    BOOL passengerMakesClaim;
    Boolean stadoEmal;
    NSMutableArray *groupArr;
    NSArray *claimArray;
    NSArray *arr;
    LabelTextCell *lableTextCell;
    LabelTextCell *lableTextCellMail;
    Boolean stadoMail;
    NSUInteger contSelect;
}

@end

@implementation LTDetailCUSReportViewController
@synthesize customerDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        self.isCus = YES;
        appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.controller = @"CUS";
    stadoEmal = true;
    self.isCus = YES;
    stadoMail = true;
    contSelect = 0;
    
    claimArray = @[[appDel copyTextForKey:@"CLAIM"],
                   [appDel copyTextForKey:@"INFORMATIVE"]];
    [self initiallizeData];
    
    self.passingerInfoArray = [[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"], nil];
    sourceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:
                                                                     [appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"],@"Seat number",[appDel copyEnglishTextForKey:@"LANPASS"],@"Language",@"Add", nil],[NSNumber numberWithInt:1],nil];
    // Do any additional setup after loading the view from its nib.
    [self saveLegInformationInDictionary];
    [self saveUserInformationInDictionary];

    self.CUSTableView.backgroundColor = [UIColor clearColor];
}
-(void)saveLegInformationInDictionary {

    NSArray *groups = [[LTSingleton getSharedSingletonInstance].flightCUSDict objectForKey:@"groups"];
    
    NSDictionary *SelectLegDict = [[groups objectAtIndex:0] objectForKey:@"singleEvents"];
    
    NSDictionary *legDict =  [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
    
    NSString *legInfo = [NSString stringWithFormat:@"%@-%@",[legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
    
    [SelectLegDict setValue:legInfo forKey:@"Select Leg"];
}

-(void)saveUserInformationInDictionary {
    NSArray *groups = [[LTSingleton getSharedSingletonInstance].flightCUSDict objectForKey:@"groups"];
    NSDictionary *PassengerDict = [[groups objectAtIndex:1] objectForKey:@"singleEvents"];
//    if ([customerDict objectForKey:@"LANGUAGE"]) {
//        [PassengerDict setValue:[customerDict objectForKey:@"LANGUAGE"]forKey:@"Language"];
//
//    }
//    
    if ([customerDict objectForKey:@"EMAIL"]) {
        [PassengerDict setValue:[customerDict objectForKey:@"EMAIL"]forKey:@"Email"];
    }
//    if ([customerDict objectForKey:@"ADDRESS"]) {
//        [PassengerDict setValue:[customerDict objectForKey:@"ADDRESS"]forKey:@"Address"];
//        
//    }
    
    if ([customerDict objectForKey:@"SEAT_NUMBER"] && ![[customerDict objectForKey:@"SEAT_NUMBER"] isEqualToString:@""]) {
        NSMutableString *seat = (NSMutableString *)[customerDict objectForKey:@"SEAT_NUMBER"];
        [PassengerDict setValue:[seat substringToIndex:seat.length-1]forKey:@"Seat-Row"];
        [PassengerDict setValue:[seat substringFromIndex:seat.length-1]forKey:@"Letter"];
        
    }

    [self.CUSTableView reloadData];

}

#pragma mark - Internal Methods
-(void)initiallizeData {
    
    self.tableView = self.CUSTableView;
    self.ipArray = [[NSMutableArray alloc] init];
    switchValue = NO;
    lanPassSwitch = NO;
    medicalAssinstace = NO;
    passengerMakesClaim = NO;
    [LTSingleton getSharedSingletonInstance].emailValid = @"";
    self.associatedLegArray = [[NSMutableArray alloc] init];
    self.seatManteinanceArray = [[NSMutableArray alloc] init];
    self.actionTakenArray = [[NSMutableArray alloc] init];
    [LTSingleton getSharedSingletonInstance].flightCUSDict = [[NSMutableDictionary alloc] init];
    NSDictionary *flightCUSDict = [LTCUSData getFormCUSReportForDictionary:nil CUSReport:self.report];
    
    if(flightCUSDict != nil) {
        
        groupArr = [flightCUSDict objectForKey:@"groups"];
        for(NSDictionary *groupDict in groupArr)
        {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys])
            {
                for(NSDictionary *rowDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:rowName])
                {
                    DLog(@"rowDict %@",rowDict);
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"]] )
                        {
                            [self.associatedLegArray addObject:@"1"];
                        }
                    }
                    else if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"REPORT"]])
                    {
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"]])
                        {
                            [self.seatManteinanceArray addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"]])
                        {
                            [self.actionTakenArray addObject:@"1"];
                        }
                    }
                }
            }
        }
    }
    if(nil == groupArr)
        groupArr = [[NSMutableArray alloc]init];
    
    groupArr = [flightCUSDict objectForKey:@"groups"];
    
    if([groupArr count] > 0){
        
        NSArray *array = [flightCUSDict objectForKey:@"groups"];
        
        for (NSDictionary *dict in array) {
            
            if ([[dict objectForKey:@"name"] isEqualToString:[appDel copyEnglishTextForKey:@"PASSENGER_INFORMATION"]]) {
                passengerMakesClaim = [[[dict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"]] boolValue];
                lanPassSwitch = [[[dict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"LANPASS"]] boolValue];
            }
            else if([[dict objectForKey:@"name"] isEqualToString:[appDel copyEnglishTextForKey:@"REPORT"]]) {
                medicalAssinstace = [[[dict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"]] boolValue];
            }
            
        }
        
    }
    //Create the main form dictionary
    
    if ([groupArr count] == 0 ) {
        groupArr = [[NSMutableArray alloc]init];
        NSMutableDictionary *groupDict;
        NSMutableDictionary *leg = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"",[appDel copyEnglishTextForKey:@"SELECT_LEG"],nil];
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"ASSOCIATED_LEG"] forKey:@"name"];
        [groupDict setObject:leg forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
        
        NSMutableDictionary *associatePAX = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init] ,nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"], nil]];
        
        NSMutableDictionary *passengerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @"",[appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"],
                                              @"",[appDel copyEnglishTextForKey:@"SEAT_ROW"],
                                              @"",[appDel copyEnglishTextForKey:@"SEAT_LETTER"],
                                              @"",[appDel copyEnglishTextForKey:@"LANPASS"],
                                              @"",[appDel copyEnglishTextForKey:@"LANGUAGE"],
                                              @"",[appDel copyEnglishTextForKey:@"REASON"],
                                              @"",[appDel copyEnglishTextForKey:@"ADDRESS"],
                                              @"",[appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"],
                                              @"",[appDel copyEnglishTextForKey:@"PHONE_NUMBER"],
                                              @"",[appDel copyEnglishTextForKey:@"EMAIL"],
                                              nil];
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"PASSENGER_INFORMATION"] forKey:@"name"];
        [groupDict setObject:passengerInfo forKey:@"singleEvents"];
        
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"] forKey:@"name"];
        [groupDict setObject:associatePAX forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"",[appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"],
                                                 @"",[appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"],
                                                 @"",[appDel copyEnglishTextForKey:@"DOCTOR_FULL_NAME"],
                                                 @"",[appDel copyEnglishTextForKey:@"DIAGNOSE"],
                                                 @"",[appDel copyEnglishTextForKey:@"LICENSE_NUMBER"],
                                                 @"",[appDel copyEnglishTextForKey:@"EMAIL"],
                                                 @"",[appDel copyEnglishTextForKey:@"PHONE_NUMBER"],
                                                 @"",[appDel copyEnglishTextForKey:@"REPORT_DETAILS"],
                                                 nil];
        
        NSMutableDictionary *report = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init] ,[[NSMutableArray alloc] init],nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"],[appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"REPORT"] forKey:@"name"];
        [groupDict setObject:report forKey:@"multiEvents"];
        [groupDict setObject:initialStateDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        //groupDict = [[NSMutableDictionary alloc] init];
        
    }
    Uris *uri = self.flightRoster.flightUri;
    [LTSingleton getSharedSingletonInstance].flightCUSDict.accessibilityValue = uri.cus;
    [[LTSingleton getSharedSingletonInstance].flightCUSDict setObject:groupArr forKey:@"groups"];
    [self.CUSTableView setEditing:YES animated:YES];
    
    [self initializeIndexPathArray];
}

#pragma mark - Form Data Storage Methods

//Get the form elements from the dictionary
-(NSString *)getContentInFormDictForView:(id)view
{
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    
    NSInteger row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSString *event;
    NSString *value;
    
    switch (indexPath.section) {
        case 1:
        {
             sectionName = [appDel copyEnglishTextForKey:@"ASSOCIATED_LEG"];
             
             if(indexPath.row == 0){
             rowName = [appDel copyEnglishTextForKey:@"SELECT_LEG"];
             event = @"singleEvents";
             }
        }
            break;
        case 2:
        {
            sectionName = [appDel copyEnglishTextForKey:@"PASSENGER_INFORMATION"];
            
            if(indexPath.row == 0){
                rowName = [appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"];
                event = @"singleEvents";
                [self mailObli];
            }
            else if(indexPath.row == 1) {
                rowName = @"Seat Number";
                event = @"singleEvents";
                
            }
            else if (indexPath.row == 2) {
                rowName = [appDel copyEnglishTextForKey:@"LANPASS"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 3) {
                
                rowName = [appDel copyEnglishTextForKey:@"LANGUAGE"];
                event = @"singleEvents";
                
            }
            else if(indexPath.row == 4) {
                rowName = [appDel copyEnglishTextForKey:@"ADDRESS"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 5)
            {
                rowName = [appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"];
                event = @"singleEvents";
                
                
            }else if(indexPath.row == 6)
            {
                rowName = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 7)
            {
                rowName = [appDel copyEnglishTextForKey:@"EMAIL"];
                event = @"singleEvents";
                
            }
            else if((indexPath.row > 8)  && (indexPath.row <= (9+self.associatedLegArray.count))) {
                
                rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                event = @"multiEvents";
                row = indexPath.row - 8;
            }
        }
            break;
        case 3:{
            sectionName = [appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"];
            
            if(indexPath.row > 0) {
                rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                event = @"multiEvents";
                row = indexPath.row;
            }
        }
            break;
        case 4:
        {
            sectionName = [appDel copyEnglishTextForKey:@"REPORT"];
            {
                if(indexPath.row == 0){
                    rowName = [appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"];
                    event = @"singleEvents";
                }
                else if(indexPath.row == 1){
                    rowName = [appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row >1 &&(indexPath.row <= (self.seatManteinanceArray.count+1)))
                {
                    rowName = [appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"];
                    event = @"multiEvents";
                    row = indexPath.row - 1;
                }
                else if(indexPath.row > (self.seatManteinanceArray.count+1) && (indexPath.row <= (self.seatManteinanceArray.count+1+self.actionTakenArray.count+1)))
                {
                    rowName = [appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                    event = @"multiEvents";
                    row = indexPath.row - (self.seatManteinanceArray.count+2);
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 3)) {
                    rowName = [appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4) && !medicalAssinstace){
                    rowName = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                    event = @"singleEvents";
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4))
                {
                    rowName = [appDel copyEnglishTextForKey:@"DOCTOR_FULL_NAME"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 5))
                {
                    rowName = [appDel copyEnglishTextForKey:@"LICENSE_NUMBER"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 6))
                {
                    rowName = [appDel copyEnglishTextForKey:@"DIAGNOSE"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 7))
                {
                    rowName = [appDel copyEnglishTextForKey:@"EMAIL"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 8))
                {
                    rowName = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 9))
                {
                    rowName = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                    event = @"singleEvents";
                }
            }
            
        }
            break;
    }
    @try {
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict;
        if([event isEqualToString:@"singleEvents"])
        {
            
            eventDict = [groupDict objectForKey:@"singleEvents"];
            
            //NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
            
            value = [eventDict objectForKey:rowName];
            if([view isKindOfClass:[UITextField class]])
                value = [eventDict objectForKey:((UITextField *)view).accessibilityIdentifier];
            else if([view isKindOfClass:[UITextView class]]) {
                value = [eventDict objectForKey:((UITextView *)view).accessibilityIdentifier];
            }
            else if([view isKindOfClass:[TestView class]])
            {
                NSString *testViewValue = [eventDict objectForKey:((TestView *)view).key];
                if(testViewValue && [testViewValue length]>0)
                {//REPORT_DETAILS
                    if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]] )
                        value = testViewValue;
                    else if([testViewValue containsString:@"-1"]){
                        NSString *other = [testViewValue substringFromIndex:3];
                        
                        value = [[other componentsSeparatedByString:@"||"] firstObject];
                    }
                    else
                        value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
                }
            }
        }
        else if([event isEqualToString:@"multiEvents"])
        {
            NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
            if ([cellArr count]<=0 || row <=0 ) {
                return @"";
            }else if([cellArr count]>=row){
                eventDict = [cellArr objectAtIndex:row - 1];
            }else{
                return @"";
            }
            
            if([view isKindOfClass:[TestView class]])
            {
                NSString *testViewValue = [eventDict objectForKey:((TestView *)view).key];
                if(testViewValue && [testViewValue length]>0)
                {
                    if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]])
                        value = testViewValue;
                    else if([testViewValue containsString:@"-1"]){
                        NSString *other = [testViewValue substringFromIndex:3];
                        
                        value = [[other componentsSeparatedByString:@"||"] firstObject];
                    }
                    else
                        value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
                }
            }
            else if([view isKindOfClass:[UITextField class]])
                value = [eventDict objectForKey:((UITextField *)view).accessibilityIdentifier];
            
        }
    }
    @catch (NSException *exception) {
        
    }
    return  value;
}

//Store the form elements in a dictionary
-(void)setContentInFormDictForView:(id)view {
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    OffsetCustomCell *cell;
    
    if(ISiOS8)
        cell = ((OffsetCustomCell *)[[view superview] superview]);
    else
        cell = ((OffsetCustomCell *)[[[view superview] superview] superview]);
    
    if([cell isKindOfClass:[TextTextTextTextOther class]]) {
        if([view isKindOfClass:[TestView class]]) {
            TextTextTextTextOther *cell1 = (TextTextTextTextOther*)cell;
            NSDictionary *docValidationDict = [LTCUSDropdownData getDictForKey:((TestView*)view).selectedTextField.text];
            cell1.docNumberTextField.placeholder = [[[docValidationDict objectForKey:@"RegExpression"] allKeys] objectAtIndex:0];
        }
    }

    if(indexPath == nil)
        return;
    
    NSInteger row = 0;
    NSString *sectionName;
    NSString *rowName = @"";
    NSString *event;
    
    switch (indexPath.section) {
        case 1:
        {
            sectionName = [appDel copyEnglishTextForKey:@"ASSOCIATED_LEG"];
            
            if(indexPath.row == 0){
                // rowName = [appDel copyEnglishTextForKey:@"SELECT_LEG"];
                rowName = @"";
                event = @"singleEvents";
            }
            
        }
            break;
        case 2:
        {
            sectionName = [appDel copyEnglishTextForKey:@"PASSENGER_INFORMATION"];
            
            if(indexPath.row == 0){
                rowName =[appDel copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"];
                event = @"singleEvents";
                [self mailObli];
            }
            else if(indexPath.row == 1) {
                rowName = @"Seat Number";
                event = @"singleEvents";
                
            }
            else if (indexPath.row == 2) {
                rowName = [appDel copyEnglishTextForKey:@"LANPASS"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 3) {
                
                rowName = [appDel copyEnglishTextForKey:@"LANGUAGE"];
                
                event = @"singleEvents";
                if (contSelect != 2){
                     contSelect++;
                    if (contSelect == 2){
                        stadoMail = false;
                    }
                }else{
                    stadoMail = false;
                }
            }
            else if(indexPath.row == 4) {
                rowName = [appDel copyEnglishTextForKey:@"ADDRESS"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 5)
            {
                rowName = [appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"];
                event = @"singleEvents";
                if (contSelect != 2){
                    contSelect++;
                    
                    if (contSelect == 2){
                      stadoMail = false;
                    }
                }else{
                   stadoMail = false;
                }
                
            }else if(indexPath.row == 6)
            {
                rowName = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                event = @"singleEvents";
            }
            else if(indexPath.row == 7)
            {
                rowName = [appDel copyEnglishTextForKey:@"EMAIL"];
                event = @"singleEvents";
                
            }
            else if((indexPath.row > 8)  && (indexPath.row <= (9+self.associatedLegArray.count))) {
                
                rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                event = @"multiEvents";
                row = indexPath.row - 8;
            }
        }
            break;
        case 3:{
            sectionName = [appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"];
            
            if(indexPath.row > 0) {
                rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                event = @"multiEvents";
                row = indexPath.row;
            }
        }
            break;
        case 4:
        {
            sectionName = [appDel copyEnglishTextForKey:@"REPORT"];
            {
                if(indexPath.row == 0){
                    rowName = [appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"];
                    event = @"singleEvents";
                }
                else if(indexPath.row == 1){
                    rowName = [appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row >1 &&(indexPath.row <= (self.seatManteinanceArray.count+1)))
                {
                    rowName = [appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"];
                    event = @"multiEvents";
                    row = indexPath.row - 1;
                }
                else if(indexPath.row > (self.seatManteinanceArray.count+1) && (indexPath.row <= (self.seatManteinanceArray.count+1+self.actionTakenArray.count+1)))
                {
                    rowName = [appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                    event = @"multiEvents";
                    row = indexPath.row - (self.seatManteinanceArray.count+2);
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 3)) {
                    rowName = [appDel copyEnglishTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4) && !medicalAssinstace){
                    rowName = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                    event = @"singleEvents";
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4))
                {
                    rowName = [appDel copyEnglishTextForKey:@"DOCTOR_FULL_NAME"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 5))
                {
                    rowName = [appDel copyEnglishTextForKey:@"LICENSE_NUMBER"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 6))
                {
                    rowName = [appDel copyEnglishTextForKey:@"DIAGNOSE"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 7))
                {
                    rowName = [appDel copyEnglishTextForKey:@"EMAIL"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 8))
                {
                    rowName = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                    event = @"singleEvents";
                    
                }
                else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 9))
                {
                    rowName = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                    event = @"singleEvents";
                }
            }
            
        }
            break;
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    NSMutableDictionary *eventDict;
    if([event isEqualToString:@"singleEvents"])
    {
        
        eventDict = [groupDict objectForKey:@"singleEvents"];
        
    }
    else if([event isEqualToString:@"multiEvents"])
    {
        NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
        eventDict = [cellArr objectAtIndex:row - 1];
    }
    
    if([view isKindOfClass:[UISwitch class]]){
        [eventDict setObject:((switchValue)? @"YES": @"NO")  forKey:rowName];
    }
    else if([view isKindOfClass:[UITextView class]]) {
        
        [eventDict setObject:((UITextView *)view).text forKey:((UITextView *)view).accessibilityIdentifier];
    }
    else if([view isKindOfClass:[TestView class]]) {
        
        if([((TestView*)view).selectedValue containsString:@"-1"]) {
            [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
        }else {
            NSString *index = [LTCUSDropdownData getIndexValue:((TestView*)view).key atIndex:((TestView *)view).selectedIndex forDocType:@"LAN"];
            
            [eventDict setObject:[index stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
        }
    }
    else if([view isKindOfClass:[UISegmentedControl class]]){
        UISegmentedControl *seg= (UISegmentedControl*)view;
        if(seg.tag == 55)
        {
            if([self.legsArray count]>0)
                [eventDict setObject:[self.legsArray objectAtIndex:[view selectedSegmentIndex]]  forKey:rowName];
        }
        else{
            if([claimArray count]>0)
                [eventDict setObject:[NSString stringWithFormat:@"%ld|%@",[view selectedSegmentIndex],[claimArray objectAtIndex:[view selectedSegmentIndex]]]  forKey:rowName];
        }
    }
    else {
        [eventDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    }
    
    [[LTSingleton getSharedSingletonInstance].flightCUSDict setObject:groupArr forKey:@"groups"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mailObli{
    
    if(stadoEmal){

        lableTextCellMail.reportLabel.text = [appDel copyTextForKey:@"EMAIL"];
        stadoEmal = false;
        
    }else{
        lableTextCellMail.reportLabel.attributedText = [[[appDel copyTextForKey:@"EMAIL"]
                                                         stringByAppendingString:@"*"] mandatoryString];
         stadoEmal = true;
        
    }
    
    
}

#pragma mark - Navigate Field for Segment Control

-(void)navigateField:(UISegmentedControl *)segControl {
    OffsetCustomCell *cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
    id view;
    if(segControl.selectedSegmentIndex == 0) {
        view = [cell viewWithTag:currentTxtField.tag - 1];
    }
    else {
        view = [cell viewWithTag:currentTxtField.tag + 1];
    }
    if(view == nil) {
        
        if(segControl.selectedSegmentIndex == 0) {
            for(NSInteger section = cell.indexPath.section; section >= 0; section--) {
                BOOL isPrevFieldFound = NO;
                NSInteger rowVal;int tempTag = 0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.CUSTableView numberOfRowsInSection:section]-1;
                for(NSInteger row = rowVal; row >= 0; row--) {
                    cell = (OffsetCustomCell *)[self.CUSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]) {
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]) {
                        tempTag = MANDATORYTAG;
                    }
                    if([cell viewWithTag:tempTag]) {
                        if([[[cell viewWithTag:tempTag] superview] isKindOfClass:[TestView class]]) {
                            
                        }
                        else {
                            [[cell viewWithTag:tempTag] becomeFirstResponder];
                            isPrevFieldFound = YES;
                            break;
                        }
                    }
                }
                if(isPrevFieldFound)
                    break;
            }
        }
        else {
            for(NSInteger section = cell.indexPath.section; section < [self.CUSTableView numberOfSections]; section++) {
                BOOL isNextFieldFound = NO;
                NSInteger rowVal; int tempTag = 0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(NSInteger row = rowVal; row < [self.CUSTableView numberOfRowsInSection:section]; row++) {
                    cell = (OffsetCustomCell *)[self.CUSTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]) {
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]) {
                        tempTag = MANDATORYTAG;
                    }
                    
                    if([cell viewWithTag:tempTag]) {
                        if([[[cell viewWithTag:tempTag] superview] isKindOfClass:[TestView class]]) {
                            
                        }
                        else {
                            [[cell viewWithTag:tempTag] becomeFirstResponder];
                            isNextFieldFound = YES;
                            break;
                        }
                    }
                }
                if(isNextFieldFound)
                    break;
            }
        }
    }
    else if(view!=nil && [view isKindOfClass:[UITextField class]]) {
        [view becomeFirstResponder];
    }
}

#pragma mark - Popover Delegate Methods
-(void)valueSelectedInPopover:(TestView *)testView {
    [self setContentInFormDictForView:testView];
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;    [self.CUSTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    //if([LTSingleton getSharedSingletonInstance].sendCusReport)
    {
        [self updateCusReportDictionary];
    }
}
-(void)valuesSelectedInPopOver:(UITextField *)textFields {
    [self setContentInFormDictForView:textFields];
    
}
#pragma -mark TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 1;
            break;
        case 2:
            count = 8;
            break;
        case 3:
            count = 1 + self.associatedLegArray.count;
            break;
        case 4:
            if(medicalAssinstace) {
                count = (2 + self.seatManteinanceArray.count + self.actionTakenArray.count + 8);
                
            }
            else {
                count = (1 + self.seatManteinanceArray.count + self.actionTakenArray.count + 4);
            }
            break;
    }
    return count;
}

-(NSMutableAttributedString *)attributedStringforFirstname:(NSString *)firstName lastName:(NSString *)lastName{
    NSMutableAttributedString *attributedName;
    NSRange boldedRange;
    
    NSString *str = [NSString stringWithFormat:@"%@, %@",firstName,lastName];
    attributedName = [[NSMutableAttributedString alloc] initWithString:str];
    boldedRange = NSMakeRange(0, [firstName length]);
    
    [attributedName addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:22] range:boldedRange];
    [attributedName addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:22] range:NSMakeRange([firstName length]+1,[attributedName length]-([firstName length]+1))];
    
    return attributedName;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.readonly) {
        [cell setUserInteractionEnabled:NO];
        cell.contentView.alpha = 0.6f;
    }
    
    if([LTSingleton getSharedSingletonInstance].sendCusReport && !([NSStringFromClass([cell class]) isEqualToString:@"AddRowCell"])){
        self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] validateCusCell:(OffsetCustomCell *)cell withLeastIndexPath:self.leastIndexPath];
    }
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        return nil;
    }
    
    static NSString *twoButtonIdentifier = @"TwoButtonCell";
    static NSString *headingIdentifier = @"HeaderCell";
    static NSString *seatNumIdentifier = @"SeatNum";
    static NSString *switchIdentifier = @"SwitchCell";
    static NSString *cusSwitchIdentifier = @"CUSSwitchCell";
    
    static NSString *labelTextCellID = @"LabelTextCellID";
    static NSString *textTextTextTextOtherID = @"TextTextTextTextOtherID";
    static NSString *otherCellId = @"OtherCellID";
    static NSString *labelTextViewCellID = @"LabelTextViewCellID";
    static NSString *leftOtherCellID = @"LeftOtherCellID";
    
    LabelTextViewCell *textViewCell;
    OffsetCustomCell *cell;
    AddRowCell *headingCell;
    LeftOtherCell *leftOtherCell;
    TextTextTextTextOther *textTextTextTextOther;
    OtherCell *otherCell;
    
    TwoButtonCell *twoButtonCell;
    CUSSwitchCell *cusSWitchCell;
    
    switch (indexPath.section) {
        case 0: {
            
            return [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        } break;
        case 1: {
            
            return [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        } break;
        case 2: {
            
            if(indexPath.row == 0) {
                
                twoButtonCell = (TwoButtonCell *)[self createCellForTableView:tableView withCellID:twoButtonIdentifier];
                cell = twoButtonCell;
                twoButtonCell.indexPath = indexPath;
                twoButtonCell.leftLabel.text = [appDel copyTextForKey:@"PASSENGER_MAKES_CLAIM"];
                [twoButtonCell.leftLabel setFont:KRobotoFontForLeftLabel];
                twoButtonCell.leftLabel.textColor = KRobotoFontColorForLeftLabel;
                twoButtonCell.contentView.backgroundColor = [UIColor clearColor];
                UISegmentedControl *segmentedController = ((TwoButtonCell *)cell).segmentControl;
                segmentedController.frame = CGRectMake(320, 5, 200, 30);
                while(segmentedController.numberOfSegments > 0) {
                    [segmentedController removeSegmentAtIndex:0 animated:NO];
                }
                for (int i = 0; i < 2; i++) {
                    if(i == 0)
                        [segmentedController insertSegmentWithTitle:[appDel copyTextForKey:@"CLAIM"] atIndex:1 animated:NO];
                    else {
                        [segmentedController insertSegmentWithTitle:[appDel copyTextForKey:@"INFORMATIVE"] atIndex:1 animated:NO];
                    }
                }
                
                NSInteger selectedIndex = 0;
                segmentedController.tag = 66;
                
                [twoButtonCell.segmentControl addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventValueChanged];
                segmentedController.enabled = !self.readonly;
                
                NSString *selectedValue = [self getContentInFormDictForView:((TwoButtonCell *)cell).segmentControl];
                
                if([selectedValue isEqualToString:@"1|Informativo"]){
                    stadoEmal = true;
                }else{
                    stadoEmal = false;
                }
                
                [self mailObli];
                
                if([selectedValue length] > 0) {
                    int index = [[[selectedValue componentsSeparatedByString:@"|"] firstObject] intValue];
                    
                    selectedIndex = [claimArray indexOfObject:selectedValue];
                    ((TwoButtonCell *)cell).segmentControl.selectedSegmentIndex = index;
                    DLog(@"%ld",selectedIndex);
                }
                else {
                    
                    ((TwoButtonCell *)cell).segmentControl.selectedSegmentIndex = 1;
                    [self setContentInFormDictForView:twoButtonCell.segmentControl];
                    
                }
                cell.backgroundColor = [UIColor clearColor];
                
            }
            else if(indexPath.row == 1) {
                
                SeatNum *seatNum = (SeatNum *)[self createCellForTableView:tableView withCellID:seatNumIdentifier];
                cell = seatNum;
                seatNum.delegate = self;
                seatNum.indexPath = indexPath;
                seatNum.leftLabel.text = [appDel copyTextForKey:@"SELECT_SEAT"];
                [seatNum.leftLabel setFont:KRobotoFontForLeftLabel];
                seatNum.leftLabel.textColor = KRobotoFontColorForLeftLabel;
                seatNum.leftLabel.frame = CGRectMake(42, 10, 150, 20);
                seatNum.button.frame = CGRectMake(320, 5, 260, 30);
                seatNum.seatRowTxt.frame = CGRectMake(320, 5, 130, 30);
                seatNum.seatLetterTxt.frame = CGRectMake(450, 5, 130, 30);
                seatNum.seatRowTxt.font = KRobotoFontForLeftLabel;
                seatNum.seatRowTxt.textColor = KRobotoFontColorForRightLabel;
                seatNum.seatLetterTxt.font = KRobotoFontForLeftLabel;
                seatNum.seatLetterTxt.textColor = KRobotoFontColorForRightLabel;
                
                seatNum.seatLetterTxt.layer.borderWidth = 1.0;
                seatNum.seatRowTxt.layer.borderWidth = 1.0;
                
                seatNum.seatLetterTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_LETTER"];
                [seatNum.seatLetterTxt setText:[self getContentInFormDictForView:seatNum.seatLetterTxt]];
                seatNum.seatLetterTxt.layer.borderWidth = 0.0f;
                seatNum.seatRowTxt.layer.borderWidth = 0.0f;
                [seatNum.seatLetterTxt setBackgroundColor:[UIColor clearColor]];
                [seatNum.seatRowTxt setBackgroundColor:[UIColor clearColor]];
                seatNum.seatRowTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_ROW"];
                [seatNum.seatRowTxt setText:[self getContentInFormDictForView:seatNum.seatRowTxt]];
                seatNum.seatLetterTxt.layer.borderWidth = 0.0f;
                seatNum.seatRowTxt.layer.borderWidth = 0.0f;
                seatNum.seatRowTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                seatNum.seatLetterTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                seatNum.contentView.hidden = YES;
                seatNum.button.enabled = !self.readonly;
            }
            else if (indexPath.row == 2) {
                
                cell = (SwitchCell *)[self createCellForTableView:tableView withCellID:switchIdentifier];
                cell.indexPath = indexPath;
                cell.leftLabel.text = [appDel copyEnglishTextForKey:@"LANPASS"];
                [cell.leftLabel setFont:KRobotoFontForLeftLabel];
                cell.leftLabel.textColor = KRobotoFontColorForLeftLabel;
                ((SwitchCell *)cell).rightSwitch.tag = 33;
                ((SwitchCell *)cell).rightSwitch.on = lanPassSwitch;
                ((SwitchCell *)cell).rightSwitch.frame = CGRectMake(640, 5, 200, 20);
                
                cell.indexPath = indexPath;
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.hidden = YES;
                ((SwitchCell *)cell).rightSwitch.enabled = !self.readonly;
            }
            else if(indexPath.row == 3) {
                
                leftOtherCell = (LeftOtherCell *)[self createCellForTableView:tableView withCellID:leftOtherCellID];
                cell = leftOtherCell;
                leftOtherCell.indexPath = indexPath;
                leftOtherCell.reasonTxt.typeOfDropDown = NormalDropDown;
                leftOtherCell.reasonTxt.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"LANGUAGE"] forDocType:@"LAN"];
                leftOtherCell.reasonTxt.delegate = self;
                leftOtherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"LANGUAGE"];
                
                leftOtherCell.reasonLbl.textColor = KRobotoFontColorForLeftLabel;
                [leftOtherCell.reasonLbl setFont:KRobotoFontForLeftLabel];
                
                leftOtherCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"LANGUAGE"] stringByAppendingString:@"*"] mandatoryString];
                leftOtherCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
                leftOtherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:leftOtherCell.reasonTxt];
                // leftOtherCell.reasonTxt.selectedTextField.borderStyle = UITextBorderStyleNone;
                leftOtherCell.reasonTxt.selectedTextField.backgroundColor = [UIColor clearColor];
                leftOtherCell.reasonTxt.selectedTextField.textAlignment = NSTextAlignmentRight;
                leftOtherCell.reasonTxt.selectedTextField.layer.borderWidth = 0.0f;
                leftOtherCell.reasonTxt.selectedTextField.font = KRobotoFontForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.textColor = KRobotoFontColorForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                
                leftOtherCell.reasonLbl.frame = CGRectMake(42, 10, 200, 20);
                leftOtherCell.reasonTxt.frame = CGRectMake(375, 0, 320, 40);
                
                leftOtherCell.reasonTxt.dropDownButton.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                
            }
            else if(indexPath.row == 4) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCell.indexPath = indexPath;
                cell = lableTextCell;
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"ADDRESS"];
                [lableTextCell.reportLabel setFont:KRobotoFontForLeftLabel];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontForRightLabel;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"ADDRESS"];
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                
                lableTextCell.textField.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
            }
            else if(indexPath.row == 5)
            {
                leftOtherCell = (LeftOtherCell *)[self createCellForTableView:tableView withCellID:leftOtherCellID];
                cell = leftOtherCell;
                leftOtherCell.indexPath = indexPath;
                leftOtherCell.reasonTxt.typeOfDropDown = NormalDropDown;
                leftOtherCell.reasonTxt.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"] forDocType:@"LAN"];
                leftOtherCell.reasonTxt.delegate = self;
                leftOtherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"];

                leftOtherCell.reasonLbl.textColor = KRobotoFontColorForLeftLabel;

                
                leftOtherCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"COUNTRY_OF_RESIDENCE"] stringByAppendingString:@"*"] mandatoryString];
                [leftOtherCell.reasonLbl setFont:kCUSFont];
                leftOtherCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
                leftOtherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:leftOtherCell.reasonTxt];
                
               // leftOtherCell.reasonLbl.textColor = KRobotoFontColorForLeftLabel;
                [leftOtherCell.reasonLbl setFont:KRobotoFontForLeftLabel];
                leftOtherCell.reasonTxt.selectedTextField.backgroundColor = [UIColor clearColor];
                leftOtherCell.reasonTxt.selectedTextField.textAlignment = NSTextAlignmentRight;
                leftOtherCell.reasonTxt.selectedTextField.layer.borderWidth = 0.0f;
                leftOtherCell.reasonTxt.selectedTextField.font = KRobotoFontForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.textColor = KRobotoFontColorForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                
                leftOtherCell.reasonLbl.frame = CGRectMake(42, 10, 200, 20);
                leftOtherCell.reasonTxt.frame = CGRectMake(375, 0, 320, 40);
                
                leftOtherCell.reasonTxt.dropDownButton.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                
            }
            else if(indexPath.row == 6) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                cell = lableTextCell;
                lableTextCell.indexPath = indexPath;
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"PHONE_NUMBER"];
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                
                [lableTextCell.reportLabel setFont:KRobotoFontForLeftLabel];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontForRightLabel;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                lableTextCell.textField.keyboardType = UIKeyboardTypeNumberPad;
                //[lableTextCell.reportLabel setFont:kCUSFont];
                
                lableTextCell.textField.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
            }
            else if(indexPath.row == 7) {
                if (stadoMail)
                {
                lableTextCellMail= nil;
                lableTextCellMail = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCellMail.indexPath = indexPath;
                cell = lableTextCellMail;
                
                lableTextCellMail.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                 if(stadoEmal){
                         lableTextCellMail.reportLabel.attributedText = [[[appDel copyTextForKey:@"EMAIL"]stringByAppendingString:@"*"] mandatoryString];
                 }else{
                       lableTextCellMail.reportLabel.text = [appDel copyTextForKey:@"EMAIL"]; //stringByAppendingString:@"*"] mandatoryString];
                 }
                lableTextCellMail.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"EMAIL"];
                
                [lableTextCellMail.reportLabel setFont:KRobotoFontForLeftLabel];
                lableTextCellMail.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCellMail.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCellMail.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                lableTextCellMail.textField.textAlignment = NSTextAlignmentRight;
                lableTextCellMail.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                lableTextCellMail.textField.borderStyle = UITextBorderStyleNone;
                lableTextCellMail.textField.backgroundColor = [UIColor clearColor];
                lableTextCellMail.textField.layer.borderWidth = 0.0f;
                lableTextCellMail.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCellMail.rightIndicator.hidden = true;
                lableTextCellMail.textField.font = KRobotoFontForRightLabel;
                lableTextCellMail.textField.textColor = KRobotoFontColorForRightLabel;
                
                lableTextCellMail.textField.delegate = self;
                lableTextCellMail.textField.tag = MANDATORYTAG;
                lableTextCellMail.textField.text = [self getContentInFormDictForView:lableTextCellMail.textField];
                [lableTextCellMail.textField setFont:KRobotoFontForRightLabel];
                lableTextCellMail.textField.keyboardType = UIKeyboardTypeEmailAddress;
                
                lableTextCellMail.textField.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                }
                stadoMail = true;
                
            }
            
            else {
                DLog(@"%@",indexPath);
            }
        }
            break;
        case 3: {
            if(indexPath.row == 0) {
                headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
                headingCell.headingLbl.text = [appDel copyTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                [headingCell.headingLbl setFont:KRobotoFontForLeftLabel];
                [headingCell.headingLbl setTextColor:KRobotoFontColorForLeftLabel];
                
                cell= headingCell;
                headingCell.indexPath = indexPath;
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor redColor];
                
                headingCell.controlButton.hidden = self.readonly;
                
            }
            else if((indexPath.row > 0)  && (indexPath.row <= (1 + self.associatedLegArray.count))) {
                
                textTextTextTextOther = (TextTextTextTextOther*)[self createCellForTableView:tableView withCellID:textTextTextTextOtherID];
                
                textTextTextTextOther.firstNameTextField.enabled = !self.readonly;
                textTextTextTextOther.lastnameTextField.enabled = !self.readonly;
                textTextTextTextOther.secondLastNameTextField.enabled = !self.readonly;
                textTextTextTextOther.docNumberTextField.enabled = !self.readonly;
                textTextTextTextOther.doctypetestView.dropDownButton.enabled = !self.readonly;
                textTextTextTextOther.controlButton.hidden = self.readonly;
                
                cell = textTextTextTextOther;
                cell.indexPath = indexPath;
                textTextTextTextOther.nameLabel.textColor = KCUSFontColor;
                
                textTextTextTextOther.nameLabel.attributedText = [[[appDel copyTextForKey:@"FIRST_NAME"] stringByAppendingString:@"*"] mandatoryString];
                textTextTextTextOther.firstNameTextField.delegate = self;
                textTextTextTextOther.firstNameTextField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"FIRST_NAME"];
                textTextTextTextOther.firstNameTextField.tag = MANDATORYTAG;
                textTextTextTextOther.firstNameTextField.text = [self getContentInFormDictForView:textTextTextTextOther.firstNameTextField];
                textTextTextTextOther.firstNameTextField.backgroundColor = [UIColor clearColor];
                textTextTextTextOther.firstNameTextField.font = KRobotoFontSize18;
                textTextTextTextOther.firstNameTextField.textColor = KRobotoFontColorForRightLabel;
                
                [textTextTextTextOther.nameLabel setFont:kCUSTitleFont];
                
                textTextTextTextOther.lastNameLabel.textColor = KCUSFontColor;
                
                textTextTextTextOther.lastNameLabel.attributedText = [[[appDel copyTextForKey:@"LAST_NAME"] stringByAppendingString:@"*"] mandatoryString];
                [textTextTextTextOther.lastNameLabel setFont:kCUSTitleFont];
                textTextTextTextOther.lastnameTextField.delegate = self;
                textTextTextTextOther.lastnameTextField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"LAST_NAME"];
                textTextTextTextOther.lastnameTextField.backgroundColor = [UIColor clearColor];
                textTextTextTextOther.lastnameTextField.font = KRobotoFontSize18;
                textTextTextTextOther.lastnameTextField.textColor = KRobotoFontColorForRightLabel;
                
                
                textTextTextTextOther.lastnameTextField.tag = MANDATORYTAG;
                
                textTextTextTextOther.lastnameTextField.text = [self getContentInFormDictForView:textTextTextTextOther.lastnameTextField];
                textTextTextTextOther.seconLastNameLabel.textColor = KCUSFontColor;
                
                textTextTextTextOther.seconLastNameLabel.text = [appDel copyTextForKey:@"SECOND_LAST_NAME"];
                [textTextTextTextOther.seconLastNameLabel setFont:kCUSTitleFont];
                textTextTextTextOther.secondLastNameTextField.delegate = self;
                textTextTextTextOther.secondLastNameTextField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SECOND_LAST_NAME"];
                textTextTextTextOther.secondLastNameTextField.text = [self getContentInFormDictForView:textTextTextTextOther.secondLastNameTextField];
                textTextTextTextOther.secondLastNameTextField.backgroundColor = [UIColor clearColor];
                textTextTextTextOther.secondLastNameTextField.font = KRobotoFontSize18;
                textTextTextTextOther.secondLastNameTextField.textColor = KRobotoFontColorForRightLabel;
                
                [textTextTextTextOther.docTypeLabel setTextColor:KRobotoFontColorForRightLabel];
                textTextTextTextOther.docTypeLabel.attributedText = [[[appDel copyTextForKey:@"DOCUMENT_TYPE"] stringByAppendingString:@"*"] mandatoryString];
                textTextTextTextOther.docTypeLabel.backgroundColor = [UIColor clearColor];
                [textTextTextTextOther.docTypeLabel setFont:KRobotoFontSize18];
                
                textTextTextTextOther.doctypetestView.typeOfDropDown = NormalDropDown;
                textTextTextTextOther.doctypetestView.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"] forDocType:@"LAN"];
                textTextTextTextOther.doctypetestView.delegate = self;
                textTextTextTextOther.doctypetestView.selectedTextField.tag = MANDATORYTAG;
                
                textTextTextTextOther.docNumberLabel.textColor = KCUSFontColor;
                
                textTextTextTextOther.doctypetestView.key = [appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"];
                textTextTextTextOther.doctypetestView.selectedTextField.text = [self getContentInFormDictForView:textTextTextTextOther.doctypetestView];
                
                textTextTextTextOther.docNumberLabel.attributedText = [[[appDel copyTextForKey:@"DOCUMENT_NUMBER"] stringByAppendingString:@"*"] mandatoryString];
                [textTextTextTextOther.docNumberLabel setFont:kCUSTitleFont];
                
                textTextTextTextOther.docNumberTextField.delegate = self;
                textTextTextTextOther.docNumberTextField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"DOCUMENT_NUMBER"];
                textTextTextTextOther.docNumberTextField.tag = MANDATORYTAG;
                textTextTextTextOther.docNumberTextField.backgroundColor = [UIColor clearColor];
                textTextTextTextOther.docNumberTextField.font = KRobotoFontSize18;
                textTextTextTextOther.docNumberTextField.textColor = KRobotoFontColorForRightLabel;
                
                
                [textTextTextTextOther.docNumberTextField setKeyboardType:UIKeyboardTypeNumberPad];
                textTextTextTextOther.docNumberTextField.text = [self getContentInFormDictForView:textTextTextTextOther.docNumberTextField];
                
                if([textTextTextTextOther.doctypetestView.selectedTextField.text length]>0) {
                    NSDictionary *docValidationDict = [LTCUSDropdownData getDictForKey:textTextTextTextOther.doctypetestView.selectedTextField.text];
                    textTextTextTextOther.docNumberTextField.placeholder = [[[docValidationDict objectForKey:@"Example"] allKeys] objectAtIndex:0];
                    textTextTextTextOther.doctypetestView.selectedTextField.font = KRobotoFontSize18;
                    textTextTextTextOther.doctypetestView.selectedTextField.textColor = KCUSFontColor;
                }
                
                textTextTextTextOther.tag = 654;
//                textTextTextTextOther.doctypetestView.selectedTextField.layer.borderWidth = 0.0f;
                textTextTextTextOther.doctypetestView.selectedTextField.layer.sublayerTransform=CATransform3DMakeTranslation(0, 0, 10);
                textTextTextTextOther.backgroundColor = [UIColor clearColor];
            }
            cell.contentView.backgroundColor=[UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
        }
            break;
        case 4: {
            if(indexPath.row == 0) {
                leftOtherCell = (LeftOtherCell *)[self createCellForTableView:tableView withCellID:leftOtherCellID];
                cell = leftOtherCell;
                leftOtherCell.indexPath = indexPath;
                //changed by palash
                leftOtherCell.reasonTxt.typeOfDropDown = NormalDropDown;
                leftOtherCell.reasonTxt.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"] forDocType:@"LAN"];
                leftOtherCell.reasonTxt.delegate = self;
                
                leftOtherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"];
                leftOtherCell.reasonLbl.textColor = KRobotoFontColorForLeftLabel;
                [leftOtherCell.reasonLbl setFont:KRobotoFontForLeftLabel];
                
                leftOtherCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"REASON_FOR_REPORT"] stringByAppendingString:@"*"] mandatoryString];
                leftOtherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:leftOtherCell.reasonTxt];
                leftOtherCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
                leftOtherCell.reasonTxt.selectedTextField.backgroundColor = [UIColor clearColor];
                leftOtherCell.reasonTxt.selectedTextField.textAlignment = NSTextAlignmentRight;
                leftOtherCell.reasonTxt.selectedTextField.layer.borderWidth = 0.0f;
                leftOtherCell.reasonTxt.selectedTextField.font = KRobotoFontForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.textColor = KRobotoFontColorForRightLabel;
                leftOtherCell.reasonTxt.selectedTextField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                
                leftOtherCell.reasonLbl.frame = CGRectMake(42, 10, 200, 20);
                leftOtherCell.reasonTxt.frame = CGRectMake(375, 0, 320, 40);
                
                leftOtherCell.reasonTxt.dropDownButton.enabled = !self.readonly;
                
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
            }
            else if(indexPath.row == 1) {
                headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
                headingCell.headingLbl.text = [appDel copyTextForKey:@"SEAT_MAINTENANCE"];
                cell= headingCell;
                //[headingCell.headingLbl setFont:kCUSFont];
                headingCell.indexPath = indexPath;
                headingCell.headingLbl.textColor = KRobotoFontColorForLeftLabel;
                [headingCell.headingLbl setFont:KRobotoFontForLeftLabel];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                headingCell.controlButton.hidden = self.readonly;
                
            }
            else if(indexPath.row > 1 && (indexPath.row <= (self.seatManteinanceArray.count+1))) {
                otherCell = (OtherCell *)[self createCellForTableView:tableView withCellID:otherCellId];
                otherCell.indexPath = indexPath;
                cell = otherCell;
                otherCell.reasonLbl.textColor = KCUSFontColor;
                
                otherCell.reasonTxt.typeOfDropDown = NormalDropDown;
                otherCell.reasonTxt.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"] forDocType:@"LAN"];
                otherCell.reasonTxt.delegate = self;
                [otherCell.reasonLbl setFont:kCUSTitleFont];
                otherCell.reasonLbl.text = [appDel copyTextForKey:@"SEAT_MAINTENANCE"] ;
                otherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"];
                otherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherCell.reasonTxt];
                otherCell.reasonTxt.selectedTextField.layer.borderWidth = 0.0f;
                otherCell.reasonTxt.selectedTextField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 10);
                otherCell.reasonTxt.selectedTextField.textColor = KRobotoFontColorForRightLabel;
                otherCell.reasonTxt.selectedTextField.font = KRobotoFontSize18;
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                otherCell.reasonTxt.dropDownButton.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + 2)) {
                headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
                headingCell.headingLbl.text = [appDel copyTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                cell= headingCell;
                //[headingCell.headingLbl setFont:kCUSFont];
                headingCell.indexPath = indexPath;
                headingCell.headingLbl.textColor = KRobotoFontColorForLeftLabel;
                [headingCell.headingLbl setFont:KRobotoFontForLeftLabel];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                headingCell.controlButton.hidden = self.readonly;
                
            }
            
            else if(indexPath.row > (self.seatManteinanceArray.count + 1) && (indexPath.row <= (self.seatManteinanceArray.count+1+self.actionTakenArray.count + 1))) {
                otherCell = (OtherCell *)[self createCellForTableView:tableView withCellID:otherCellId];
                cell = otherCell;
                otherCell.indexPath = indexPath;
                [otherCell.reasonLbl setFont:kCUSTitleFont];
                otherCell.reasonLbl.text = [appDel copyTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                otherCell.reasonLbl.textColor = KCUSFontColor;
                
                otherCell.reasonTxt.typeOfDropDown = OtherDropDown;
                otherCell.reasonTxt.dataSource = [LTCUSDropdownData copyDataForKey:[appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"] forDocType:@"LAN"];
                otherCell.reasonTxt.delegate = self;
                otherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                otherCell.reasonTxt.selectedTextField.layer.borderWidth = 0.0f;
                otherCell.reasonLbl.text = [appDel copyTextForKey:@"SEAT_MAINTENANCE"] ;
                otherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherCell.reasonTxt];
                otherCell.reasonTxt.selectedTextField.textColor = KRobotoFontColorForRightLabel;
                otherCell.reasonTxt.selectedTextField.font = KRobotoFontSize18;
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 3)) {
                cusSWitchCell = (CUSSwitchCell *)[self createCellForTableView:tableView withCellID:cusSwitchIdentifier];
                cusSWitchCell.leftLabel.text = [appDel copyTextForKey:@"ON_BOARD_MEDICAL_ATTENTION"];
                cusSWitchCell.leftLabel.textColor = KRobotoFontColorForLeftLabel;
                [cusSWitchCell.leftLabel setFont:KRobotoFontForLeftLabel];
                cusSWitchCell.leftLabel.frame = CGRectMake(42, 10, 300, 20);
                cusSWitchCell.rightSwitch.frame = CGRectMake(640, 5, 200, 20);
                
                ((CUSSwitchCell *)cusSWitchCell).rightSwitch.on = medicalAssinstace;
                ((CUSSwitchCell *)cusSWitchCell).rightSwitch.tag = 44;
                
                cusSWitchCell.indexPath = indexPath;
                cell = cusSWitchCell;
                cell.contentView.backgroundColor=[UIColor redColor];
                cell.backgroundColor = [UIColor redColor];
                
                cusSWitchCell.rightSwitch.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4) && !medicalAssinstace) {
                
                textViewCell = (LabelTextViewCell *)[self createCellForTableView:tableView withCellID:labelTextViewCellID];
                textViewCell.indexPath = indexPath;
                cell = textViewCell;
                [textViewCell.reportLabel setFont:KRobotoFontSize20];
                textViewCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                
                textViewCell.textField.tag = MANDATORYTAG;
                textViewCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                textViewCell.textField.delegate = self;
                textViewCell.textField.text = [self getContentInFormDictForView:textViewCell.textField];
                textViewCell.textField.backgroundColor = [UIColor clearColor];
                textViewCell.textField.textColor = KRobotoFontColorForRightLabel;
                textViewCell.textField.font = KRobotoFontSize18;
                //Pravallika Added
                textViewCell.reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT_DETAILS"] stringByAppendingString:@"*"] mandatoryString];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                [textViewCell.textField setUserInteractionEnabled:!self.readonly];
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4)) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCell.indexPath = indexPath;
                cell = lableTextCell;
                lableTextCell.reportLabel.textColor = KCUSFontColor;
                
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"DOCTOR_FULL_NAME"];
                [lableTextCell.reportLabel setFont:KRobotoFontSize18];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontSize18;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"DOCTOR_FULL_NAME"];
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 5)) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCell.indexPath = indexPath;
                cell = lableTextCell;
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"LICENSE_NUMBER"];
                [lableTextCell.reportLabel setFont:kCUSFont];
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"LICENSE_NUMBER"];
                
                [lableTextCell.reportLabel setFont:KRobotoFontSize18];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontSize18;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 6)) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCell.indexPath = indexPath;
                cell = lableTextCell;
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"DIAGNOSE"];
                [lableTextCell.reportLabel setFont:kCUSFont];
                
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"DIAGNOSE"];
                
                [lableTextCell.reportLabel setFont:KRobotoFontSize18];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontSize18;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 7)) {
                lableTextCellMail = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCellMail.indexPath = indexPath;
                cell = lableTextCellMail;
                if(stadoEmal){
                            lableTextCellMail.reportLabel.attributedText = [[[appDel copyTextForKey:@"EMAIL"]stringByAppendingString:@"*"] mandatoryString];
                }else{
                      lableTextCellMail.reportLabel.text = [appDel copyTextForKey:@"EMAIL"]; //stringByAppendingString:@"*"] mandatoryString];
                }
                
                [lableTextCellMail.reportLabel setFont:kCUSFont];
                
                lableTextCellMail.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"EMAIL"];
                lableTextCellMail.textField.keyboardType = UIKeyboardTypeEmailAddress;
                
                [lableTextCellMail.reportLabel setFont:KRobotoFontSize18];
                lableTextCellMail.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCellMail.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCellMail.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCellMail.textField.textAlignment = NSTextAlignmentRight;
                lableTextCellMail.textField.borderStyle = UITextBorderStyleNone;
                lableTextCellMail.textField.layer.borderWidth = 0.0f;
                lableTextCellMail.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCellMail.rightIndicator.hidden = true;
                lableTextCellMail.textField.font = KRobotoFontSize18;
                lableTextCellMail.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCellMail.textField.backgroundColor = [UIColor clearColor];
                
                lableTextCellMail.textField.delegate = self;
                
                lableTextCellMail.textField.text = [self getContentInFormDictForView:lableTextCellMail.textField];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                lableTextCellMail.textField.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 8)) {
                lableTextCell = (LabelTextCell *)[self createCellForTableView:tableView withCellID:labelTextCellID];
                lableTextCell.indexPath = indexPath;
                cell = lableTextCell;
                [lableTextCell.reportLabel setFont:kCUSFont];
                
                lableTextCell.reportLabel.text = [appDel copyTextForKey:@"PHONE_NUMBER"];
                lableTextCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"PHONE_NUMBER"];
                lableTextCell.textField.keyboardType = UIKeyboardTypeNumberPad;
                
                [lableTextCell.reportLabel setFont:KRobotoFontSize18];
                lableTextCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                lableTextCell.reportLabel.frame = CGRectMake(42, 10, 200, 20);
                lableTextCell.textField.frame = CGRectMake(365, 0, 320, 40);
                lableTextCell.textField.textAlignment = NSTextAlignmentRight;
                lableTextCell.textField.borderStyle = UITextBorderStyleNone;
                lableTextCell.textField.layer.borderWidth = 0.0f;
                lableTextCell.textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 20);
                lableTextCell.rightIndicator.hidden = true;
                lableTextCell.textField.font = KRobotoFontSize18;
                lableTextCell.textField.textColor = KRobotoFontColorForRightLabel;
                lableTextCell.textField.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.delegate = self;
                lableTextCell.textField.text = [self getContentInFormDictForView:lableTextCell.textField];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                lableTextCell.textField.enabled = !self.readonly;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 9)) {
                textViewCell = (LabelTextViewCell *)[self createCellForTableView:tableView withCellID:labelTextViewCellID];
                textViewCell.indexPath = indexPath;
                cell = textViewCell;
                [textViewCell.reportLabel setFont:KRobotoFontSize20];
                textViewCell.reportLabel.textColor = KRobotoFontColorForLeftLabel;
                
                textViewCell.textField.tag = MANDATORYTAG;
                textViewCell.textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"REPORT_DETAILS"];
                textViewCell.textField.delegate = self;
                textViewCell.textField.text = [self getContentInFormDictForView:textViewCell.textField];
                textViewCell.textField.backgroundColor = [UIColor clearColor];
                textViewCell.textField.textColor = KRobotoFontColorForRightLabel;
                textViewCell.textField.font = KRobotoFontSize18;
                //Pravallika Added
                textViewCell.reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT_DETAILS"] stringByAppendingString:@"*"] mandatoryString];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.backgroundColor = [UIColor clearColor];
                
                [textViewCell.textField setUserInteractionEnabled:!self.readonly];
            }
            cell.contentView.backgroundColor=[UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
        }
            break;
            
        default:
            break;
    }
    if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleInsert){
        //"add" cell
        [[cell controlButton] setImage:[UIImage imageNamed:@"N__0002_plus.png"]];
    }else if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleDelete){
        //normal cell
        [[cell controlButton] setImage:[UIImage imageNamed:@"N__0001_minus.png"]];
    }
    if(cell ==nil) {
        DLog(@"%@",indexPath);
        
    }
    if([[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] count] == 0){
        [self.ipArray addObject:indexPath];
    }
    
    cell.tag = kCusTag;
    return cell;
}


-(void)switchChanged:(UISwitch *)sw {
    
    switch (sw.tag) {
        case 33: {
            lanPassSwitch = !lanPassSwitch;
            sw.on = lanPassSwitch;
            switchValue = lanPassSwitch;
        }
            break;
        case 44: {
            medicalAssinstace = !medicalAssinstace;
            sw.on = medicalAssinstace;
            switchValue = medicalAssinstace;
            
            if(!medicalAssinstace){
                
                NSString *sectionName = [appDel copyEnglishTextForKey:@"REPORT"];
                
                NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
                
                for (NSString *key in [[groupDict objectForKey:@"singleEvents"] allKeys]) {
                    //                    if(![key isEqualToString:[appDel copyEnglishTextForKey:@"REPORT_DETAILS"]])
                    if(![key isEqualToString:[appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"]] && ![key isEqualToString:[appDel copyEnglishTextForKey:@"REPORT_DETAILS_TAM"]])
                        [[groupDict objectForKey:@"singleEvents"] setObject:@"" forKey:key];
                }
            }
            
        }
            break;
        case 55: {
            passengerMakesClaim = !passengerMakesClaim;
            sw.on = passengerMakesClaim;
            switchValue = passengerMakesClaim;
        }
            break;
        default:
            break;
    }
    [self setContentInFormDictForView:sw];
    
    if (sw.tag == 44) {
        [self.CUSTableView reloadData];
    }
}

- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID {
    OffsetCustomCell *cell;
    if([cellID isEqualToString:@"TwoButtonCell"]) {
        TwoButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
            cell = (TwoButtonCell *)[topLevelObjects objectAtIndex:0];
            cell.segmentControl.tintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            [cell.segmentControl addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventValueChanged];
            
        }
        return cell;
    }
    
    else if([cellID isEqualToString:@"HeaderCell"])
    {
        AddRowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"SeatNum"])
    {
        SeatNum *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SeatNum" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"CUSSwitchCell"])
    {
        CUSSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CUSSwitchCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            cell.rightSwitch.tintColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:.5];
            [cell.rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"SwitchCell"])
    {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            cell.rightSwitch.tintColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:.5];
            [cell.rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"LabelTextCellID"]) {
        
        LabelTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LabelTextCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"LabelTextViewCellID"]) {
        
        LabelTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LabelTextViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.textField.layer.borderWidth = 1.0f;
            cell.textField.layer.borderColor = [[UIColor grayColor] CGColor];
            
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"OtherCellID"]) {
        
        OtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"FullOtherCellID"]) {
        FullOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FullOtherCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"TextTextTextTextOtherID"]) {
        TextTextTextTextOther *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if(nil == cell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextTextTextTextOther" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"LeftOtherCellID"]){
        LeftOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LeftOtherCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.backgroundColor=[UIColor clearColor];
            
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"CutomerDetailCell"]){
        CUSCutomerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CUSCutomerDetailCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [currentTxtField resignFirstResponder];
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSIndexPath *modifiedIndexpath;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        switch (indexPath.section) {
            case 3: {
                sectionName = [appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"];
                if(indexPath.row > 0 && (indexPath.row <= (1+self.associatedLegArray.count)))
                {
                    rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                    if([self.associatedLegArray count]>(indexPath.row-1))
                        [self.associatedLegArray removeObjectAtIndex:indexPath.row - 1];
                    row = (int)(indexPath.row - 1);
                }
            }
                break;
            case 4: {
                sectionName = [appDel copyEnglishTextForKey:@"REPORT"];
                
                if(indexPath.row >1 &&(indexPath.row <= (self.seatManteinanceArray.count+2))) {
                    
                    rowName = [appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"];
                    row = (int)(indexPath.row - 2);
                    if([self.seatManteinanceArray count]>row)
                        [self.seatManteinanceArray removeObjectAtIndex:row];
                }
                else if(indexPath.row > (self.seatManteinanceArray.count+2) && (indexPath.row <= (self.seatManteinanceArray.count+1+self.actionTakenArray.count+2))) {
                    
                    rowName = [appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                    row = (int)(indexPath.row - self.seatManteinanceArray.count -3);
                    if([self.actionTakenArray count]>row)
                        [self.actionTakenArray removeObjectAtIndex:row];
                }
            }
                break;
        }
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        if(cellArr == nil) {
            
            [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
            cellArr = [eventDict objectForKey:rowName];
        }
        [cellArr removeObjectAtIndex:row ];
        
        [[LTSingleton getSharedSingletonInstance].flightCUSDict setObject:groupArr forKey:@"groups"];
        [self.CUSTableView beginUpdates];
        [self.CUSTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.CUSTableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        
        if([LTSingleton getSharedSingletonInstance].sendCusReport){
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        switch (indexPath.section) {
            case 3: {
                
                sectionName = [appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"];
                if(indexPath.row == 0) {
                    
                    rowName = [appDel copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"];
                    if([self.associatedLegArray count] != kNumerOfRelatedPassengers)
                        [self.associatedLegArray addObject:@"1"];
                    else {
                        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_RELATED_PASSENGES_LIMIT"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil, nil];
                        //[alert show];
                        return;
                    }
                }
            }
                break;
            case 4: {
                sectionName = [appDel copyEnglishTextForKey:@"REPORT"];
                
                if(indexPath.row ==1) {
                    
                    rowName = [appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"];
                    [self.seatManteinanceArray addObject:@"1"];
                }
                if(indexPath.row == (self.seatManteinanceArray.count+2)) {
                    
                    rowName = [appDel copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"];
                    [self.actionTakenArray addObject:@"1"];
                }
            }
                break;
        }
        
        NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        
        [cellArr insertObject:cellDict atIndex:0];
        [[LTSingleton getSharedSingletonInstance].flightCUSDict setObject:groupArr forKey:@"groups"];
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        [self.CUSTableView beginUpdates];
        [self.CUSTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.CUSTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        
        if([LTSingleton getSharedSingletonInstance].sendCusReport) {
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        }
        
        NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
        
        if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
            [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCellEditingStyle cellEditingStyle = UITableViewCellEditingStyleNone;
    switch (indexPath.section) {
        case 0:
            cellEditingStyle = UITableViewCellEditingStyleNone;
            break;
        case 1:
            cellEditingStyle = UITableViewCellEditingStyleNone;
            break;
        case 2:
            cellEditingStyle = UITableViewCellEditingStyleNone;
            break;
            
        case 3: {
            if(indexPath.row == 0) {
                cellEditingStyle = UITableViewCellEditingStyleInsert;
            }
            else if(indexPath.row > 0 && indexPath.row <= (0 +self.associatedLegArray.count)) {
                cellEditingStyle = UITableViewCellEditingStyleDelete;
            }
            else {
                cellEditingStyle = UITableViewCellEditingStyleNone;
            }
        }
            break;
        case 4: {
            
            if(indexPath.row == 1) {
                cellEditingStyle = UITableViewCellEditingStyleInsert;
            }
            else if(indexPath.row > 1 &&(indexPath.row <= (self.seatManteinanceArray.count+1))) {
                cellEditingStyle = UITableViewCellEditingStyleDelete;
            }
            else if(indexPath.row == (self.seatManteinanceArray.count+2)) {
                cellEditingStyle = UITableViewCellEditingStyleInsert;
            }
            else if(indexPath.row > (self.seatManteinanceArray.count+1) && (indexPath.row <= (self.seatManteinanceArray.count+1+self.actionTakenArray.count+1))) {
                cellEditingStyle = UITableViewCellEditingStyleDelete;
            }
            else {
                cellEditingStyle = UITableViewCellEditingStyleNone;
            }
        }
            break;
    }
    
    return cellEditingStyle;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 70)];
    headerView.backgroundColor = [UIColor colorWithWhite:.97 alpha:1.0  ];

    NSString *title;
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(0, 25, tableView.frame.size.width, 30);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    CGRect sepFrame = CGRectMake(17, 70, 698, 1);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = KSeparatorLineColor;
    [headerView addSubview:seperatorView];
    
    switch (section) {
        case 0: {
            title = @"";
            DLog(@"%@",title);
            headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
            [headerView setBackgroundColor:[UIColor clearColor]];
            return headerView;
        }
            break;
        case 1: {
            
        }
            break;
        case 2: {
            title = [appDel copyTextForKey:@"PASSENGER_INFORMATION"];
        }
            break;
        case 3: {
            title = [appDel copyTextForKey:@"ADD_PASSENGER_TITLE"];
        }
            break;
        case 4: {
            title = [appDel copyTextForKey:@"REPORT"];
        }
            break;
        default:
            break;
    }
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = KRobotoFontColorForHeader;
    headerLabel.font = KRobotoFontForHeader;
    headerLabel.text = title;
    [headerView addSubview:headerLabel];
    return headerView;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
}

#pragma -mark TableViewDelegates

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == 0){
        return .1;
    }
    else if(section == 1) {
        return .1;
    }

    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float height = 43;
    if(indexPath.section ==3) {
        if((indexPath.row > 0)  && (indexPath.row <= (1+self.associatedLegArray.count))) {
            height = 145;
        }
    }else if(indexPath.section == 0)
        height = .1;
    else if(indexPath.section == 4){
        if(medicalAssinstace)
        {
            if(indexPath.row == (self.seatManteinanceArray.count+self.actionTakenArray.count+9)) {
                height = 147;
            }
        }else{
            if(indexPath.row == (self.seatManteinanceArray.count + self.actionTakenArray.count + 4) && !medicalAssinstace) {
                height = 147;
            }
        }
        
    }else if(indexPath.section == 1 && indexPath.row == 0)
        height = .1;
    else if(indexPath.section == 2 && indexPath.row == 1)
        height = .1;
    else if(indexPath.section == 2 && indexPath.row == 2)
        height = .1;

    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - TextView delegates
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:self.CUSTableView];
    CGPoint contentOffset = self.CUSTableView.contentOffset;
    
    
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    CGSize newContentSize = self.CUSTableView.contentSize;
    newContentSize.height += kKeyboardFrame;
    self.CUSTableView.contentSize = newContentSize;
    
    [self.CUSTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self setContentInFormDictForView:textView];
    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES){
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return;
    }
    id textfieldCellRef;
    if(ISiOS8)
    {
        textfieldCellRef = textView.superview.superview;
        
    }
    else
        textfieldCellRef = textView.superview.superview.superview;
    if ([textfieldCellRef isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell;
        
        if(ISiOS8)
        {
            cell = (UITableViewCell*)textView.superview.superview;
            
        }
        else
            cell = (UITableViewCell*)textView.superview.superview.superview;
        
        
        NSIndexPath *indexPath = [self.CUSTableView indexPathForCell:cell];
        
        [UIView animateWithDuration:kTableViewTransitionSpeed animations:^{
            CGSize newContentSize = self.CUSTableView.contentSize;
            newContentSize.height -= kKeyboardFrame;
            self.CUSTableView.contentSize = newContentSize;
        }];
        
        [self.CUSTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *concatText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    textView.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    DLog(@"%@:%@",textView.accessibilityIdentifier,text);
    
    if (concatText.length > COMMENTVIEWLENGTH) {
        textView.text = [concatText substringToIndex:COMMENTVIEWLENGTH];
        return NO;
    }
    if (range.location == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
    if([text length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendCusReport  && textView.tag == MANDATORYTAG) {
        textView.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    return YES;
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UITableViewCell *cell;
    
    if(ISiOS8) {
        cell = (UITableViewCell*)textField.superview.superview;
    }
    else
        cell = (UITableViewCell*)textField.superview.superview.superview;
    if([NSStringFromClass([[[[[textField superview] superview] subviews] firstObject] class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) {
        
        ((OffsetCustomCell *)cell).comboBoxShown = YES;
        [((OffsetCustomCell *)cell) layoutSubviews];
        //[self.CUSTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:((OffsetCustomCell *)[[[textField superview] superview] superview]).indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    ((OffsetCustomCell *)cell).comboBoxShown = NO;
    
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    currentTxtField = textField;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.CUSTableView];
    CGPoint contentOffset = self.CUSTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.CUSTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self setContentInFormDictForView:textField];
    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES){
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return;
    }
    id textfieldCellRef;
    if(ISiOS8)
    {
        textfieldCellRef = textField.superview.superview;
        
    }
    else
        textfieldCellRef = textField.superview.superview.superview;
    
    if ([textfieldCellRef isKindOfClass:[UITableViewCell class]])
    {
        if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"EMAIL"]]) {
            if([textField.text length]>0 && ![textField.text validateEmail:YES]){
                [LTSingleton getSharedSingletonInstance].emailValid = @"NO";
                NSIndexPath *indexPath = ((OffsetCustomCell *)textfieldCellRef).indexPath;
                [LTSingleton getSharedSingletonInstance].emailIndexpath = indexPath;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_EMAIL_VALIDATION"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil, nil];
                [alert show];
            }else {
                [LTSingleton getSharedSingletonInstance].emailValid = @"YES";
                [LTSingleton getSharedSingletonInstance].emailIndexpath = nil;
                
            }
        }
    }
    UITableViewCell *cell;
    
    if(ISiOS8) {
        cell = (UITableViewCell*)textField.superview.superview;
    }
    else {
        cell = (UITableViewCell*)textField.superview.superview.superview;
    }
    
    NSIndexPath *indexPath = [self.CUSTableView indexPathForCell:cell];
    [self.CUSTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self setContentInFormDictForView:textField];
    
    UITableViewCell *cell;
    
    if(ISiOS8) {
        cell = (UITableViewCell*)textField.superview.superview;
    }
    else {
        cell = (UITableViewCell*)textField.superview.superview.superview;
    }
    
    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES) {
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return  YES;
    }
    
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"EMAIL"]]) {
            if([textField.text length]>0 && ![textField.text validateEmail:YES]) {
                [LTSingleton getSharedSingletonInstance].emailValid = @"NO";
                NSIndexPath *indexPath = ((OffsetCustomCell *)cell).indexPath;
                [LTSingleton getSharedSingletonInstance].emailIndexpath = indexPath;
            } else {
                [LTSingleton getSharedSingletonInstance].emailValid = @"YES";
                [LTSingleton getSharedSingletonInstance].emailIndexpath = nil;
                
            }
        }
    }
    
    NSIndexPath *indexPath = [self.CUSTableView indexPathForCell:cell];
    [self.CUSTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    DLog(@"%@:%@",textField.accessibilityIdentifier,string);
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    NSLog(@"textField.accessibilityIdentifier:%@",textField.accessibilityIdentifier);
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if([string length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendCusReport  && textField.tag == MANDATORYTAG){
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    if(([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"AMOUNT"]]) && ((![textField.text validateMaximumLength:KAmountLength] && string.length > 0)|| ![string validateNumeric])){
        return NO;
    }
    else if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"PHONE_NUMBER"]]) {
        if(concatText.length > KPhoneNumLength) {
            textField.text = [concatText substringToIndex:KPhoneNumLength];
            return NO;
        }
        else if(![concatText validateNumeric]) {
            return NO;
        }
    }
    else if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"ADDRESS"]] && concatText.length > KAddressLength) {
        textField.text = [concatText substringToIndex:KAddressLength];
        return NO;
    }
    else if ([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"EMAIL"]] && concatText.length > KEmailLength) {
        textField.text = [concatText substringToIndex:KEmailLength];
        return NO;
    }
    else if ((![textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"EMAIL"]] &&
              ![textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"AMOUNT"]] &&
              ![textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"PHONE_NUMBER"]]&&
              ![textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"ADDRESS"]]) &&
             concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateMandatoryFields {
    NSArray *mandatoryFieldsSection2single;
    Boolean *mailVacio = true;
    
    if(stadoEmal){
        
        mandatoryFieldsSection2single = @[
                                          [appDel copyEnglishTextForKey:@"LANGUAGE"],
                                          [appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"],
                                          [appDel copyEnglishTextForKey:@"EMAIL"]
                                          ];
    }else{
        mandatoryFieldsSection2single = @[
                                          [appDel copyEnglishTextForKey:@"LANGUAGE"],
                                          [appDel copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"]
                                          ];
    }
    NSArray *mandatoryFieldsSection4single = @[
                                               [appDel copyEnglishTextForKey:@"REASON_FOR_REPORT"],
                                               [appDel copyEnglishTextForKey:@"REPORT_DETAILS"]
                                               ];
    
//
//
    
    NSDictionary *mandatoryFieldsBySection = @{
                                          
                [appDel copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"]
                        : @{@"singleEvents" : @[], @"multiEvents" : @[]},
                                          
                [appDel copyEnglishTextForKey:@"PASSENGER_INFORMATION"]
                        : @{@"singleEvents" : mandatoryFieldsSection2single, @"multiEvents" : @[]},
                                        
                [appDel copyEnglishTextForKey:@"ASSOCIATED_LEG"]
                        : @{@"singleEvents" : @[], @"multiEvents" : @[]},
                                        
                [appDel copyEnglishTextForKey:@"REPORT"]
                        : @{@"singleEvents" : mandatoryFieldsSection4single, @"multiEvents" : @[]}
                                          
                                          };
    
    for(int i = 0; i < groupArr.count; i++) {
        
        NSString *sectionName = ((NSDictionary*)groupArr[i])[@"name"];
        NSDictionary *sectionDict = mandatoryFieldsBySection[sectionName];
        NSDictionary *singleEventsDict = ((NSDictionary*)groupArr[i])[@"singleEvents"];
        NSDictionary *multiEventsDict = ((NSDictionary*)groupArr[i])[@"multiEvents"];
        
        
        for(NSString *rowName in sectionDict[@"singleEvents"]) {

            if(!singleEventsDict[rowName] || [singleEventsDict[rowName] isEqualToString:@""]) {
                return NO;
            }
        }
        
        for(NSString *rowName in sectionDict[@"multiEvents"]) {
            if(!multiEventsDict[rowName] || [multiEventsDict[rowName] isEqualToString:@""]) {
                return NO;
            }
        }
    }

    return YES;
}

@end
