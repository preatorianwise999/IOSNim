//
//  DOMBoardingViewController.m
//  Nimbus2
//
//  Created by Priyanka on 07/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "AppDelegate.h"
#import "DOMBoardingViewController.h"
#import "OffsetCustomCell.h"
#import "DropDownCell.h"
#import "SwitchCell.h"
#import "AddRowCell.h"
#import "OnlyDropDownCell.h"
#import "NSString+Validation.h"
#import "AlertUtils.h"
//#import "GapSwitchCell.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"
#define customOffset 22;


@interface DOMBoardingViewController ()
{
    NSDictionary *sourceDictionary;
    NSArray *sectionArray;
    NSMutableArray *motivoArray;
    NSMutableArray *actionsArray;
    BOOL greaterThanOneHour;
    AppDelegate *appDel;
    NSMutableArray *groupArr;
    
    NSMutableArray *actionsDropDown;
    NSMutableArray *reasonsDropDown;
    
    Boolean stadoSelect;
    Boolean stadoMotivo;
    Boolean stadoAction;
    NSInteger contMotivo;
    NSInteger contAccion;
    Boolean listMotivo;
    Boolean listAction;
    Boolean stadoIngP;
}
@end

@implementation DOMBoardingViewController

@synthesize switchValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeData];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.ipArray = [[NSMutableArray alloc] init];
    self.tableView = _boardingTableView;
    contAccion = 0;
    contMotivo = 0;
    listAction = true;
    listMotivo = true;
    
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    _headingLabel.textColor=kFontColor;
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headingLabel.text = [appDel copyTextForKey:@"Boarding"];

    CGRect frame = _headingLabel.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    _headingLabel.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    

    
    sectionArray = [[NSArray alloc] initWithObjects:[appDel copyTextForKey:@"GENERAL_EMBARQUE_INFO"],[appDel copyTextForKey:@"GENERAL_ATRASOS"], nil];
    sourceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_HORA_MINIMA"],[appDel copyTextForKey:@"GENERAL_HORA_PUERTAS"], nil],[NSNumber numberWithInt:0],[NSArray arrayWithObjects:[appDel copyTextForKey:@"GENERAL_HUBRO"],[appDel copyTextForKey:@"GENERAL_TIEMPO"], nil],[NSNumber numberWithInt:1], nil];
    [_boardingTableView setEditing:YES];
    self.headingLabel.text = [appDel copyTextForKey:@"Boarding"];
    _headingLabel.textColor=kFontColor;
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];

    [self initializeIndexPathArray];
    _boardingTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

    
}

-(void)initializeData{

   
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    greaterThanOneHour = NO;
    motivoArray = [[NSMutableArray alloc] init];
    actionsArray = [[NSMutableArray alloc] init];
    switchValue = NO;

    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    groupArr = [[NSMutableArray alloc]init];
    if(flightRoasterDraft != nil)
    {
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        for(NSDictionary *groupDict in groupArr)
        {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]]){
                switchValue = [[[groupDict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_HUBRO"]] boolValue];
                NSString *timeString =  [[groupDict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_TIEMPO"]];
                if([timeString isEqualToString:@""]){
                    
                }
                else{
                    greaterThanOneHour = [self isGreaterThanOneHour:timeString];
                }
            }
            
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys])
            {
                for(int i=0; i < [[[groupDict objectForKey:@"multiEvents"] objectForKey:rowName] count]; i++)
                {
                    
                    
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"]] )
                        {
                            [actionsArray addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"]] )
                        {
                            [motivoArray addObject:@"1"];
                        }
                    }
                }
            }
        }
    }
    
    
    //    groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    
    if ([groupArr count] == 0) {
        
        groupArr = [[NSMutableArray alloc]init];
        
        
        NSMutableDictionary *groupDict;
        
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_HORA_MINIMA"],[appDel copyEnglishTextForKey:@"GENERAL_HORA_PUERTAS"], nil]];
        
        NSMutableDictionary *atrasosDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init],[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"],[appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"], nil]];
        
        NSMutableDictionary *singleAtrasosDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"NO"],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_HUBRO"],[appDel copyEnglishTextForKey:@"GENERAL_TIEMPO"], nil]];
        
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"] forKey:@"name"];
        [groupDict setObject:infoDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"] forKey:@"name"];
        [groupDict setObject:atrasosDict forKey:@"multiEvents"];
        [groupDict setObject:singleAtrasosDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
    }

    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
    [self configurePopovers];
    
}


