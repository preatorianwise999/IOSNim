//
//  TAMOverviewViewController.m
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TAMOverviewViewController.h"
#import "OffsetCustomCell.h"
#import "TextFieldNameCell.h"
#import "TextTextCell.h"
#import "AddRowCell.h"
#import "ComboBoxTextCell.h"
#import "ComboTextTextCell.h"
#import "TwoButtonCell.h"
#import "NumberTextCell.h"
#import "TextObservationsCell.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"


@interface TAMOverviewViewController () {
    NSArray *sectionArray;
    
    NSMutableArray *specialServiceOccurencesArray;
    NSMutableArray *specialServicePassengersArray;
    NSMutableArray *specialOccurencesArray;
    NSMutableArray *accompanyArray;
    
    
    NSMutableArray *flightOccurencesArray;
    NSMutableArray *superiorFlightOccurencesArray;
    
    NSMutableArray *desspecialServiceOccurencesArray;
    
    NSMutableArray *documentsAddedArray;
    
    UITextField *currentTxtField;
    
    AppDelegate *appDel;
    NSMutableArray *groupArr;
    
    NSMutableArray *especoOccDropDown;
    NSMutableArray *spOccDropDown;
    
    NSMutableArray *flightDropDown;
    NSMutableArray *occMedicasDropDown;
    NSMutableArray *desembarqueDropDown;
    
    NSMutableArray *documentDropDown;
    NSIndexPath *deleteIndexPath;
    NSMutableArray *aguaBordoEmb;
    NSMutableArray *aguaBordoDesem;
    NSMutableArray *wasteEmb;
    NSMutableArray *wasteDesem;
}
@end

@implementation TAMOverviewViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self initializeData];
    }
    return self;
}

#pragma mark - Data Initialization

