//
//  WBFirstIFEViewController.m
//  LATAM
//
//  Created by Durga Madamanchi on 4/14/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "WBFirstIFEViewController.h"
#import "OffsetCustomCell.h"
#import "ComboTextCamera.h"
#import "ComboText.h"
#import "AddRowCell.h"
#import "ComboNumTextText.h"
#import "OtherComboNumText.h"
#import "ComboComboComboText.h"
#import "ComboNum.h"
#import "NSString+Validation.h"
#import "AppDelegate.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"
#import "LTSingleton.h"
#import "SwitchCell.h"
#import "SimpleComboText.h"
#import "SimpleComboComboComboText.h"
#import "SimpleComboNum.h"
#import "ComboBoxTextNum.h"
#import "LTGetDropDownvalue.h"


@interface WBFirstIFEViewController ()<UITextFieldDelegate,PopoverDelegate> {
    UITextField *currentTxtField;
    NSArray *arr;
    NSMutableArray *groupArr;
    
    AppDelegate *appDel;
    BOOL switchValue;
    NSDictionary *dropDownDict;
    NSDictionary *flightRoasterDraft;
    BOOL isFirst;
}

@end

@implementation WBFirstIFEViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initiallizeData];
        
    }
    return self;
}

//Initialize data esp group array and drop down dictionary
-(void)initiallizeData
{
    switchValue = NO;
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    self.individualFailureArray = [[NSMutableArray alloc] init];
    self.massiveFailuresArray = [[NSMutableArray alloc] init];
    self.stateOfSystemArray = [[NSMutableArray alloc] init];
    self.descriptionofFailureArray = [[NSMutableArray alloc] init];
    self.correctiveActionArray = [[NSMutableArray alloc] init];
    self.finalSystemStatusArray = [[NSMutableArray alloc] init];
    
    DLog(@"dict==%@",flightRoasterDraft);
  
    flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    
    if(flightRoasterDraft != nil)
    {
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        if([groupArr count] > 0){
            switchValue = [[[[[[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] objectAtIndex:1] objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] boolValue];
        }
        
        for(NSDictionary *groupDict in groupArr)
        {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys])
            {
                for(NSDictionary *rowDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:rowName])
                {
                    DLog(@"rowDict %@",rowDict);
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]] )
                        {
                            [self.stateOfSystemArray addObject:@"1"];
                        }
                    }
                    else if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"]])
                    {
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"]])
                        {
                            [self.individualFailureArray addObject:@"1"];
                        }
                    }
                }
            }
        }
    }
    if(nil == groupArr)
        groupArr = [[NSMutableArray alloc]init];
    
    //Create the main form dictionary
    NSMutableDictionary *groupDict;
    
    if ([groupArr count] == 0 ) {
        
        groupArr = [[NSMutableArray alloc]init];
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *cateringDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init] ,nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"], nil]];
        [groupDict setObject:cateringDict forKey:@"multiEvents"];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"] forKey:@"name"];
        [groupArr addObject:groupDict];
        
        if(!switchValue) {
            
            NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"NO",[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],nil];
            groupDict = [[NSMutableDictionary alloc] init];
            
            [groupDict setObject:initialStateDict forKey:@"singleEvents"];
            [groupDict setObject:[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"] forKey:@"name"];
            [groupArr addObject:groupDict];
            
        }
        else {
            
            NSMutableDictionary *cateringDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init] ,[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"],[appDel copyTextForKey:@"DESCRIPTION_OF_FAILURE"],[appDel copyTextForKey:@"CORRECTIVE_ACTION"],[appDel copyTextForKey:@"FINAL_SYSTEM_STATUS"], nil]];
            
            
            NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"",[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],
                                                     nil];
            groupDict = [[NSMutableDictionary alloc] init];
            [groupDict setObject:[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"] forKey:@"name"];
            [groupDict setObject:initialStateDict forKey:@"singleEvents"];
            
            [groupDict setObject:cateringDict forKey:@"multiEvents"];
            
            [groupArr addObject:groupDict];
        }
        
    }else {
        
        NSArray *array = [groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]]];
        if([array count]>0)
            groupDict = [array objectAtIndex:0];
        
        if(switchValue) {
            
        }else {
            
            NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"NO",[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],nil];
            
            [groupDict setObject:initialStateDict forKey:@"singleEvents"];
        }
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
    NSDictionary *flightRoaster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    NSString *type = [flightRoaster objectForKey:@"flightReportType"];
    
    NSString *report = [[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"name"];
    
    NSString *section = [[[[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"name"];
    
    dropDownDict = [LTGetDropDownvalue getDictForReportType:type FlightReport:report Section:section];
    
    isFirst = NO;
}

-(NSArray *)getDropDownDataForGroup:(NSString *)group event:(NSString *)event content:(NSString *)content
{
    return [[[dropDownDict objectForKey:[appDel copyEnglishTextForKey:group]]objectForKey:[appDel copyEnglishTextForKey:event]] objectForKey:[appDel copyEnglishTextForKey:content]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirst = YES;
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.tableView = self.IFEtableView;
    self.ipArray = [[NSMutableArray alloc] init];
    
    
    CGRect frame = __headingLabel.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    __headingLabel.frame= frame;
    [__headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self._headingLabel.text = [appDel copyTextForKey:@"IFE"];

    _header_Line.frame = CGRectMake(15, 37,560,8);
    [self.tableView setEditing:YES animated:YES];
    
    [self initializeIndexPathArray];
    _IFEtableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

    // Do any additional setup after loading the view from its nib.
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}
#pragma mark - Form Data Storage Methods

//Get the form elements from the dictionary
-(NSString *)getContentInFormDictForView:(id)view
{
    NSString *value;
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    int row=0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    if (indexPath.section == 0)
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"];
        if(indexPath.row <= self.individualFailureArray.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
            row = indexPath.row;
        }else {
            rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
            row = indexPath.row;
        }
        
    }
    else
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
        
        if(indexPath.row <= self.massiveFailuresArray.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"];
            row = indexPath.row+1;
        }
        else  if(indexPath.row <= self.massiveFailuresArray.count+self.stateOfSystemArray.count+1 )
        {
            rowName = [appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"];
            row = indexPath.row-(self.massiveFailuresArray.count+1);
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+3) {
            rowName = [appDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"];
            row = indexPath.row - (self.massiveFailuresArray.count+self.stateOfSystemArray.count+2);
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+5){
            rowName = [appDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"];
            row = indexPath.row - (self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+4);
        }else if(indexPath.row ==  self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+7){
            rowName = [appDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"];
            row = indexPath.row -(self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6);
        }else {
            rowName = [appDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"];
            row = indexPath.row -(self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6);
        }
    }
    @try {
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict ;
        
        if(indexPath.section ==1)
            if(indexPath.row !=1 ) {
                NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
                NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
                eventDict = [cellArr objectAtIndex:row - 1];
            }else {
                eventDict = [groupDict objectForKey:@"singleEvents"];
                
            }else {
                NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
                NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
                eventDict = [cellArr objectAtIndex:row - 1];
            }
        
        if([view isKindOfClass:[TestView class]])
        {
            NSString *testViewValue = [eventDict objectForKey:((TestView *)view).key];
            if(testViewValue)
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
        }        else if([view isKindOfClass:[UITextField class]])
            value = [eventDict objectForKey:((UITextField *)view).accessibilityIdentifier];
        else
        {
            UILabel *label = ((UILabel *)view);
            NSString *key = label.accessibilityIdentifier;
            value = [eventDict objectForKey:key];
        }
        
        return  value;
    }
    @catch (NSException *exception) {
        
    }
    
    return value;
}

//Store the form elements in a dictionary
-(void)setContentInFormDictForView:(id)view
{
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    if(indexPath == nil)
        return;
    
    int row=0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    if (indexPath.section == 0)
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"];
        if(indexPath.row <= self.individualFailureArray.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
            row = indexPath.row;
        }else {
            rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
            row = indexPath.row;
        }
        
    }
    else
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
        
        if(indexPath.row <= self.massiveFailuresArray.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"];
            row = indexPath.row+1;
        }
        else  if(indexPath.row <= self.massiveFailuresArray.count+self.stateOfSystemArray.count+1 )
        {
            rowName = [appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"];
            row = indexPath.row-(self.massiveFailuresArray.count+1);
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+3) {
            rowName = [appDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"];
            row = indexPath.row - (self.massiveFailuresArray.count+self.stateOfSystemArray.count+2);
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil|| [cellArr count]==0)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
                [cellArr addObject:cellDict];
                [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
                
            }
            
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+5){
            rowName = [appDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"];
            row = indexPath.row - (self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+4);
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil|| [cellArr count]==0)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
                [cellArr addObject:cellDict];
                [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
                
            }
            
        }else if(indexPath.row ==  self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+7){
            rowName = [appDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"];
            row = indexPath.row -(self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6);
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil|| [cellArr count]==0)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
                [cellArr addObject:cellDict];
                [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
                
            }
            
        }else {
            rowName = [appDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"];
            row = indexPath.row -(self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6);
            
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil|| [cellArr count]==0)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
                [cellArr addObject:cellDict];
                [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
                
            }
            
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    NSMutableDictionary *eventDict ;
    if(indexPath.section ==1)
        
        if(indexPath.row !=0 ) {
            NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
            eventDict = [cellArr objectAtIndex:row - 1];
        }else {
            eventDict = [groupDict objectForKey:@"singleEvents"];
            
        }else {
            NSMutableDictionary *eventDict1 = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict1 objectForKey:rowName];
            eventDict = [cellArr objectAtIndex:row - 1];
        }
    if([view isKindOfClass:[TestView class]])
    {
        if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]])
        {
            [eventDict setObject:((TestView *)view).selectedValue forKey:((TestView *)view).key];
        }
        else
            [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
    }
    else if([view isKindOfClass:[UISwitch class]]){
        [eventDict setObject:((switchValue)? @"YES": @"NO")  forKey:rowName];
    }
    else if([view isKindOfClass:[UITextField class]])
        [eventDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    else{
        if(ISiOS8)
        {
            NSString *key = [((SimpleComboNum *)[[view superview] superview]) valueLabel].accessibilityIdentifier;
            [eventDict setObject:[((SimpleComboNum *)[[view superview] superview]) valueLabel].text forKey:key];
            
        }
        else
        {
            NSString *key = [((SimpleComboNum *)[[[view superview] superview] superview]) valueLabel].accessibilityIdentifier;
            [eventDict setObject:[((SimpleComboNum *)[[[view superview] superview] superview]) valueLabel].text forKey:key];
        }
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}

#pragma mark - Popover Delegate Methods
-(void)valueSelectedInPopover:(TestView *)testView
{
    [self setContentInFormDictForView:testView];
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    [self.IFEtableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    [self updateReportDictionary];
    
    
}
-(void)valuesSelectedInPopOver:(UITextField *)textFields {
    [self setContentInFormDictForView:textFields];
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[textFields superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[textFields superview] superview] superview]).indexPath;
    
    [self.IFEtableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self updateReportDictionary];
    
}

#pragma mark - Keyboard Navigation Methods

- (UIToolbar *)keyboardToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UISegmentedControl *segControl;
    segControl = [[UISegmentedControl alloc] initWithItems:@[@"Previous", @"Next"]];
    segControl.momentary = YES;
    [segControl addTarget:self action:@selector(navigateField:) forControlEvents:(UIControlEventValueChanged)];
    
    UIBarButtonItem *segmentBarBtn = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    
    NSArray *itemsArray = @[segmentBarBtn];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

#pragma mark - Navigate Field for Segment Control

-(void)navigateField:(UISegmentedControl *)segControl
{
    OffsetCustomCell *cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
    id view;
    if(segControl.selectedSegmentIndex == 0){
        view = [cell viewWithTag:currentTxtField.tag - 1];
        
    }
    else{
        view = [cell viewWithTag:currentTxtField.tag + 1];
    }
    if(view == nil){
        
        if(segControl.selectedSegmentIndex == 0){
            for(int section = cell.indexPath.section ;section>=0;section--){
                BOOL isPrevFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.IFEtableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.IFEtableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]){
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]){
                        tempTag = MANDATORYTAG;
                    }
                    if([cell viewWithTag:tempTag]){
                        if([[[cell viewWithTag:tempTag] superview] isKindOfClass:[TestView class]]){
                            
                        }
                        else{
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
        else{
            for(int section = cell.indexPath.section ;section<[self.IFEtableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.IFEtableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.IFEtableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]){
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]){
                        tempTag = MANDATORYTAG;
                    }
                    
                    if([cell viewWithTag:tempTag]){
                        if([[[cell viewWithTag:tempTag] superview] isKindOfClass:[TestView class]]){
                            
                        }
                        else{
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
    else if(view!=nil && [view isKindOfClass:[UITextField class]])
    {
        [view becomeFirstResponder];
    }
    
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    if(section == 0)
    {
        rowCount = self.individualFailureArray.count+1;
    }
    else
    {
        if(switchValue) {
            
            rowCount = self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+self.finalSystemStatusArray.count+8;;
            
        }else {
            return 1;
            
        }
        
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    static NSString *headingCellCellID = @"HeaderCell";
    static NSString *comboTextId = @"ComboText";
    static NSString *comboTextId1 = @"ComboTextID";
    
    static NSString *comboNumId = @"ComboNum";
    static NSString *switchIdentifier = @"SwitchCell";
    static NSString *comboComboComboTextId = @"ComboComboComboText";
    static NSString *comboNumTextId = @"ComboBoxTextNumId";
    
    OffsetCustomCell *cell = nil;
    ComboText *comboTextCell = nil;
    AddRowCell *headingCell = nil;
    SimpleComboNum *comboNum = nil;
    SimpleComboComboComboText *comboComboComboText = nil;
    SwitchCell *switchCell;
    SimpleComboText *simplecomboTextCell = nil;
    ComboBoxTextNum *comboTextNum;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
        }
        else
        {
            comboTextNum = (ComboBoxTextNum *)[self createCellForTableView:tableView withCellID:comboNumTextId];
        }
    }
    else {
        
        if(indexPath.row == 0)
        {
            switchCell = (SwitchCell *)[self createCellForTableView:tableView withCellID:switchIdentifier];
            switchCell.indexPath = indexPath;
            switchCell.leftLabel.text = [appDel copyTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"];
            
            ((SwitchCell *)switchCell).rightSwitch.on = switchValue;
            
            cell.indexPath = indexPath;
        }else if(indexPath.row == self.massiveFailuresArray.count+1) {
            headingCell = (AddRowCell*)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"];
            
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+2) {
            headingCell = (AddRowCell*)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"DESCRIPTION_OF_FAILURE"];
            
        }else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+3) {
            
            comboComboComboText = (SimpleComboComboComboText *)[self createCellForTableView:tableView withCellID:comboComboComboTextId];
        }
        else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+4){
            headingCell = (AddRowCell*)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"CORRECTIVE_ACTION"];
            
        }else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+5){
            comboNum = (SimpleComboNum *)[self createCellForTableView:tableView withCellID:comboNumId];
            
        }
        else if(indexPath.row ==  self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6){
            headingCell = (AddRowCell*)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"FINAL_SYSTEM_STATUS"];
            
        }else if(indexPath.row ==  self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+7){
            simplecomboTextCell = (SimpleComboText *)[self createCellForTableView:tableView withCellID:comboTextId];
            
        }
        else if(indexPath.row >1 && indexPath.row <= self.stateOfSystemArray.count+1 ) {
            comboTextCell = (ComboText *)[self createCellForTableView:tableView withCellID:comboTextId1];
            
        }
        
    }
    // Configure the cell...
    if(headingCell)
        cell = headingCell;
    else if(switchCell) {
        cell = switchCell;
    }
    else if(comboTextNum)
    {
        cell = comboTextNum;
        comboTextNum.delegate = self;
        comboTextNum.indexPath = indexPath;
        
        comboTextNum.comboView.delegate = self;
        
        comboTextNum.comboView.dataSource = [self getDropDownDataForGroup:@"INDIVIDUAL_FAILURES" event:@"INDIVIDUAL_FAILURE _IFE" content:@"REASON"];
        comboTextNum.comboView.typeOfDropDown = NormalDropDown;
        
        comboTextNum.comboView.key = [appDel copyEnglishTextForKey:@"SELECT_REASON"];
        comboTextNum.comboView.selectedTextField.tag = MANDATORYTAG;
        
        comboTextNum.comboView.selectedTextField.text = [self getContentInFormDictForView:comboTextNum.comboView];
        
        comboTextNum.comboViewlabel.attributedText = [[[appDel copyTextForKey:@"SELECT_REASON"] stringByAppendingString:@"*"] mandatoryString];
        
        comboTextNum.seatLetterTxt.delegate = self;
        comboTextNum.seatLetterTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_LETTER"];
        [comboTextNum.seatLetterTxt setText:[self getContentInFormDictForView:comboTextNum.seatLetterTxt]];
        [comboTextNum.seatLetterTxt setFont:[UIFont fontWithName:KFontName size:14.0]];

        comboTextNum.seatRowTxt.delegate = self;
        
        comboTextNum.seatRowTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_ROW"];
        [comboTextNum.seatRowTxt setText:[self getContentInFormDictForView:comboTextNum.seatRowTxt]];
        [comboTextNum.seatRowTxt setFont:[UIFont fontWithName:KFontName size:14.0]];

        comboTextNum.seatLetterLbl.attributedText = [[[appDel copyTextForKey:@"SEAT_LETTER"] stringByAppendingString:@"*"] mandatoryString];
        comboTextNum.seatRowLbl.attributedText = [[[appDel copyTextForKey:@"SEAT_ROW"] stringByAppendingString:@"*"] mandatoryString];;
        comboTextNum.seatLetterTxt.tag = MANDATORYTAG;
        comboTextNum.seatRowTxt.tag = MANDATORYTAG;
    }
    else if(simplecomboTextCell)
    {
        cell = simplecomboTextCell;
        simplecomboTextCell.indexPath = indexPath;
        simplecomboTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        
        simplecomboTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        
        simplecomboTextCell.alertComboView.typeOfDropDown = AlertDropDown;
        simplecomboTextCell.alertComboView.selectedTextField.hidden = YES;
        simplecomboTextCell.alertComboView.delegate = self;
        simplecomboTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:simplecomboTextCell.alertComboView];
        simplecomboTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:simplecomboTextCell.alertComboView];
        
        simplecomboTextCell.reportTxt.delegate = self;
        simplecomboTextCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"FINAL_SYSTEM_STATUS" content:@"SELECT_STATE"];
        simplecomboTextCell.reportTxt.typeOfDropDown = OtherDropDown;
        simplecomboTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"SELECT_STATE"];
        simplecomboTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:simplecomboTextCell.reportTxt];
        simplecomboTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"SELECT_STATE"] stringByAppendingString:@"*"] mandatoryString];
        
        simplecomboTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        if([self getContentInFormDictForView:simplecomboTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:simplecomboTextCell.alertComboView] isEqualToString:@""])
        {
            [simplecomboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [simplecomboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
    }
    else if(comboComboComboText)
    {
        cell = comboComboComboText;
        comboComboComboText.indexPath = indexPath;
        comboComboComboText.serviceLbl.attributedText = [[[appDel copyTextForKey:@"TIME_OF_FLIGHT"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboText.optionLbl.attributedText = [[[appDel copyTextForKey:@"FAULT_TYPE"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboText.reportLbl.attributedText = [[[appDel copyTextForKey:@"DURATION_OF_FAILURE"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboText.amountLbl.attributedText = [[[appDel copyTextForKey:@"SEATING"] stringByAppendingString:@"*"] mandatoryString];
        
        
        comboComboComboText.serviceTxt.delegate = self;
        comboComboComboText.serviceTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"DESCRIPTION_OF_FAILURE" content:@"TIME_OF_FLIGHT"];
        comboComboComboText.serviceTxt.typeOfDropDown = NormalDropDown;
        comboComboComboText.serviceTxt.key = [appDel copyEnglishTextForKey:@"TIME_OF_FLIGHT"];
        comboComboComboText.serviceTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboText.serviceTxt];
        comboComboComboText.serviceTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        comboComboComboText.optionTxt.delegate = self;
        comboComboComboText.optionTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"DESCRIPTION_OF_FAILURE" content:@"FAULT_TYPE"];
        comboComboComboText.optionTxt.typeOfDropDown = OtherDropDown;
        comboComboComboText.optionTxt.key = [appDel copyEnglishTextForKey:@"FAULT_TYPE"];
        comboComboComboText.optionTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboText.optionTxt];
        comboComboComboText.optionTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        comboComboComboText.reportTxt.delegate = self;
        comboComboComboText.reportTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"DESCRIPTION_OF_FAILURE" content:@"DURATION_OF_FAILURE"];
        comboComboComboText.reportTxt.typeOfDropDown = NormalDropDown;
        comboComboComboText.reportTxt.key = [appDel copyEnglishTextForKey:@"DURATION_OF_FAILURE"];
        comboComboComboText.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboText.reportTxt];
        comboComboComboText.reportTxt.selectedTextField.tag = MANDATORYTAG;
        
        comboComboComboText.amountTxt.delegate = self;
        comboComboComboText.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEATING"];
        [comboComboComboText.amountTxt setText:[self getContentInFormDictForView:comboComboComboText.amountTxt]];
        comboComboComboText.amountTxt.tag = MANDATORYTAG;
        comboComboComboText.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
        
    }
    else if(comboNum)
    {
        cell = comboNum;
        
        comboNum.indexPath = indexPath;
        
        comboNum.reportTxt.delegate = self;
        comboNum.reportTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"CORRECTIVE_ACTION" content:@"AREA_RESET"];
        comboNum.reportTxt.typeOfDropDown = NormalDropDown;
        comboNum.reportTxt.key = [appDel copyEnglishTextForKey:@"AREA_RESET"];
        comboNum.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboNum.reportTxt];
        comboNum.reportLbl.attributedText = [[[appDel copyTextForKey:@"AREA_RESET"] stringByAppendingString:@"*"] mandatoryString];
        comboNum.reportTxt.selectedTextField.tag = MANDATORYTAG;
        
        comboNum.valueLabel.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"NUMBER_OF_RESETS"];
        comboNum.amountLbl.text = [appDel copyTextForKey:@"NUMBER_OF_RESETS"];
        comboNum.amountLbl.tag = MANDATORYTAG;
        
        NSString *stringValue = [self getContentInFormDictForView:comboNum.valueLabel];
        if(nil == stringValue || [stringValue length] == 0){
            comboNum.valueLabel.text = @"0";
        }
        else  {
            comboNum.valueLabel.text = stringValue;
        }
        [comboNum.minusButton addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventTouchUpInside];
        [comboNum.plusButton addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    else if(comboTextCell)
    {
        //dfg
        cell = comboTextCell;
        comboTextCell.indexPath = indexPath;
        comboTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        comboTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        
        comboTextCell.alertComboView.typeOfDropDown = AlertDropDown;
        comboTextCell.alertComboView.selectedTextField.hidden = YES;
        comboTextCell.alertComboView.delegate = self;
        comboTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:comboTextCell.alertComboView];
        comboTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:comboTextCell.alertComboView];
        
        comboTextCell.reportTxt.delegate = self;
        comboTextCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"MASSIVE_FAILURES" event:@"INITIAL_STATE_OF_THE_SYSTEM" content:@"SELECT_STATE"];
        comboTextCell.reportTxt.typeOfDropDown = OtherDropDown;
        comboTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"SELECT_STATE"];
        comboTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboTextCell.reportTxt];
        comboTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"SELECT_STATE"] stringByAppendingString:@"*"] mandatoryString];
        comboTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        if([self getContentInFormDictForView:comboTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:comboTextCell.alertComboView] isEqualToString:@""])
        {
            [comboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [comboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
    }
    if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleInsert){
        //"add" cell
        [[cell controlButton] setImage:[UIImage imageNamed:@"add"]];
    }else if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleDelete){
        //normal cell
        
        [[cell controlButton] setImage:[UIImage imageNamed:@"remove"]];
    }
    if([[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] count] == 0){
        [self.ipArray addObject:indexPath];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];;

    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([LTSingleton getSharedSingletonInstance].sendReport && !([NSStringFromClass([cell class]) isEqualToString:@"AddRowCell"])){
        self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] validateCell:(OffsetCustomCell *)cell withLeastIndexPath:self.leastIndexPath];
        DLog(@"ID:%@",self.leastIndexPath);
    }
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