-(void)configurePopovers{
    
    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    NSString *report = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
    
    NSString *section = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
    
    NSString *group = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
    
    NSMutableDictionary *retDict = [LTGetDropDownvalue getDictForReportType:flightType FlightReport:report Section:section];
    
    actionsDropDown = [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"]] objectForKey:[appDel copyEnglishTextForKey:@"ACTIONS"]];
    reasonsDropDown=  [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"]] objectForKey:[appDel copyEnglishTextForKey:@"REASON"]];
    
}

#pragma mark - Form Saving Methods

-(NSString *)getContentInFormDictForView:(id)view
{
    NSString *value;
    // NSIndexPath *indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    if(indexPath.section == 0){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"];
        
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HORA_MINIMA"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HORA_PUERTAS"];
        }
        row = indexPath.row;
    }
    else if(indexPath.section == 1){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HUBRO"];
            row = indexPath.row;
        }
        else if(indexPath.row == 1){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIEMPO"];
            row = indexPath.row;
        }
    } else if(indexPath.section == 5){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        if(stadoMotivo){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"];
            row = 0;
        }else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"];
            row = (indexPath.row)-(([motivoArray count] - 1) + 3);
            if (row < 0)
            {
                row = (row*-1);
            }
        }
        
    }else if(indexPath.section == 6){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        if(stadoAction){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"];
            row = 0;
        }else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"];
            row = (indexPath.row)-(([actionsArray count] - 1) + 4);
            if (row < 0)
            {
                row = (row*-1);
            }
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    if(indexPath.section == 0 || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1) )){
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        value =  [eventDict objectForKey:rowName];
        if([view isKindOfClass:[TestView class]] && ((TestView *)view).typeOfDropDown != DateDropDown)
        {
            if(value)
            {
                if([value containsString:@"-1"])
                {
                    value = [value substringFromIndex:3];
                }
                else{
                    value = [((TestView *)view).dataSource objectAtIndex:[value intValue] - 1];
                }
            }
        }
        return value;
    }
    
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
    NSArray *cellArray = [eventDict objectForKey:rowName];
    NSMutableDictionary *cellDict =  [cellArray objectAtIndex:row];
    
    
    NSString *testViewValue = [cellDict objectForKey:((TestView *)view).key];
    if(testViewValue)
    {
        if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]])
            value = testViewValue;
        else if([testViewValue containsString:@"-1"])
        {
            NSString *other = [testViewValue substringFromIndex:3];
            
            value = [[other componentsSeparatedByString:@"||"] firstObject];
        }
        else
            value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
    }
    
    return value;
    
}

-(void)setContentInFormDictForView:(id)view
{
    // NSIndexPath *indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
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
    
    if(indexPath.section == 0){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"];
        
        if(indexPath.row == 0){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HORA_MINIMA"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HORA_PUERTAS"];
        }
        row = indexPath.row;
    }
    else if(indexPath.section == 1) {
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        if(indexPath.row == 0) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_HUBRO"];
            row = indexPath.row;
        }
        else if(indexPath.row == 1) {
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_TIEMPO"];
            row = indexPath.row;
        }
    }
    else if(indexPath.section == 5){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"];
        row = (indexPath.row)- (3+(([motivoArray count])-1));
        if (row < 0)
        {
            row = (row*-1);
        }
        
    }else if(indexPath.section == 6){
        sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"];
        
        row = (indexPath.row) - (4+(([actionsArray count])-1));
        if (row < 0)
        {
            row = (row*-1);
        }
        
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    if(indexPath.section == 0 || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1) )){
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        
        if([view isKindOfClass:[UISwitch class]]){
            [eventDict setObject:((switchValue)? @"YES": @"NO")  forKey:rowName];
            contAccion = 0;
            contMotivo = 0;
            listAction = true;
            listMotivo = true;
        }
        else if([view isKindOfClass:[TestView class]]){
            [eventDict setObject:((TestView *)view).selectedValue forKey:rowName];
        }
        else{
            [eventDict setObject:((UITextField *)view).text forKey:rowName];
        }
    }
    
    else {
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArray = [eventDict objectForKey:rowName];
        if (row >= [cellArray count]) {//prevent crash of object of index==number of rows
            DLog(@"failed to calculate row number");
            return;
        }
        NSMutableDictionary *cellDict = [cellArray objectAtIndex:row];
        [cellDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
    }

    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}