-(void)initializeData {
    
    CGRect frame = _overviewTableView.frame;
    frame.size.height = -5;
    self.tableView = _overviewTableView;
    self.tableView.frame = frame;
    boardingDropDown = [[NSMutableArray alloc] init];

    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    specialServiceOccurencesArray = [[NSMutableArray alloc] init];
    specialServicePassengersArray = [[NSMutableArray alloc] init];
    specialOccurencesArray = [[NSMutableArray alloc] init];
    accompanyArray = [[NSMutableArray alloc] init];
    
    flightOccurencesArray = [[NSMutableArray alloc] init];
    superiorFlightOccurencesArray = [[NSMutableArray alloc] init];
    desspecialServiceOccurencesArray = [[NSMutableArray alloc] init];
    documentsAddedArray = [[NSMutableArray alloc] init];
    
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    groupArr = [[NSMutableArray alloc]init];
    
    if(flightRoasterDraft != nil) {
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        for(NSDictionary *groupDict in groupArr) {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys]) {
                for(int i = 0; i < [[[groupDict objectForKey:@"multiEvents"] objectForKey:rowName] count]; i++) {
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"]]) {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"]]) {
                            [specialServiceOccurencesArray addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"]]) {
                            [specialServicePassengersArray addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"]]) {
                            [specialOccurencesArray addObject:@"1"];
                        }
                        else {
                            [accompanyArray addObject:@"1"];
                        }
                        
                    }
                    else if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_VUELO"]]) {
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"]]) {
                            [flightOccurencesArray addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"]]) {
                            [superiorFlightOccurencesArray addObject:@"1"];
                        }
                    }
                    else if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]]) {
                        [desspecialServiceOccurencesArray addObject:@"1"];
                    }
                    else if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"]]) {
                        [documentsAddedArray addObject:@"1"];
                    }
                }
            }
        }
    }
    
    if ([groupArr count] == 0) {
        
        groupArr = [[NSMutableArray alloc]init];
        
        
        NSMutableDictionary *groupDict;
        
        NSMutableDictionary *embarqueDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"],[appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"], [appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"], [appDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"], nil]];
        
        NSMutableDictionary *singleEmbarqueDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc]initWithFormat:@" ",[appDel copyTextForKey:@"GENERAL_SELECT"]],[[NSString alloc]initWithFormat:@" ",[appDel copyTextForKey:@"GENERAL_SELECT"]],[[NSString alloc] initWithFormat:@"%@",[appDel copyTextForKey:@"GENERAL_SELECT"]], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"WASTE_EMBARQUE"],[appDel copyEnglishTextForKey:@"AGUA_EMBARQUE"],[appDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"], nil]];
        
        NSMutableDictionary *wchDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"0"],[[NSString alloc] initWithFormat:@""],nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_WCH"],[appDel copyEnglishTextForKey:@"OBSERVATION"],nil]];
        
        NSMutableDictionary *arnesDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"0"],[[NSString alloc] initWithFormat:@""],nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_ARNES"],[appDel copyEnglishTextForKey:@"OBSERVATION"],nil]];
        
        NSMutableDictionary *vueloDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] initWithObjects:wchDictionary, nil],[[NSMutableArray alloc] initWithObjects:arnesDictionary, nil],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"],[appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"],[appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"],[appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"], nil]];
        
        NSMutableDictionary *desembarqueDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"], nil]];
        
        NSMutableDictionary *singleDesembarqueDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc]initWithFormat:@" ",[appDel copyTextForKey:@"GENERAL_SELECT"]],[[NSString alloc]initWithFormat:@" ",[appDel copyTextForKey:@"GENERAL_SELECT"]],[[NSString alloc] initWithFormat:@"%@",[appDel copyTextForKey:@"GENERAL_SELECT"]], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"],[appDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"],[appDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"], nil]];
        
        NSMutableDictionary *documentDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"] forKey:@"name"];
        [groupDict setObject:singleEmbarqueDict forKey:@"singleEvents"];
        [groupDict setObject:embarqueDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_VUELO"] forKey:@"name"];
        [groupDict setObject:vueloDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"] forKey:@"name"];
        [groupDict setObject:singleDesembarqueDict forKey:@"singleEvents"];
        [groupDict setObject:desembarqueDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
        if(![flightType  isEqual: DOMTAM]){
            groupDict = [[NSMutableDictionary alloc] init];
            [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"] forKey:@"name"];
            [groupDict setObject:documentDict forKey:@"multiEvents"];
            [groupArr addObject:groupDict];
        }
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    [self configurePopovers];
}

#pragma mark - Popover Configuring

-(void)configurePopovers {
    
    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    NSString *report = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
    
    NSString *section = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
    
    NSMutableDictionary *retDict = [LTGetDropDownvalue getDictForReportType:flightType FlightReport:report Section:section];
    
    especoOccDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"Boarding"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"]] objectForKey:[appDel copyEnglishTextForKey:@"OPTION"]];
    
    spOccDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"Boarding"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"]] objectForKey:[appDel copyEnglishTextForKey:@"REPORT"]];
    
    flightDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_VUELO"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"]] objectForKey:[appDel copyEnglishTextForKey:@"REPORT"]];
    occMedicasDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_VUELO"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"]] objectForKey:[appDel copyEnglishTextForKey:@"REPORT"]];
    
    desembarqueDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"]] objectForKey:[appDel copyEnglishTextForKey:@"REPORT"]];
    
    documentDropDown = [[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"]] objectForKey:[appDel copyEnglishTextForKey:@"DOCUMENTO"]];
    
    aguaBordoEmb =[[[retDict objectForKey:[appDel copyEnglishTextForKey:@"Boarding"]] objectForKey:[appDel copyEnglishTextForKey:@"AGUA_EMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"WSTBRQ"]];
    
    wasteEmb =[[[retDict objectForKey:[appDel copyEnglishTextForKey:@"Boarding"]] objectForKey:[appDel copyEnglishTextForKey:@"WASTE_EMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"WTRBRQ"]];
    
    aguaBordoDesem =[[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"WSTDRQ"]];
    
    wasteDesem =[[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"]] objectForKey:[appDel copyEnglishTextForKey:@"WTRDRQ"]];
    
    NSString *manga = [appDel copyTextForKey:@"GENERAL_MANGA"];
    manga.accessibilityLabel = [appDel copyEnglishTextForKey:@"GENERAL_MANGA"];
    NSString *remote = [appDel copyTextForKey:@"GENERAL_REMOTO"];
    remote.accessibilityLabel = [appDel copyEnglishTextForKey:@"GENERAL_REMOTO"];
    boardingDropDown = [[NSArray arrayWithObjects:manga ,remote,nil] mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ipArray = [[NSMutableArray alloc] init];
    super.tableView = _overviewTableView;
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    if([flightType  isEqual: DOMTAM]) {
        sectionArray = [[NSArray alloc] initWithObjects:[appDel copyTextForKey:@"GENERAL_EMBARQUE"],[appDel copyTextForKey:@"GENERAL_VUELO"],[appDel copyTextForKey:@"GENERAL_DESEMBARQUE"],[appDel copyTextForKey:@"TITULO_WSTBRQ"],[appDel copyTextForKey:@"TITULO_WTRBRQ"], nil];
    }
    else {
        sectionArray = [[NSArray alloc] initWithObjects:[appDel copyTextForKey:@"GENERAL_EMBARQUE"],[appDel copyTextForKey:@"GENERAL_VUELO"],[appDel copyTextForKey:@"GENERAL_DESEMBARQUE"],[appDel copyTextForKey:@"TITULO_WSTBRQ"],[appDel copyTextForKey:@"TITULO_WTRBRQ"],[appDel copyTextForKey:@"GENERAL_DOCUMENTOS"], nil];
    }
    [_overviewTableView setEditing:YES animated:YES];
    self.headingLabel.text = [appDel copyTextForKey:@"Overview"];
    _headingLabel.textColor=kFontColor;
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    CGRect frame = _headingLabel.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    _headingLabel.frame= frame;
    sourceDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_SELECT"],[appDel copyTextForKey:@"GENERAL_MANGA"],[appDel copyTextForKey:@"GENERAL_REMOTO"],nil],[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],nil];

    _header_Line.frame = CGRectMake(15, 37,560,8);

    [self initializeIndexPathArray];
    _overviewTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Keyboard Methods

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

-(void)navigateField:(UISegmentedControl *)segControl {
    id textfield_ref;
    
    if (ISiOS8) {
        textfield_ref = [[currentTxtField superview] superview];
    }
    else {
        textfield_ref = [[[currentTxtField superview] superview] superview];
    }
    
    OffsetCustomCell *cell = ((OffsetCustomCell *)(textfield_ref));
    id view;
    if(segControl.selectedSegmentIndex == 0){
        view = [cell viewWithTag:currentTxtField.tag - 1];
        
    }
    else {
        view = [cell viewWithTag:currentTxtField.tag + 1];
    }
    if(view == nil) {
        
        if(segControl.selectedSegmentIndex == 0) {
            for(int section = cell.indexPath.section ;section>=0;section--) {
                BOOL isPrevFieldFound = NO;
                int rowVal;int tempTag=-9678;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.overviewTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--) {
                    cell = (OffsetCustomCell *)[self.overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]) {
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]){
                        tempTag = MANDATORYTAG;
                    }
                    if([cell viewWithTag:tempTag]) {
                        if([[[cell viewWithTag:tempTag] superview] isKindOfClass:[TestView class]]){
                            
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
            for(int section = cell.indexPath.section ;section<[self.overviewTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=-9678;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.overviewTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.overviewTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]) {
                        tempTag = TEXTFIELD_BEGIN_TAG;
                    }
                    else if([cell viewWithTag:MANDATORYTAG]) {
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

#pragma mark - Form Saving Methods

-(NSString *)getContentInFormDictForView:(id)view {
    NSString *value;
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSString *labelKey;
    
    if(indexPath.section == 0) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
        
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"];
            row = indexPath.row;
        }
        else if(indexPath.row > 1 && indexPath.row < 2+[specialServiceOccurencesArray count]) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"];
            row = indexPath.row - 2;
            
        }
        else if(indexPath.row > 2+[specialServiceOccurencesArray count] && indexPath.row < 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"];
            row = indexPath.row - (3+[specialServiceOccurencesArray count]);
            
        }
        else if(indexPath.row > 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count] && indexPath.row < 4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"];
            row = indexPath.row-(4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]);
            
        }
        else {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"];
            row = indexPath.row-(5+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]);
        }
    }
    else if(indexPath.section == 1) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"];
            row = indexPath.row;
            if([view isKindOfClass:[UILabel class]]) {
                
                labelKey = [appDel copyEnglishTextForKey:@"GENERAL_WCH"];
            }
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"];
            row = indexPath.row - 1;
            if([view isKindOfClass:[UILabel class]]){
                
                labelKey = [appDel copyEnglishTextForKey:@"GENERAL_ARNES"];
            }
        }
        else if(indexPath.row > 2 && indexPath.row < 3+[flightOccurencesArray count]) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"];
            row = indexPath.row - 3;
        }
        else {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"];//GENERAL_ADD_MEDICAS//GENERAL_CUMPLE_OCC
            row = indexPath.row - (4+[flightOccurencesArray count]);
        }
    }
    else if(indexPath.section == 2) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
        
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"];
            row = indexPath.row;
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"];
            row = indexPath.row - 2;
        }
    }
    else if(indexPath.section == 3){
        if(indexPath.row == 0) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"AGUA_EMBARQUE"];
            row = indexPath.row;
        }
        else if(indexPath.row == 1) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"];
            row = indexPath.row-1;
        }
        
    }
    else if(indexPath.section == 4){
        if(indexPath.row == 0) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"WASTE_EMBARQUE"];
            row = indexPath.row;
        }
        else if(indexPath.row == 1) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"];
            row = indexPath.row-1;
            
        }
        
    }
    else if(indexPath.section == 5) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"];
        row = indexPath.row - 1;
    }

    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    if((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0)|| (indexPath.section == 3) || (indexPath.section == 4)) {
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        
        value = [eventDict objectForKey:rowName];
        
        if((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0)|| (indexPath.section == 3) || (indexPath.section == 4)) {
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
            DLog(@"value ---> %@",value);
            value = [eventDict objectForKey:rowName];
            
            if([view isKindOfClass:[TestView class]]) {
                
                if([value isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_SELECT"]]) {
//                    value=@"";
                }
                else{
                    if ((indexPath.section == 3) || (indexPath.section == 4)){
                        value=[eventDict objectForKey:rowName];
                        value = [[value componentsSeparatedByString:@"||"] lastObject];
                    }else{
                        value=[eventDict objectForKey:rowName];
                    }
                }

//        if([view isKindOfClass:[TestView class]])
//        {
//            NSString *testViewValue = [eventDict objectForKey:rowName];
//            if(testViewValue)
//            {
//                if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ARNES_OBSERVATIONS"]] || [((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_WCH_OBSERVATIONS"]])
//                    value = testViewValue;
//                else if([testViewValue containsString:@"-1"])
//                {
//                    NSString *other = [testViewValue substringFromIndex:3];
//                    
//                    value = [[other componentsSeparatedByString:@"||"] firstObject];
//                }
//            }
//        }
            }
            }
    }
    else{
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArray = [eventDict objectForKey:rowName];
        NSMutableDictionary *cellDictionary = [cellArray objectAtIndex:row];
        if([view isKindOfClass:[TestView class]])
        {
            NSString *testViewValue = [cellDictionary objectForKey:((TestView *)view).key];
            if(testViewValue)
            {
                if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"]])
                    value = testViewValue;
                else if([testViewValue containsString:@"-1"])
                {
                    NSString *other = [testViewValue substringFromIndex:3];
                    
                    value = [[other componentsSeparatedByString:@"||"] firstObject];
                }
                else
                    value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
            }
        }
        else if([view isKindOfClass:[UITextField class]]){
            value =  [cellDictionary objectForKey:((UITextField *)view).accessibilityIdentifier];
        }
        else if([view isKindOfClass:[UILabel class]]){
            value = [cellDictionary objectForKey:labelKey];
        }
        else{
            value = [cellDictionary objectForKey:rowName];
        }
    }
    
    return value;
    
}


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
    NSString *labelKey;
    labelKey = @"";
    
    
    if(indexPath.section == 0){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
        
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"];
            row = indexPath.row;
        }
        else if(indexPath.row > 1 && indexPath.row < 2+[specialServiceOccurencesArray count]){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"];
            row = indexPath.row - 2;
            
        }
        else if(indexPath.row > 2+[specialServiceOccurencesArray count] && indexPath.row < 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"];
            row = indexPath.row - (3+[specialServiceOccurencesArray count]);
            
        }
        else if(indexPath.row > 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count] && indexPath.row < 4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"];
            row = indexPath.row-(4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]);
            
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"];
            row = indexPath.row-(5+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]);
        }
    }
    else if(indexPath.section == 1){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO"];
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"];
            row = indexPath.row;
            if([view isKindOfClass:[UIButton class]]){
                
                labelKey = [appDel copyEnglishTextForKey:@"GENERAL_WCH"];
            }
            
        }
        else if(indexPath.row == 1){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"];
            row = indexPath.row-1;
            if([view isKindOfClass:[UIButton class]]){
                
                labelKey = [appDel copyEnglishTextForKey:@"GENERAL_ARNES"];
            }
            
        }
        else if(indexPath.row > 2 && indexPath.row < 3+[flightOccurencesArray count]){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"];
            row = indexPath.row - 3;
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"];//GENERAL_ADD_MEDICAS//GENERAL_CUMPLE_OCC
            row = indexPath.row - (4+[flightOccurencesArray count]);
        }
    }
    else if(indexPath.section == 2){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
        
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"];
            row = indexPath.row;
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"];
            row = indexPath.row - 2;
        }
    }
    else if(indexPath.section == 3){
        if(indexPath.row == 0) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"AGUA_EMBARQUE"];
            row = indexPath.row;
        }
        else if(indexPath.row == 1) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"];
            row = indexPath.row;
        }
        
    }
    else if(indexPath.section == 4){
        if(indexPath.row == 0) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"WASTE_EMBARQUE"];
            row = indexPath.row-1;
        }
        else if(indexPath.row == 1) {
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"];
            row = indexPath.row-1;
            
        }
        
    }
    else if(indexPath.section == 5){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"];
        row = indexPath.row - 1;
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    
    if((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 3) || (indexPath.section == 4)){
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        
        if([view isKindOfClass:[TestView class]]){
            if([((TestView *)view).selectedValue isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_SELECT"]]){
//                [eventDict setObject:@"" forKey:rowName];
                ;
                
            }
            else{
                if ((indexPath.section == 3) || (indexPath.section == 4)){
                    [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:rowName];
                }else{
                    [eventDict setObject:((TestView *)view).selectedValue forKey:rowName];
                }
            }
            
        }
        
        
        
        //        if([view isKindOfClass:[UISegmentedControl class]]){
//            [eventDict setObject:([view selectedSegmentIndex]?[appDel copyEnglishTextForKey:@"GENERAL_REMOTO"]:[appDel copyEnglishTextForKey:@"GENERAL_MANGA"])  forKey:rowName];
//        }
//        else if([view isKindOfClass:[TestView class]]){
//            [eventDict setObject:((TestView *)view).selectedValue forKey:rowName];
//        }
//        else{
//            
//            id view_ref;
//            if(ISiOS8)
//                view_ref = [[view superview] superview];
//            else
//                view_ref = [[[view superview] superview] superview];
//            
//            [eventDict setObject:[((NumberTextCell *)view_ref) valueLabel].text forKey:rowName];
//            
//        }
    }
    
    else{
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArray = [eventDict objectForKey:rowName];
        
        NSMutableDictionary *cellDict=[[NSMutableDictionary alloc] init];
        if([cellArray count]>row)
            cellDict = [cellArray objectAtIndex:row];
        if([view isKindOfClass:[TestView class]]){
            if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"]]){
                [cellDict setObject:((TestView *)view).selectedValue forKey:((TestView *)view).key];
            }
            else{
                [cellDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
            }
        }
        else if([view isKindOfClass:[UITextField class]]){
            [cellDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
        }
        else{
            id view_ref;
            if(ISiOS8)
                view_ref = [[view superview] superview];
            else
                view_ref = [[[view superview] superview] superview];
            
            
            [cellDict setObject:[((NumberTextCell *)view_ref) valueLabel].text forKey:labelKey];
        }
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}

-(void)valueSelectedInPopover:(TestView *)testView{
    [LTSingleton getSharedSingletonInstance].isDataChanged=YES;

    [self setContentInFormDictForView:testView];
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    [self.overviewTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self updateReportDictionary];
    
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    currentTxtField = textField;
    
    id textField_ref;
    if(ISiOS8)
        textField_ref = textField.superview;
    else
        textField_ref = textField.superview.superview;
    
    CGPoint pointInTable = [textField_ref convertPoint:textField.frame.origin toView:self.overviewTableView];
    CGPoint contentOffset = self.overviewTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset - 20);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.overviewTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([LTSingleton getSharedSingletonInstance].legPressed == YES){
        NSIndexPath *indexPath;
        if(ISiOS8)
            indexPath = ((OffsetCustomCell *)[[textField superview] superview]).indexPath;
        else
            indexPath = ((OffsetCustomCell *)[[[textField superview] superview] superview]).indexPath;
        
        
        if (deleteIndexPath && [deleteIndexPath compare:indexPath] == NSOrderedSame)
        {
            return;
        }
        [self setContentInFormDictForView:textField];
    }
    else{
        return;
    }
    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES){
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return;
    }    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES){
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return;
    }
    
    id textfield_ref;
    
    if (ISiOS8) {
        textfield_ref = textField.superview.superview;
    }
    else
    {
        textfield_ref = textField.superview.superview.superview;
    }
    
    if ([textfield_ref isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell = (UITableViewCell*)textfield_ref;
        NSIndexPath *indexPath = [self.overviewTableView indexPathForCell:cell];
        [self.overviewTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.location == 0 && [string isEqualToString:@" "])
        return NO;
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    
    NSIndexPath *ip;
    if(ISiOS8)
        ip = ((OffsetCustomCell *)[[textField superview] superview]).indexPath;
    else
        ip = ((OffsetCustomCell *)[[[textField superview] superview] superview]).indexPath;
    
    if(ip.section == 5){
        
        if(![string validateNumeric]) {
            return NO;
        }
    }
    
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    
    if([string length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendReport && textField.tag == MANDATORYTAG){
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    if (!string.length)
    {
        return YES;
    }
    
    if(([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"AMOUNT"]]) && ((![textField.text validateMaximumLength:KAmountLength] && string.length > 0)|| ![string validateNumeric]))
        return NO;
    
    if([textField.text length] == KOtherFieldsLength) return NO;
    
    return YES;
}



#pragma mark - tableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 5+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]+[accompanyArray count];
    }
    else if(section == 1){
        return 4+[flightOccurencesArray count]+[superiorFlightOccurencesArray count];
    }
    else if(section == 2){
        return 2+[desspecialServiceOccurencesArray count];
    }
    else if(section == 3){
        return 2;
    }
    else if(section == 4){
        return 2;
    }
    else{
        return 1+[documentsAddedArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return nil;
    }
    
    static NSString *headingIdentifier = @"HeaderCell";
    static NSString *textFieldIdentifier = @"TextFieldNameCell";
    static NSString *comboTextIdentifier = @"ComboBoxTextCell";
    static NSString *comboTextTextIdentifier = @"ComboTextTextCell";
    static NSString *numberTextIdentifier = @"NumberTextFieldCell";
    static NSString *textObservationIdentifier = @"TextObservationsCell";
    static NSString *dropDownIdentifier = @"DropDownCell";

    OffsetCustomCell *cell;
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
        
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.attributedText = [[[appDel copyTextForKey:@"GENERAL_TIPO_EMBARQUE"] stringByAppendingString:@"*"] mandatoryString] ;
            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = boardingDropDown;
            ((DropDownCell *)cell).comboView.selectedTextField.text = [appDel valueForEnglishValue:[self getContentInFormDictForView:((DropDownCell *)cell).comboView]];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
        }
        else if(indexPath.row == 1) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GEN_ADD_SPEC_OCC"];
        }
        else if(indexPath.row == 2 + [specialServiceOccurencesArray count]) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GEN_ADD_PASS_SPEC_OCC"];
        }
        else if(indexPath.row == 3 + [specialServiceOccurencesArray count]+[specialServicePassengersArray count]) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GEN_ADD_ESPACO_OCC"];
        }
        else if(indexPath.row == 4 + [specialServicePassengersArray count]+[specialServiceOccurencesArray count]+[specialOccurencesArray count]) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GEN_ADD_ACCOMP_OCC"];
        }
        else if(indexPath.row > 1 && indexPath.row < 2 + [specialServiceOccurencesArray count]) {
            cell = (ComboBoxTextCell *)[self createCellForTableView:tableView withCellID:comboTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboBoxTextCell *)cell).reportLabel.text = [appDel copyTextForKey:@"REPORT@TAM"];
            ((ComboBoxTextCell *)cell).comboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.dataSource = spOccDropDown;
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            ((ComboBoxTextCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            
            
            ((ComboBoxTextCell *)cell).reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT@TAM"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboBoxTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            ((ComboBoxTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"REPORT"];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            
            ((ComboBoxTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboBoxTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboBoxTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboBoxTextCell *)cell).alertComboView.delegate = self;
            ((ComboBoxTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            ((ComboBoxTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            if([self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
        else if(indexPath.row > 2 + [specialServiceOccurencesArray count] && indexPath.row < 3 + [specialServiceOccurencesArray count]+[specialServicePassengersArray count]) {
            cell = (TextObservationsCell *)[self createCellForTableView:tableView withCellID:textObservationIdentifier];
            cell.indexPath = indexPath;
            
            ((TextObservationsCell *)cell).numberLabel.attributedText = [[[appDel copyTextForKey:@"INDICAR_NUMERO"] stringByAppendingString:@"*"] mandatoryString];
            
            ((TextObservationsCell *)cell).textField.tag = MANDATORYTAG;
            ((TextObservationsCell *)cell).observationsLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            ((TextObservationsCell *)cell).textField.delegate = self;
            //((TextObservationsCell *)cell).textField.inputAccessoryView = [self keyboardToolBar];
            ((TextObservationsCell *)cell).textField.accessibilityIdentifier=[appDel copyEnglishTextForKey:@"INDICAR_NUMERO"];
            ((TextObservationsCell *)cell).textField.text = [self getContentInFormDictForView:((TextObservationsCell *)cell).textField];
            
            
            ((TextObservationsCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((TextObservationsCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((TextObservationsCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((TextObservationsCell *)cell).alertComboView.delegate = self;
            ((TextObservationsCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((TextObservationsCell *)cell).alertComboView];
            ((TextObservationsCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((TextObservationsCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((TextObservationsCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((TextObservationsCell *)cell).alertComboView] isEqualToString:@""]) {
                [((TextObservationsCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((TextObservationsCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
        else if(indexPath.row > 3 + [specialServiceOccurencesArray count]+[specialServicePassengersArray count] && indexPath.row < 4 + [specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]) {
            
            cell = (ComboBoxTextCell *)[self createCellForTableView:tableView withCellID:comboTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            ((ComboBoxTextCell *)cell).reportLabel.attributedText = [[[appDel copyTextForKey:@"SELECIONAR_OPCOES@TAM"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboBoxTextCell *)cell).comboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.dataSource = especoOccDropDown;
            ((ComboBoxTextCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            ((ComboBoxTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"OPTION"];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            ((ComboBoxTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            ((ComboBoxTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboBoxTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboBoxTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboBoxTextCell *)cell).alertComboView.delegate = self;
            ((ComboBoxTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            ((ComboBoxTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            if([self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
        
        else {
            cell = (TextFieldNameCell *)[self createCellForTableView:tableView withCellID:textFieldIdentifier];
            cell.leftLabel.attributedText=[[[appDel copyTextForKey:@"QUANT_ACCOMP"] stringByAppendingString:@"*"] mandatoryString];
            ((TextFieldNameCell *)cell).rightTextTextField.tag = MANDATORYTAG;
            cell.indexPath = indexPath;
            ((TextFieldNameCell *)cell).rightTextTextField.delegate = self;
            ((TextFieldNameCell *)cell).rightTextTextField.accessibilityIdentifier=[appDel copyEnglishTextForKey:@"QUANT_ACCOMPANY"];
            ((TextFieldNameCell *)cell).rightTextTextField.text = [self getContentInFormDictForView:((TextFieldNameCell *)cell).rightTextTextField];
            ((TextFieldNameCell *)cell).rightTextTextField.font=[UIFont fontWithName:KFontName size:14.0];
        }
    }
    else if(indexPath.section == 1) {
        if(indexPath.row == 0 || indexPath.row == 1) {
            cell = (NumberTextCell *)[self createCellForTableView:tableView withCellID:numberTextIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = indexPath.row ?[appDel copyTextForKey:@"GENERAL_SOLICITUD_ARNES@TAM"]:[appDel copyTextForKey:@"GENERAL_SOLICITUD_WCH"];
            ((NumberTextCell *)cell).valueLabel.text = [self getContentInFormDictForView:((NumberTextCell *)cell).valueLabel];
            ((NumberTextCell *)cell).observationsLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            ((NumberTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            
            ((NumberTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((NumberTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((NumberTextCell *)cell).alertComboView.delegate = self;
            ((NumberTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((NumberTextCell *)cell).alertComboView];
            ((NumberTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((NumberTextCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((NumberTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((NumberTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((NumberTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((NumberTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
        else if(indexPath.row == 2) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_VUELO_OCC"];
        }
        else if(indexPath.row >2 && indexPath.row < 3+[flightOccurencesArray count]) {
            cell = (ComboBoxTextCell *)[self createCellForTableView:tableView withCellID:comboTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboBoxTextCell *)cell).comboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.dataSource = flightDropDown;
            
            ((ComboBoxTextCell *)cell).reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT@TAM"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            
            
            ((ComboBoxTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            ((ComboBoxTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"REPORT"];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            
            ((ComboBoxTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboBoxTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboBoxTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboBoxTextCell *)cell).alertComboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            
            ((ComboBoxTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            ((ComboBoxTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
        else if(indexPath.row == 3+[flightOccurencesArray count]) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_MEDICAS"];
            
        }
        else {
            
            cell = (ComboBoxTextCell *)[self createCellForTableView:tableView withCellID:comboTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboBoxTextCell *)cell).comboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.dataSource = occMedicasDropDown;
            ((ComboBoxTextCell *)cell).reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT@TAM"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            ((ComboBoxTextCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            
            ((ComboBoxTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            ((ComboBoxTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"REPORT"];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            
            ((ComboBoxTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboBoxTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboBoxTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboBoxTextCell *)cell).alertComboView.delegate = self;
            
            
            ((ComboBoxTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            ((ComboBoxTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
    }
    else if(indexPath.section == 2) {
        if(indexPath.row == 0) {
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.attributedText = [[[appDel copyTextForKey:@"GENERAL_TIPO_DESEMBARQUE"] stringByAppendingString:@"*"] mandatoryString];

            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = boardingDropDown;
            ((DropDownCell *)cell).comboView.selectedTextField.text = [appDel valueForEnglishValue:[self getContentInFormDictForView:((DropDownCell *)cell).comboView]];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
        }
        else if(indexPath.row == 1) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_DES_OCC"];
        }
        else {
            cell = (ComboBoxTextCell *)[self createCellForTableView:tableView withCellID:comboTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboBoxTextCell *)cell).comboView.delegate = self;
            ((ComboBoxTextCell *)cell).comboView.dataSource = desembarqueDropDown;
            
            ((ComboBoxTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"REPORT"];
            
            ((ComboBoxTextCell *)cell).reportLabel.attributedText = [[[appDel copyTextForKey:@"REPORT@TAM"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            
            ((ComboBoxTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            ((ComboBoxTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            
            ((ComboBoxTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboBoxTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboBoxTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboBoxTextCell *)cell).alertComboView.delegate = self;
            
            ((ComboBoxTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            ((ComboBoxTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboBoxTextCell *)cell).alertComboView] isEqualToString:@""]) {
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboBoxTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
        }
    }
    else if(indexPath.section == 5) {
        if(indexPath.row == 0) {
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"];
        }
        else {
            cell = (ComboTextTextCell *)[self createCellForTableView:tableView withCellID:comboTextTextIdentifier];
            cell.indexPath = indexPath;
            ((ComboTextTextCell *)cell).quantityLabel.attributedText = [[[appDel copyTextForKey:@"AMOUNT"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboTextTextCell *)cell).documentLabel.attributedText = [[[appDel copyTextForKey:@"DOCUMENTO"] stringByAppendingString:@"*"] mandatoryString];
            ((ComboTextTextCell *)cell).observationLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            ((ComboTextTextCell *)cell).textField.delegate=self;
            ((ComboTextTextCell *)cell).textField.tag = MANDATORYTAG;
            ((ComboTextTextCell *)cell).textField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            ((ComboTextTextCell *)cell).textField.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            ((ComboTextTextCell *)cell).textField.text = [self getContentInFormDictForView:((ComboTextTextCell *)cell).textField];
            ((ComboTextTextCell *)cell).textField.keyboardType = UIKeyboardTypeNumberPad;
            
            ((ComboTextTextCell *)cell).comboView.delegate = self;
            ((ComboTextTextCell *)cell).comboView.dataSource = documentDropDown;
            ((ComboTextTextCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            ((ComboTextTextCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            ((ComboTextTextCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"DOCUMENTO"];
            ((ComboTextTextCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((ComboBoxTextCell *)cell).comboView];
            
            ((ComboTextTextCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
            ((ComboTextTextCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((ComboTextTextCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((ComboTextTextCell *)cell).alertComboView.delegate = self;
            ((ComboTextTextCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((ComboTextTextCell *)cell).alertComboView];
            ((ComboTextTextCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((ComboTextTextCell *)cell).alertComboView];
            
            if([self getContentInFormDictForView:((ComboTextTextCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((ComboTextTextCell *)cell).alertComboView] isEqualToString:@""])
            {
                [((ComboTextTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [((ComboTextTextCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        }
    }
    if(indexPath.section == 3) {
        
        if(indexPath.row == 0) {
            
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = [appDel copyTextForKey:@"TITULO_WST_BRQ"];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = aguaBordoEmb;
            ((DropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"WSTBRQ"];
            
            ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            
            
            
        }else if(indexPath.row == 1) {
            
            
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = [appDel copyTextForKey:@"TITULO_WST_DRQ"];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = aguaBordoDesem;
            ((DropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"WSTDRQ"];
            
            ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            
            
        }
        
    }if(indexPath.section == 4) {
        
        if(indexPath.row == 0) {
            
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = [appDel copyTextForKey:@"TITULO_WTR_BRQ"];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = wasteEmb;
            ((DropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"WTRBRQ"];
            
            ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            
            
        }else if(indexPath.row == 1) {
            
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:dropDownIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = [appDel copyTextForKey:@"TITULO_WTR_DRQ"];
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.typeOfDropDown = NormalDropDown;
            ((DropDownCell *)cell).comboView.dataSource = wasteDesem;
            ((DropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"WTRDRQ"];
            
            ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            
        }
        
    }
    
    if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleInsert) {
        [[cell controlButton] setImage:[UIImage imageNamed:@"add"]];
    } else if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleDelete) {
        [[cell controlButton] setImage:[UIImage imageNamed:@"remove"]];
    }
    
    cell.indexPath = indexPath;
    if([[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] count] == 0) {
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
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID {
    
    if([cellID isEqualToString:@"HeaderCell"]) {
        AddRowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"TextTextCell"]) {
        TextTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextTextCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"ComboBoxTextCell"]) {
        ComboBoxTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboBoxTextCell" owner:self options:nil];
            cell = (ComboBoxTextCell *)[topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    
    else if([cellID isEqualToString:@"DropDownCell"]) {
        DropDownCell  *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:self options:nil];
            cell = (DropDownCell *)[topLevelObjects objectAtIndex:0];
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"TextFieldNameCell"]) {
        TextFieldNameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextFieldNameCell" owner:self options:nil];
            cell = (TextFieldNameCell *)[topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    
    else if([cellID isEqualToString:@"NumberTextFieldCell"]){
        NumberTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NumberTextCell" owner:self options:nil];
            cell = (NumberTextCell *)[topLevelObjects objectAtIndex:0];
            [cell.minusButton addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventTouchUpInside];
            [cell.plusButton addTarget:self action:@selector(setContentInFormDictForView:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    else if([cellID isEqualToString:@"TextObservationsCell"]){
        TextObservationsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if(cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextObservationsCell" owner:self options:nil];
            cell = (TextObservationsCell *)[topLevelObjects objectAtIndex:0];
        }
        return cell;
    }
    else {
        ComboTextTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboTextTextCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        cell.textField.delegate = self;
        return cell;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if(indexPath.section == 0) {
        if(indexPath.row == 1 || indexPath.row == 2+[specialServiceOccurencesArray count] || indexPath.row == 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count] || indexPath.row == 4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]) {
            style = UITableViewCellEditingStyleInsert;
        }
        else if(indexPath.row == 0) {
            style = UITableViewCellEditingStyleNone;
        }
        else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    else if(indexPath.section == 1) {
        if(indexPath.row == 2 || indexPath.row == 3+[flightOccurencesArray count]){
            style = UITableViewCellEditingStyleInsert;
        }
        else if((indexPath.row > 2 && indexPath.row < 3+[flightOccurencesArray count]) || indexPath.row > 3+[flightOccurencesArray count]){
            style = UITableViewCellEditingStyleDelete;
        }
    }
    else if(indexPath.section == 2) {
        if(indexPath.row == 1) {
            style = UITableViewCellEditingStyleInsert;
        }
        else if(indexPath.row > 1) {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    else if(indexPath.section == 5) {
        if(indexPath.row == 0) {
            style = UITableViewCellEditingStyleInsert;
        }
        else{
            style = UITableViewCellEditingStyleDelete;
        }
    }
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)) || (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 3) || (indexPath.section == 4)){
        return NO;
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    NSString *sectionTitle;
    sectionTitle = [sectionArray objectAtIndex:section];
    
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 0, kSectionalHeaderWidth, 40);
    if(section == 1){
        headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 10, kSectionalHeaderWidth, 30);
    }
    if(section == 2){
        headerView.frame = CGRectMake(kSectionalHeaderLableXPosition, 0, kSectionalHeaderWidth, 45);
        headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 7, kSectionalHeaderWidth, 45);
        
    }
    if(section == 5){
        headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 10, kSectionalHeaderWidth, 30);
    }
    if(section == 3){
        headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 15, kSectionalHeaderWidth, 30);
    }
    if(section == 4){
        headerLabel.frame = CGRectMake(kSectionalHeaderLableXPosition, 15, kSectionalHeaderWidth, 30);
    }
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 2) return 50;
    //    if(section == 3) return 40;
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)) || (indexPath.section == 2 && indexPath.row == 1) || (indexPath.section == 5 && indexPath.row == 0)){
        return 44;
    }
    if((indexPath.section == 0) && (indexPath.row == 1 || indexPath.row == 2+[specialServiceOccurencesArray count] || indexPath.row == 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count] || indexPath.row == 4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count])){
        return 44;
    }
    if(indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)){
        return 44;
    }
    return 44;
}




-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [currentTxtField resignFirstResponder];
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSIndexPath *modifiedIndexpath;
    
    if(editingStyle == UITableViewCellEditingStyleInsert){
        if(indexPath.section == 0){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            if(indexPath.row == 1){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"];
                [specialServiceOccurencesArray addObject:[NSNumber numberWithInt:[specialServiceOccurencesArray count]+1]];
            }
            else if(indexPath.row == 2+[specialServiceOccurencesArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"];
                [specialServicePassengersArray addObject:[NSNumber numberWithInt:[specialServicePassengersArray count]+1]];
            }
            else if(indexPath.row == 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"];
                [specialOccurencesArray addObject:[NSNumber numberWithInt:[specialOccurencesArray count]+1]];
            }
            else{
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"];
                [accompanyArray addObject:[NSNumber numberWithInt:[accompanyArray count]+1]];
            }
        }
        else if(indexPath.section == 1){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO"];
            if(indexPath.row == 2){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"];
                [flightOccurencesArray addObject:[NSNumber numberWithInt:[flightOccurencesArray count]+1]];
                
            }
            else{
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"];//GENERAL_ADD_MEDICAS//GENERAL_CUMPLE_OCC
                [superiorFlightOccurencesArray addObject:[NSNumber numberWithInt:[superiorFlightOccurencesArray count]+1]];
                
            }
        }
        else if(indexPath.section == 2){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"];
            
            [desspecialServiceOccurencesArray addObject:[NSNumber numberWithInt:[desspecialServiceOccurencesArray count]+1]];
            
        }
        else if(indexPath.section == 5){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"];
            [documentsAddedArray addObject:[NSNumber numberWithInt:[documentsAddedArray count]+1]];
        }
        else if(indexPath.section == 3){
            
            sectionName = [appDel copyEnglishTextForKey:@"TITULO_WSTBRQ"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_OCC"];
            [documentsAddedArray addObject:[NSNumber numberWithInt:[documentsAddedArray count]+1]];
        }
        else if(indexPath.section == 4){
            
            sectionName = [appDel copyEnglishTextForKey:@"TITULO_WTRBRQ"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"];
            [documentsAddedArray addObject:[NSNumber numberWithInt:[documentsAddedArray count]+1]];
        }

        
        NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        [cellArr insertObject:cellDict atIndex:0];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [_overviewTableView beginUpdates];
        [_overviewTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_overviewTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
        //[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        if (!ISiOS8) {
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        }
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        
        NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
        
        
        if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
            [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }
    else if(editingStyle == UITableViewCellEditingStyleDelete){
        deleteIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
        
        if(indexPath.section == 0){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"];
            if(indexPath.row >1 && indexPath.row < 2+[specialServiceOccurencesArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"];
                row = indexPath.row - 2;
                [specialServiceOccurencesArray removeObjectAtIndex:indexPath.row - 2];
            }
            else if(indexPath.row > 2+[specialServiceOccurencesArray count] && indexPath.row < 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]){
                
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"];
                row = indexPath.row - (3+[specialServiceOccurencesArray count]);
                [specialServicePassengersArray removeObjectAtIndex:indexPath.row - (3+[specialServiceOccurencesArray count])];
            }
            else if(indexPath.row > 3+[specialServiceOccurencesArray count]+[specialServicePassengersArray count] && indexPath.row < 4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]){
                
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"];
                row = indexPath.row-(4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]);
                [specialOccurencesArray removeObjectAtIndex:indexPath.row-(4+[specialServiceOccurencesArray count]+[specialServicePassengersArray count])];
            }
            else{
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"];
                row = indexPath.row-(5+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count]);
                [accompanyArray removeObjectAtIndex:indexPath.row-(5+[specialServiceOccurencesArray count]+[specialServicePassengersArray count]+[specialOccurencesArray count])];
            }
        }
        else if(indexPath.section == 1){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO"];
            if(indexPath.row > 2 && indexPath.row < 3+[flightOccurencesArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"];
                row = indexPath.row - 3;
                [flightOccurencesArray removeObjectAtIndex:indexPath.row - 3];
            }
            else{
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"];//GENERAL_CUMPLE_OCC GENERAL_ADD_MEDICAS
                row = indexPath.row - (4+[flightOccurencesArray count]);
                [superiorFlightOccurencesArray removeObjectAtIndex:indexPath.row - (4+[flightOccurencesArray count])];
            }
        }
        else if(indexPath.section == 2){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"];
            row = indexPath.row - 2;
            [desspecialServiceOccurencesArray removeObjectAtIndex:indexPath.row-2];
        }
        else if(indexPath.section == 5){
            sectionName = [appDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"];
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ADD_MISSING_DOC_OCC"];
            row = indexPath.row - 1;
            [documentsAddedArray removeObjectAtIndex:indexPath.row-1];
        }
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        [cellArr removeObjectAtIndex:row];
        
        if(self.leastIndexPath.row == indexPath.row && self.leastIndexPath.section == indexPath.section){
            self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        }
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        
        NSIndexPath *ip = [[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] firstObject];
        [self.ipArray removeObjectIdenticalTo:ip];
        
        
        [_overviewTableView beginUpdates];
        [_overviewTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_overviewTableView endUpdates];
        if (!ISiOS8) {
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        }
       // [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        
    }
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