//Create different cells based on the cell identifier
- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID
{
    if([cellID isEqualToString:@"HeaderCell"])
    {
        AddRowCell *cell;
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else if ([cellID isEqualToString:@"ComboNum"]){
        SimpleComboNum *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SimpleComboNum" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        return cell;
    }else if ([cellID isEqualToString:@"ComboComboComboText"]){
        SimpleComboComboComboText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SimpleComboComboComboText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        cell.amountTxt.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
        cell.amountTxt.layer.borderWidth = 1.0f;
        
        return cell;
    }
    else if ([cellID isEqualToString:@"ComboBoxTextNumId"]){
        ComboBoxTextNum *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboBoxTextNum" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        
        return cell;
    }
    
    else if([cellID isEqualToString:@"ComboText"]) {
        
        SimpleComboText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SimpleComboText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        return cell;
        
    }else if([cellID isEqualToString:@"OtherComboNumText"]){
        OtherComboNumText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherComboNumText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
        
    }else if([cellID isEqualToString:@"SwitchCell"]){
        
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            [cell.rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    
    else if ([cellID isEqualToString:@"ComboNum"]){
        ComboNum *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboNum" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }else if ([cellID isEqualToString:@"ComboComboComboText"]){
        ComboComboComboText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboComboComboText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"ComboTextID"]) {
        
        ComboText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
        
    }else if([cellID isEqualToString:@"OtherComboNumText"]){
        OtherComboNumText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherComboNumText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
        
    }else if([cellID isEqualToString:@"SwitchCell"]){
        
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            [cell.rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    return nil;
}
-(void)switchChanged:(UISwitch *)sw
{
    switchValue = !switchValue;
    [self setContentInFormDictForView:sw];
    
    [self resetAllDataInMassiveFailure:switchValue ];
    
    
    // [self.tableView reloadData];
    [self initializeIndexPathArray];
    
}
-(void)resetAllDataInMassiveFailure :(BOOL)isSwitchOn {
    
    if(switchValue) {
        
        NSString *sectionName = [appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        [groupDict removeAllObjects];
        
        NSMutableDictionary *cateringDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init] ,[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"],[appDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"],[appDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"],[appDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"], nil]];
        
        NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"YES",[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],
                                                 nil];
        
        [groupDict setObject:[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"] forKey:@"name"];
        [groupDict setObject:initialStateDict forKey:@"singleEvents"];
        
        [groupDict setObject:cateringDict forKey:@"multiEvents"];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    }
    else{
        
        [self.stateOfSystemArray removeAllObjects];
        [self.descriptionofFailureArray removeAllObjects];
        [self.correctiveActionArray removeAllObjects];
        [self.finalSystemStatusArray removeAllObjects];
        
        NSString *sectionName = [appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        [groupDict removeAllObjects];
        
        NSMutableDictionary *initialStateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"NO",[appDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],nil];
        
        [groupDict setObject:initialStateDict forKey:@"singleEvents"];
        
        [groupDict setObject:sectionName forKey:@"name"];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    }
    
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 30)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    NSString *sectionTitle;
    if(section == 0)
    {
        sectionTitle = [appDel copyTextForKey:@"INDIVIDUAL_FAILURES"];
    }
    else if (section == 1)
    {
        sectionTitle = [appDel copyTextForKey:@"MASSIVE_FAILURES"];
    }
    
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 0, kSectionalHeaderWidth, 40);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = sectionTitle;
    headerLabel.textColor = kSectionalHeaderTextColour;
    headerLabel.font = kSectionalHeaderTextSize;
    [headerView addSubview:headerLabel];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kSectionalFooterImage]];
    imageView.frame = CGRectMake(41, 0, kSectionalFooterWidth , 3);
    [imageView setBackgroundColor:[UIColor clearColor]];;
    [footerView addSubview:imageView];
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if(indexPath.section == 1)
    {
        if(indexPath.row ==0 ||
           indexPath.row == self.massiveFailuresArray.count+1||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 2||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count + 4||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count + 6||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count + 7
           )
        {
            height = 44.0;
        }else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 3){
            height = 175;
        }else if(indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count + 5){
//            return 100;
            return 100;// Added Pavan
        }
        else
        {
            height = 44.0;
        }
    }
    else
    {
        if(indexPath.row == 0 || indexPath.row == self.individualFailureArray.count + 1 )
        {
            height = 44;
            
        }
        else
        {
            height = 44.0;
        }
    }
    
    //height = 44; //Added Pavan
    return height;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [currentTxtField resignFirstResponder];
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSIndexPath *modifiedIndexpath;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0)
        {
            sectionName =[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"];
            
            if(indexPath.row <= self.individualFailureArray.count )
            {
                row = indexPath.row;
                
                rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
                [self.individualFailureArray removeObjectAtIndex:self.individualFailureArray.count  - indexPath.row];
            }
        }
        else
        {
            sectionName =[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
            
            if(indexPath.row <= self.massiveFailuresArray.count+self.stateOfSystemArray.count+1 ){
                
                row = indexPath.row - (self.massiveFailuresArray.count+1);
                
                rowName = [appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"];
                
                [self.stateOfSystemArray removeObjectAtIndex:self.massiveFailuresArray.count+self.stateOfSystemArray.count+1 -indexPath.row];
            }
        }
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        if([[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"]){
            
            NSString *imageName = [[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"];
            
            [self deleteImage:imageName];
        }
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        if(cellArr == nil)
        {
            [eventDict setObject:[NSMutableArray array] forKey:rowName];
            cellArr = [eventDict objectForKey:rowName];
        }
        [cellArr removeObjectAtIndex:row - 1];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        if (indexPath.section == 1)
        {
            sectionName =[appDel copyEnglishTextForKey:@"MASSIVE_FAILURES"];
            
            if(indexPath.row == 1 )
            {
                [self.stateOfSystemArray addObject:@"1"];
                
                rowName = [appDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"];
                
            }
        }
        else if(indexPath.section == 0)
        {
            sectionName =[appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"];
            
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"];
                
                [self.individualFailureArray addObject:@"1"];
                
            }
        }
        @try {
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            
            [cellArr insertObject:cellDict atIndex:0];
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
            
            NSArray *t;
            
            if(ISiOS8) {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationTop];
                
                t = [tableView visibleCells];
                
                [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
                
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:modifiedIndexpath.section] withRowAnimation:UITableViewRowAnimationNone];
            }else {
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
                
                t = [tableView visibleCells];
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
                
                [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
                
            }
            
            NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
            
            
            if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
                [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
            }
            
        }
        @catch (NSException *exception) {
            [self.tableView reloadData];
            DLog(@"Exception :%@",exception.description);
        }
        
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle cellEditingStyle;
    if (indexPath.section == 1)
    {
        if(indexPath.row == 1) {
            cellEditingStyle = UITableViewCellEditingStyleInsert;
        }
        else if(indexPath.row ==0 ||
                (indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 3)||
                indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 2||
                indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count + 4||
                indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count + 5){
            cellEditingStyle = UITableViewCellEditingStyleNone;
        }else if(indexPath.row >1 && indexPath.row <= self.stateOfSystemArray.count+1 ) {
            cellEditingStyle = UITableViewCellEditingStyleDelete;
        }
        else {
            cellEditingStyle = UITableViewCellEditingStyleNone;
        }
    }
    else
    {
        if(indexPath.row ==0){
            cellEditingStyle = UITableViewCellEditingStyleInsert;
        }
        else {
            cellEditingStyle = UITableViewCellEditingStyleDelete;
        }
    }
    return cellEditingStyle;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1) {
        if(indexPath.row == 1) {
            return YES;
        }
        if(indexPath.row == 0 ||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 3 ||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count + 2||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count + 4||
           indexPath.row == self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count + 5||
           self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+6||
           self.massiveFailuresArray.count+self.stateOfSystemArray.count+self.descriptionofFailureArray.count+self.correctiveActionArray.count+7) {
            return NO;
        } else {
            YES;
        }
    }
    return YES;
}
#pragma mark - TextField Methods
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    if([string length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendReport && textField.tag == MANDATORYTAG){
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"AMOUNT"]]) {
        
        if(concatText.length > KAmountLength) {
            textField.text = [concatText substringToIndex:KAmountLength];
            return NO;
        }
        else if(![concatText validateNumeric]) {
            return NO;
        }
    }
    else if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    currentTxtField = textField;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.tableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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
        UITableViewCell *cell;
        
        if(ISiOS8)
        {
            cell = (UITableViewCell*)textField.superview.superview;
            
        }
        else
            cell = (UITableViewCell*)textField.superview.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