#pragma mark - switch delegate

-(void)switchChanged:(UISwitch *)sw{
    switchValue = !switchValue;
    if(!switchValue){
        [self clearFormValues];
    }
    [self setContentInFormDictForView:sw];
    [LTSingleton getSharedSingletonInstance].isDataChanged=YES;
    [_boardingTableView reloadData];

    [self initializeIndexPathArray];
}

-(void)clearFormValues {
    [motivoArray removeAllObjects];
    [actionsArray removeAllObjects];
    
    greaterThanOneHour = NO;

    NSDictionary *flightRoasterDraft = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableArray *tempArr;// = [[NSMutableArray alloc]init];
    if(flightRoasterDraft){
        tempArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        [[[tempArr lastObject] objectForKey:@"singleEvents"] setObject:@"" forKey:[appDel copyEnglishTextForKey:@"GENERAL_TIEMPO"]];
        [[[[tempArr lastObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"]] removeAllObjects];
        [[[[tempArr lastObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"]] removeAllObjects];
        
    }
    
    
}

-(void)clearActionsForm{
    [actionsArray removeAllObjects];

    NSDictionary *flightRoasterDraft = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableArray *tempArr ;//= [[NSMutableArray alloc]init];
    tempArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    [[[[tempArr lastObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"]] removeAllObjects];
}

#pragma mark - dropdown delegate

-(BOOL)isGreaterThanOneHour:(NSString *)timeString{
    NSString *val = [timeString substringWithRange:NSMakeRange(0, 2)];
    NSString *fullString = [val stringByAppendingFormat:@".%@",[timeString substringWithRange:NSMakeRange(3, 2)]];
    
    float hour = [fullString floatValue];
    return (hour > 1.0f);
}

-(void)valueSelectedInPopover:(TestView *)testView{
    
    // NSIndexPath *ip = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    NSIndexPath *ip;
    if(ISiOS8)
        ip = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        ip = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    if(ip.section == 1 && ip.row == 1){
        greaterThanOneHour = [self isGreaterThanOneHour:[testView selectedValue]];
        [self setContentInFormDictForView:testView];
        [_boardingTableView reloadData];
        
        if(greaterThanOneHour){
            
            NSArray *t= [_boardingTableView visibleCells];
            NSIndexPath *ip = [NSIndexPath indexPathForItem:3+[motivoArray count] inSection:1];
            if ([actionsArray count] == 0) {
                [self tableView:self.boardingTableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:ip];
            }
            NSIndexPath *dest = [NSIndexPath indexPathForItem:3+[motivoArray count]+[actionsArray count] inSection:1];
            
            NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",ip.row,ip.section]];
            
            
            if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == ip.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == ip.section)){
                [_boardingTableView scrollToRowAtIndexPath:dest atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        else{
            [self clearActionsForm];
        }
        
    }
    else{
        [self setContentInFormDictForView:testView];
    }
    //    if([LTSingleton getSharedSingletonInstance].sendReport){

    [self updateReportDictionary];
    //    }
    
    [LTSingleton getSharedSingletonInstance].isDataChanged=YES;
}



# pragma mark - tableview methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2;
    }
    else{
        if(switchValue){
            if(greaterThanOneHour)  return 4 + [motivoArray count] + [actionsArray count];
            return 3 + [motivoArray count] ;
        }
        return 1;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0)
        return NO;
    if(indexPath.row == 0 || indexPath.row == 1){
        return NO;
    }
    else{
        return YES;
    }
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    static NSString *DropDownIdentifier = @"DropDownCell";
    static NSString *switchIdentifier = @"SwitchCell";
    static NSString *headingIdentifier = @"HeaderCell";
    static NSString *onlyDropDownIdentifier = @"OnlyDropDownCell";
    
    AddRowCell *headingCell;
    OffsetCustomCell *cell;
    OnlyDropDownCell *onlyDropDownCell;
    
    if(indexPath.section == 0) {
        cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:DropDownIdentifier];
        //cell.leftLabel.attributedText = [[[[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row] stringByAppendingString:@"*"] mandatoryString] ;
        cell.indexPath = indexPath;
        ((DropDownCell *)cell).comboView.delegate = self;
        ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
        ((DropDownCell *)cell).comboView.selectedValue = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
        //((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
        if(indexPath.row == 0) {
            cell.leftLabel.text = [[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row];
        }
        else{
            cell.leftLabel.attributedText = [[[[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row] stringByAppendingString:@"*"] mandatoryString] ;
            ((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            
        }
    }
    else{
        if(indexPath.row == 0){
            cell = (SwitchCell *)[self createCellForTableView:tableView withCellID:switchIdentifier];
            cell.indexPath = indexPath;
            cell.leftLabel.text = [[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row];
            
            ((SwitchCell *)cell).rightSwitch.On = switchValue;
            
            cell.indexPath = indexPath;
        }
        else if(indexPath.row == 1){
            cell = (DropDownCell *)[self createCellForTableView:tableView withCellID:DropDownIdentifier];
            cell.leftLabel.attributedText = [[[[sourceDictionary objectForKey:[NSNumber numberWithInt:indexPath.section]] objectAtIndex:indexPath.row] stringByAppendingString:@"*"] mandatoryString] ;
            
            cell.indexPath = indexPath;
            ((DropDownCell *)cell).comboView.delegate = self;
            ((DropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            ((DropDownCell *)cell).comboView.selectedValue = [self getContentInFormDictForView:((DropDownCell *)cell).comboView];
            ((DropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
        }
        else if(indexPath.row == 2){
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_REASONS"];//@"Añadir Motivo de atraso";
            cell = headingCell;
            
            
        }
        else if(indexPath.row == 3+[motivoArray count]){
            if(greaterThanOneHour){
                headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
                headingCell.headingLbl.attributedText =[[[appDel copyTextForKey:@"GENERAL_ADD_ACTIONS"] stringByAppendingString:@"*"] mandatoryString];// @"Añadir Acciones Realizadas";
                cell = headingCell;
            }
        }
        else if(indexPath.row > 2 && indexPath.row < 3+[motivoArray count]){

            stadoSelect = true;
            stadoMotivo = true;
            NSInteger row=0;
            
            row = indexPath.row + ([motivoArray count]-1);
            
            if (row < 0)
            {
                row = (row*-1);
            }
            
            
            NSIndexPath *changedRow = [NSIndexPath
                                       indexPathForRow:row             // Use the new row
                                       inSection:5];
            
            
            
            if (contMotivo < [motivoArray count]){
                
                if (listMotivo){
                    
                    row = indexPath.row;
                    
                    if (row < 0)
                    {
                        row = (row*-1);
                    }
                    
                    changedRow = [NSIndexPath
                                  indexPathForRow:row             // Use the new row
                                  inSection:5];
                    stadoMotivo =false;
                    
                    if (contMotivo == [motivoArray count]-1){
                        listMotivo = false;
                    }
                    contMotivo++;
                }
            }
            
            if (!listMotivo && stadoIngP){
                
                row = indexPath.row;
                
                if (row < 0)
                {
                    row = (row*-1);
                }
                
                changedRow = [NSIndexPath
                              indexPathForRow:row             // Use the new row
                              inSection:5];
                stadoMotivo =false;
            }
            stadoIngP= true;

            
            onlyDropDownCell = (OnlyDropDownCell *)[self createCellForTableView:tableView withCellID:onlyDropDownIdentifier];
            cell = onlyDropDownCell;
            cell.indexPath = changedRow;
            ((OnlyDropDownCell *)cell).comboView.dataSource = reasonsDropDown;
            ((OnlyDropDownCell *)cell).motivoLabel.attributedText = [[[appDel copyTextForKey:@"REASON"] stringByAppendingString:@"*"] mandatoryString];
            ((OnlyDropDownCell *)cell).comboView.delegate = self;
            ((OnlyDropDownCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            
            ((OnlyDropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"REASON"];
            
            ((OnlyDropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((OnlyDropDownCell *)cell).comboView];
            ((OnlyDropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            
        }
        else if(indexPath.row > 3 +[motivoArray count] && greaterThanOneHour){

            stadoSelect = false;
            stadoAction = true;
            NSInteger row=0;
            
            row = ((indexPath.row-[motivoArray count])+[actionsArray count])-1;
            
            if (row < 0)
            {
                row = (row*-1);
            }
            
            NSIndexPath *changedRow = [NSIndexPath
                                       indexPathForRow:row             // Use the new row
                                       inSection:6];
            
            
            
            if (contAccion < [actionsArray count]){
                
                if (listAction){
                    
                    row = indexPath.row-[motivoArray count];
                    
                    if (row < 0)
                    {
                        row = (row*-1);
                    }
                    
                    changedRow = [NSIndexPath
                                  indexPathForRow:row              // Use the new row
                                  inSection:6];
                    stadoAction =false;
                    
                    
                    if (contAccion == [actionsArray count]-1){
                        listAction = false;
                    }
                    contAccion++;
                }
            }
            
            if (!listAction && stadoIngP){
                
                row = indexPath.row-[motivoArray count];
                
                if (row < 0)
                {
                    row = (row*-1);
                }
                
                changedRow = [NSIndexPath
                              indexPathForRow:row              // Use the new row
                              inSection:6];
                stadoAction =false;
                
            }
            stadoIngP= true;
            
            
            onlyDropDownCell = (OnlyDropDownCell *)[self createCellForTableView:tableView withCellID:onlyDropDownIdentifier];
            cell = onlyDropDownCell;
            cell.indexPath = changedRow;
            ((OnlyDropDownCell *)cell).comboView.dataSource = actionsDropDown;
            ((OnlyDropDownCell *)cell).motivoLabel.attributedText = [[[appDel copyTextForKey:@"ACTIONS"] stringByAppendingString:@"*"] mandatoryString];
            ((OnlyDropDownCell *)cell).comboView.delegate = self;
            ((OnlyDropDownCell *)cell).comboView.key = [appDel copyEnglishTextForKey:@"ACTIONS"];
            ((OnlyDropDownCell *)cell).comboView.selectedTextField.text = [self getContentInFormDictForView:((OnlyDropDownCell *)cell).comboView];
            ((OnlyDropDownCell *)cell).comboView.selectedTextField.tag = MANDATORYTAG;
            ((OnlyDropDownCell *)cell).comboView.typeOfDropDown = OtherDropDown;
            
        }
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
        NSLog(@"ID:%@",self.leastIndexPath);
    }
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
       // return 69;
        return 44;
    }
    else{
        if(indexPath.row == 2 || indexPath.row == 3+[motivoArray count]){
           // return 64;
            return 44;

        }
        //return 69;
        return 44;

    }
}

- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID
{
    
    if([cellID isEqualToString:@"HeaderCell"])
    {
        AddRowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"DropDownCell"]){
        DropDownCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.comboView.typeOfDropDown = DateDropDown;
            cell.comboView.dateHeaderTitle  = [appDel copyTextForKey:@"DATE_Time"];
            
            CGRect fr = cell.comboView.frame;
            fr.origin.x+= customOffset;
            cell.comboView.frame = fr;
            
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"OnlyDropDownCell"]){

        OnlyDropDownCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OnlyDropDownCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            CGRect fr = cell.comboView.frame;
            fr.size.width += customOffset;
            fr.size.width -= 4;
            cell.comboView.frame = fr;
            
            
        }
        return cell;
    }
    else{
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            CGRect fr = cell.rightSwitch.frame;
            fr.origin.x+= customOffset;
            cell.rightSwitch.frame = fr;
            cell.rightSwitch.onTintColor = [UIColor colorWithRed:17/255.0 green:84/255.0 blue:111/255.0 alpha:1.0];
            [cell.rightSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
        
    }
    return nil;//nimbus2 addition
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if(indexPath.section == 1){
        if(indexPath.row ==2 || indexPath.row == 3+[motivoArray count]){
            style = UITableViewCellEditingStyleInsert;
        }
        else if((indexPath.row > 2 && indexPath.row < 3+[motivoArray count]) || indexPath.row > 3+[motivoArray count]){
            style = UITableViewCellEditingStyleDelete;
        }
    }
   
    
    return style;
}

//
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
//           return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSIndexPath *modifiedIndexpath;
    stadoIngP = false;
    
    sectionName = [appDel copyEnglishTextForKey:@"GENERAL_ATRASOS"];
    
    @try {
        if(editingStyle == UITableViewCellEditingStyleInsert){
            if(indexPath.row == 2){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"];
                //modifiedIndexpath = [NSIndexPath indexPathForItem:[motivoArray count]+3 inSection:1];
                [motivoArray addObject:[NSNumber numberWithInt:[motivoArray count]+1]];
            }
            else if(indexPath.row == 3+[motivoArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"];
                //modifiedIndexpath = [NSIndexPath indexPathForItem:[motivoArray count]+[actionsArray count]+4 inSection:1];
                [actionsArray addObject:[NSNumber numberWithInt:[actionsArray count]+1]];
            }
            
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            
            
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
            }
            if(indexPath.row == 2) {
                
                if ([motivoArray count]-1 == 0){
                    
                    [cellArr insertObject:cellDict atIndex:0];
                }else{
                    
                    [cellArr insertObject:cellDict atIndex:0];
                }
                
            }else if(indexPath.row == 3 + [motivoArray count]) {
                if ([actionsArray count]-1 == 0){
                    
                    [cellArr insertObject:cellDict atIndex:0];
                }else{
                    
                    [cellArr insertObject:cellDict atIndex:0];
                }
                
            }
            
            //        [cellArr addObject:cellDict];

            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
            
            [_boardingTableView beginUpdates];
            [_boardingTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_boardingTableView endUpdates];
            
            
            NSArray *t= [tableView visibleCells];
            if (!ISiOS8) {
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
            }
            //        if([LTSingleton getSharedSingletonInstance].sendReport){
           [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
            //        }
            
            NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
            
            
            if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
                [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            
        }
        else if(editingStyle == UITableViewCellEditingStyleDelete){
            if(indexPath.row > 2 && indexPath.row < 3+[motivoArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_MOTIVO"];
                row = indexPath.row - 3;
                [motivoArray removeObjectAtIndex:indexPath.row - 3];
            }
            else if(indexPath.row > 3+[motivoArray count]){
                rowName = [appDel copyEnglishTextForKey:@"GENERAL_ACCIONES"];
                row = indexPath.row - (4+[motivoArray count]);
                if ([actionsArray count] == 1) {

                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"ALERT_CANNOT_DELETE"]];
                    return;
                }
                [actionsArray removeObjectAtIndex:indexPath.row - (4+[motivoArray count])];
            }
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            [cellArr removeObjectAtIndex:row];

            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.hidden = YES;

            if(self.leastIndexPath.row == indexPath.row && self.leastIndexPath.section == indexPath.section){
                self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            }
            
            NSIndexPath *ip = [[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] firstObject];
            [self.ipArray removeObjectIdenticalTo:ip];
            
            [_boardingTableView beginUpdates];
            [_boardingTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_boardingTableView endUpdates];
            
            
            
            if (!ISiOS8) {
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
            }
            
            
            //        if([LTSingleton getSharedSingletonInstance].sendReport){
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self updateReportDictionary];
            //            });
            
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
            //        }
            
        }
    }
    @catch (NSException *exception) {
        DLog(@"Exception Handled==%@",exception.description);
        [_boardingTableView reloadData];
    }
    
    
    
    
}


@end
