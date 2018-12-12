
//
//  GeneralInfoViewController.m
//  LATAM
//
//  Created by Vishnu on 10/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "GeneralInfoViewController.h"
#import "OffsetCustomCell.h"
#import "TextFieldNameCell.h"
#import "SwitchCell.h"
#import "DropDownCell.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"


@interface GeneralInfoViewController ()
{
    NSDictionary *sourceDictionary;
    NSArray *sectionArray;
    UITextField *currentTxtField;
    AppDelegate *appDel;
    NSMutableArray *groupArr;
    CGPoint offset;
    
}

@end

@implementation GeneralInfoViewController
@synthesize materialDropdown,baseCrewDropdown,switchValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeData];

    }
    return self;
}


#pragma mark - Data Initialization

-(void)initializeData {
    
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switchValue = YES;
    BOOL dataFound = NO;
    
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    
    DLog(@"dict==%@",flightRoasterDraft);
    
    groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    
    if([groupArr count] > 0) {
        switchValue = [[[[[[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"]] boolValue];
        
        NSString *temp = (switchValue) ? @"YES" : @"NO";
        
        NSDictionary *legdict = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
        
        NSString *key = [NSString stringWithFormat:@"%@-%@",[legdict objectForKey:@"origin"],[legdict objectForKey:@"destination"] ];
        [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:temp forKey:key];
        [LTSingleton getSharedSingletonInstance].enableCells=switchValue;
        
        [[LTSingleton getSharedSingletonInstance].enableCellsDictionary setObject:temp forKey:[NSNumber numberWithInt:kCurrentLegNumber]];
        
        for(int i = 1; i < [groupArr count]; i++) {
            NSMutableDictionary *groupDict = [groupArr objectAtIndex:i];
            for(NSString *key in [[groupDict objectForKey:@"singleEvents"] allKeys]) {
                if(!([[[groupDict objectForKey:@"singleEvents"] objectForKey:key] isEqualToString:@""])) {
                    dataFound = YES;
                    break;
                }
            }
            if(dataFound) break;
        }
    }
    
    if ([groupArr count] == 0) {
        
        groupArr = [[NSMutableArray alloc]init];
        [[LTSingleton getSharedSingletonInstance].enableCellsDictionary setObject:@"YES" forKey:[NSNumber numberWithInt:[LTSingleton getSharedSingletonInstance].legNumber]];
        
        NSMutableDictionary *groupDict;
        NSMutableDictionary *tramoDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"YES"], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"], nil]];
        
        NSMutableDictionary *jefeDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_NAME"],[appDel copyEnglishTextForKey:@"GENERAL_SURNAME"],[appDel copyEnglishTextForKey:@"GENERAL_BP"], nil]];
        
        NSMutableDictionary *captainDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_NAME"],[appDel copyEnglishTextForKey:@"GENERAL_SURNAME"], nil]];
        
        NSMutableDictionary *flightDataDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"],[appDel copyEnglishTextForKey:@"GENERAL_ENROLLMENT"],[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"] forKey:@"name"];
        [groupDict setObject:tramoDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"] forKey:@"name"];
        [groupDict setObject:jefeDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_CAPITAN"] forKey:@"name"];
        [groupDict setObject:captainDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"] forKey:@"name"];
        [groupDict setObject:flightDataDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
    if(!dataFound) {
        [LTGetLightData getPrepopulatedDataForGeneral:[[LTSingleton getSharedSingletonInstance].flightRoasterDict mutableCopy]];
        if (self.tryCount == 0) {
            self.tryCount++;
            [self initializeData];
        }
    }
    
    if([LTSingleton getSharedSingletonInstance].generalDictionary) {
        [[[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] replaceObjectAtIndex:1 withObject:[[LTSingleton getSharedSingletonInstance].generalDictionary mutableCopy]];
    }
    
    [self configurePopovers];
}

- (void)viewDidLoad {
    
    self.tryCount = 0;
    [super viewDidLoad];
    self.tableView = _generalTableView;
    self.ipArray = [[NSMutableArray alloc] init];
    
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    
    _headingLabel.textColor=kFontColor;
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headingLabel.text = [appDel copyTextForKey:@"General Information"];

    CGRect frame = _headingLabel.frame;
    frame.origin.y = kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x = kxposition_NB_LAN_General;//pass the cordinate which you want

    _headingLabel.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    
    sectionArray = [[NSArray alloc] initWithObjects:[appDel copyTextForKey:@"GENERAL_TRAMO_EJECUTADO"],[appDel copyTextForKey:@"GENERAL_JEFE_DE_SERVICIO"],[appDel copyTextForKey:@"GENERAL_CAPITAN"],[appDel copyTextForKey:@"GENERAL_FLIGHT_DATA"], nil];
    sourceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_NAME"],[appDel copyTextForKey:@"GENERAL_SURNAME"],[appDel copyTextForKey:@"GENERAL_BP"], nil],[NSNumber numberWithInt:1],[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_NAME"],[appDel copyTextForKey:@"GENERAL_SURNAME"], nil],[NSNumber numberWithInt:2],[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_MATERIAL"],[appDel copyTextForKey:@"GENERAL_ENROLLMENT"],[appDel copyTextForKey:@"GENERAL_CREW_BASE"], nil],[NSNumber numberWithInt:3], nil];
    self.headingLabel.text = [appDel copyTextForKey:@"General Information"];
    [_generalTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self initializeIndexPathArray];
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Popover Configuring

-(void)configurePopovers {
    
    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    NSString *report = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
    
    NSString *section = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
    
    NSString *group = [appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"];
    
    NSMutableDictionary *retDict = [LTGetDropDownvalue getDictForReportType:flightType FlightReport:report Section:section];
    
    materialDropdown = [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]];
    baseCrewDropdown=  [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]];
}

#pragma mark - Form Saving methods

-(NSString *)getContentInFormDictForView:(id)view {
    NSString *value;
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    NSString *sectionName;
    NSString *rowName = @"";
    
    if(indexPath.section == 0){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"];
    }
    else if(indexPath.section == 1) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_NAME"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SURNAME"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_BP"];
        }
    }
    else if(indexPath.section == 2) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_CAPITAN"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_NAME"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SURNAME"];
        }
    }
    else {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ENROLLMENT"];
        }
        else {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"];
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", sectionName]] objectAtIndex:0];
    
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
    
    value = [eventDict objectForKey:rowName];
    DLog(@"value ---> %@",value);

    if([view isKindOfClass:[TestView class]]) {
        if(value) {
            if([value containsString:@"-1"]) {
                value = [value substringFromIndex:3];
            }
            else if([value containsString:@"||"]) {
                value = [[value componentsSeparatedByString:@"||"] lastObject];
            }
            else {
                value = @"";
            }
        }
    }
    
    return value;
    
}

#pragma mark - Setting Content for View

-(void)setContentInFormDictForView:(id)view {
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    if(indexPath == nil)
        return;
    
    NSString *sectionName;
    NSString *rowName=@"";
    
    rowName = @"";
    
    if(indexPath.section == 0) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"];
    }
    else if(indexPath.section == 1) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_NAME"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SURNAME"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_BP"];
        }
    }
    else if(indexPath.section == 2) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_CAPITAN"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_NAME"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SURNAME"];
        }
    }
    else {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"];
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ENROLLMENT"];
        }
        else {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"];
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
    
    if([view isKindOfClass:[UISwitch class]]) {
        [eventDict setObject:((switchValue)? @"YES": @"NO")  forKey:rowName];
    }
    else if([view isKindOfClass:[TestView class]]) {
        [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:rowName];
    }
    else {
        [eventDict setObject:((UITextField *)view).text forKey:rowName];
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}

# pragma mark - Dropdown delegate method

-(void)valueSelectedInPopover:(TestView *)testView {
    [LTSingleton getSharedSingletonInstance].isDataChanged=YES;
    [self setContentInFormDictForView:testView];
    [self updateReportDictionary];
}

#pragma mark - switch changed delegate

-(void)switchChanged:(UISwitch *)sw {
    
    switchValue = sw.isOn;
    [LTSingleton getSharedSingletonInstance].isDataChanged = YES;
    [LTSingleton getSharedSingletonInstance].enableCells = sw.selected;
    
    NSString *temp = (switchValue) ? @"YES":@"NO";
    
    NSDictionary *legdict = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
    NSString *key = [NSString stringWithFormat:@"%@-%@", [legdict objectForKey:@"origin"], [legdict objectForKey:@"destination"]];
    [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:temp forKey:key];
    if([LTSingleton getSharedSingletonInstance].sendReport) {
        NSNotification *notification = [NSNotification notificationWithName:@"MandatoryFields" object:nil userInfo:@{@"Hidden":[NSNumber numberWithBool:TRUE]}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    [[LTSingleton getSharedSingletonInstance].enableCellsDictionary setObject:temp forKey:[NSNumber numberWithInt:[LTSingleton getSharedSingletonInstance].legNumber]];
    
    // [self initializeIndexPathArray];
    [_generalTableView reloadData];

    [self cellsForTableView:_generalTableView];

    [self setContentInFormDictForView:sw];
}

-(void)clearFormValues {
    NSDictionary *flightRoasterDraft = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableArray *tempArray;
    
    if(flightRoasterDraft != nil) {
        tempArray = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        for(NSDictionary *groupDict in tempArray){
            for(NSString *rowName in [[groupDict objectForKey:@"singleEvents"] allKeys]){
                [[groupDict objectForKey:@"singleEvents"] setObject:@"" forKey:rowName];
                if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"]]){
                    [[groupDict objectForKey:@"singleEvents"] setObject:@"NO" forKey:rowName];
                }
            }
        }
        
    }
}

#pragma mark - keyboard methods

- (UIToolbar *)keyboardToolBar {
    
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
    OffsetCustomCell *cell;
    if(ISiOS8)
        cell =((OffsetCustomCell *)([[currentTxtField superview] superview]));
    else
        cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
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
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.generalTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.generalTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            for(int section = cell.indexPath.section ;section<[self.generalTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.generalTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.generalTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    
    currentTxtField = textField;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.generalTableView];
    CGPoint contentOffset = self.generalTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.generalTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([LTSingleton getSharedSingletonInstance].legPressed == YES){
        [self setContentInFormDictForView:textField];
    }
    else{
        return;
    }
    
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
        
        NSIndexPath *indexPath = [self.generalTableView indexPathForCell:cell];
        [self.generalTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    [LTSingleton getSharedSingletonInstance].isDataChanged=YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.location == 0 && [string isEqualToString:@" "])
        return NO;
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[textField superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[textField superview] superview] superview]).indexPath;
    
    if (!string.length) {
        
        if(indexPath.section == 3 && indexPath.row == 1) {
            if([textField.text length] < 7 && [LTSingleton getSharedSingletonInstance].sendReport  && textField.tag == MANDATORYTAG) {
                textField.layer.borderColor = [[UIColor redColor] CGColor];
            }
            if([textField.text length] == 3 ) {
                textField.text = [textField.text substringWithRange:NSMakeRange(0, 1)];
                return NO;
            }
        }
        return YES;
    }
    
    if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    if(indexPath.section == 1 && indexPath.row == 2) {
        NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if(finalText.length > 8) {
            return NO;
        }
    }
    
    if(indexPath.section == 3 && indexPath.row == 1) {
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
            if([textField.text length] < 6 && [LTSingleton getSharedSingletonInstance].sendReport  && textField.tag == MANDATORYTAG) {
                textField.layer.borderColor = [[UIColor redColor] CGColor];
            }
            
            if ([textField.text length] == 2 && [textField.text substringWithRange:NSMakeRange(1, 1)] ) {
                textField.text = [[textField.text uppercaseString] stringByAppendingString:@"-"];
                return NO;
            }
            
            return NO;
        }
    }
    
    if([string length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendReport  && textField.tag == MANDATORYTAG){
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    return YES;
}

#pragma mark - tableview methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    else if(section == 1 || section == 3){
        return 3;
    }
    else{
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TextFieldNameCell";
    static NSString *switchIdentifier = @"SwitchCell";
    static NSString *DropDownIdentifier = @"DropDownCell";
    OffsetCustomCell *cell;
    
    if(indexPath.section == 0) {
        cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:switchIdentifier];
        if(cell == nil){
            cell = (SwitchCell *)[[[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:nil options:nil] objectAtIndex:0];
            cell.tag = kLegExecutedTag;
            [((SwitchCell *)cell).rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.indexPath = indexPath;
            switchValue = [[self getContentInFormDictForView:((SwitchCell *)cell).rightSwitch] boolValue];
            ((SwitchCell *)cell).rightSwitch.on = switchValue;
            ((SwitchCell *)cell).rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
        }
        ((SwitchCell *)cell).leftLabel.attributedText = [[[appDel copyTextForKey:@"GENERAL_TRAMO_EJECUTADO"] stringByAppendingString:@"*"] mandatoryString];        //        return cell;
        
        if([LTSingleton getSharedSingletonInstance].enableCells){
            cell.userInteractionEnabled = YES;
            cell.contentView.alpha = 1.0f;
            [cell setFrame:cell.frame];
        }
    }
    
    else if(indexPath.section == 3 && (indexPath.row == 0 || indexPath.row == 2)) {
        cell = (DropDownCell *)[tableView dequeueReusableCellWithIdentifier:DropDownIdentifier];
        if(cell == nil){
            cell = (DropDownCell *)[[[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil] objectAtIndex:0];
        }
        cell.indexPath = indexPath;
        cell.leftLabel.attributedText = [[[[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row] stringByAppendingString:@"*"] mandatoryString] ;
        ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
        ((DropDownCell *)cell).comboView.dataSource = (indexPath.row == 0)?materialDropdown:baseCrewDropdown;
        ((DropDownCell *)cell).comboView.key = (indexPath.row == 0)?[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"];
        
        ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
        ((DropDownCell *)cell).comboView.delegate = self;
        ((DropDownCell *)cell).comboView.dropDownButton.enabled = switchValue;
        ((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
    }
    
    else {
        cell = (TextFieldNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            NSArray *ar = [[NSBundle mainBundle] loadNibNamed:@"TextFieldNameCell" owner:nil options:nil];
            cell =(TextFieldNameCell *) [ar objectAtIndex:0];
            ((TextFieldNameCell *)cell).rightTextTextField.tag = MANDATORYTAG;
            
        }
        cell.indexPath = indexPath;
        cell.leftLabel.attributedText = [[[[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row] stringByAppendingString:@"*"] mandatoryString] ;
        ((TextFieldNameCell *)cell).rightTextTextField.enabled = switchValue;
        ((TextFieldNameCell *)cell).rightTextTextField.delegate = self;
        
        ((TextFieldNameCell *)cell).rightTextTextField.text = [self getContentInFormDictForView:((TextFieldNameCell *)cell).rightTextTextField];
        ((TextFieldNameCell *)cell).rightTextTextField.font=[UIFont fontWithName:KFontName size:14.0];

        [((TextFieldNameCell *)cell).rightTextTextField setBorderStyle:UITextBorderStyleNone];
        [((TextFieldNameCell *)cell).rightTextTextField.layer setBorderWidth:1.0f];        [((TextFieldNameCell *)cell).rightTextTextField.layer setBorderColor:[[UIColor clearColor] CGColor]];
    }
    
    if([[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d", indexPath.row, indexPath.section]] count] == 0){
        [self.ipArray addObject:indexPath];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([LTSingleton getSharedSingletonInstance].sendReport && !([NSStringFromClass([cell class]) isEqualToString:@"AddRowCell"])){
        self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] validateCell:(OffsetCustomCell *)cell withLeastIndexPath:self.leastIndexPath];
        NSLog(@"ID:%@",self.leastIndexPath);
    }
    if(indexPath.section == 3 && indexPath.row == 1 && [LTSingleton getSharedSingletonInstance].sendReport ){
        UIView *cellContentView ;
        if([[[[cell.subviews firstObject] subviews] objectAtIndex:0] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]){
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:0];
            
        }else if(([[[[cell.subviews firstObject] subviews] objectAtIndex:1] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:1];
        }
        NSMutableArray *textFieldsArray = [[NSMutableArray alloc] init];
        [textFieldsArray addObjectsFromArray:((NSMutableArray *)([[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]))];
        UITextField *textField = (UITextField*)[textFieldsArray firstObject];
        if ([textField.text length] < 6) {
            textField.layer.borderColor = [[UIColor redColor] CGColor];
        }
    }
    if (!(indexPath.row == 0 && indexPath.section == 0)){
        if (!switchValue){
            [cell setAlpha:0.6f];
        }else{
            [cell setAlpha:1.0f];
        }
    }
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    NSString *sectionTitle;
    sectionTitle = [sectionArray objectAtIndex:section];
    
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


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}



#pragma mark - Keyboard Hiding

-(void)keyboardDidHide:(NSNotification *)notif{
    [self updateReportDictionary];
}

#pragma mark - View Life cycle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardDidHide:)
     name:UIKeyboardDidHideNotification
     object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:UIKeyboardDidHideNotification
     object:nil];
}
//

@end
