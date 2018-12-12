//
//  DutyFreeViewController.m
//  LATAM
//
//  Created by Vishnu on 12/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "DutyfreeViewController.h"
#import "OffsetCustomCell.h"
#import "SwitchCell.h"
#import "TextFieldNameCell.h"
#import "AddRowCell.h"
#import "TextTextCell.h"
#import "LabelComboObservationCell.h"
#import "ComboBoxTextCell.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"

@interface DutyfreeViewController ()
{
    NSMutableArray *missingItemsArray;
    NSMutableArray *reasonsArray;
    UITextField *currentTxtField;
    AppDelegate *appDel;
    NSMutableArray *groupArr;
    
    NSMutableArray *motivoArray;
}

@end

@implementation DutyfreeViewController
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


#pragma mark - Data Initialization

-(void)initializeData{
   
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    missingItemsArray = [[NSMutableArray alloc] init];
    reasonsArray = [[NSMutableArray alloc] init];
    
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    groupArr = [[NSMutableArray alloc]init];
    
    if(flightRoasterDraft != nil){
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        
        
        NSMutableDictionary *dict = [groupArr firstObject];
        if([dict objectForKey:@"name"]){
            switchValue = [[[dict objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"]] boolValue];
        }
        
        
        for(NSDictionary *groupDict in groupArr){
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                for(int i=0; i < [[[groupDict objectForKey:@"multiEvents"] objectForKey:rowName] count]; i++){
                    if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"REASON"]]){
                        [reasonsArray addObject:@"1"];
                    }
                    else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"]]){
                        [missingItemsArray addObject:@"1"];
                    }
                }
            }
        }
    }
    
    if ([groupArr count] == 0) {
        
        groupArr = [[NSMutableArray alloc]init];
        
        
        NSMutableDictionary *groupDict;
        
        NSMutableDictionary *reasonDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"REASON"],[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"], nil]];
        
        NSMutableDictionary *ventasDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] initWithObjects:reasonDictionary, nil],[[NSMutableArray alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"],[appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"], nil]];
        
        
        NSMutableDictionary *singleVentasDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"NO"],[[NSString alloc] initWithFormat:@""], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"],[appDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_VENTAS"] forKey:@"name"];
        [groupDict setObject:singleVentasDict forKey:@"singleEvents"];
        [groupDict setObject:ventasDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    [self configurePopovers];
    
}

#pragma mark - Popover Drop downs

-(void)configurePopovers{
    
    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    NSString *report = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
    
    NSString *section = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
    
    
    NSMutableDictionary *retDict = [LTGetDropDownvalue getDictForReportType:flightType FlightReport:report Section:section];
    
    motivoArray = [[NSMutableArray alloc] initWithArray:[[[retDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_VENTAS"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]] objectForKey:[appDel copyEnglishTextForKey:@"REASON"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ipArray = [[NSMutableArray alloc] init];
    super.tableView = _dutyfreeTableView;
    
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [LTSingleton getSharedSingletonInstance].isDutyIndexPathZero = YES;

    
    _headingLabel.textColor=kFontColor;
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headingLabel.text = [appDel copyTextForKey:@"Dutyfree"];

    CGRect frame = _headingLabel.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;//pass the cordinate which you want
    //_headingLabel.frame=CGRectMake(kxposition_NB_LAN_General,kyposition_NB_LAN_General,kwidth_headingLabel_NB_LAN_General,kheight_headingLabel_NB_LAN_General);
    _headingLabel.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    [_dutyfreeTableView setEditing:YES];
    self.headingLabel.text = [appDel copyTextForKey:@"Dutyfree"];
    [self initializeIndexPathArray];
    _dutyfreeTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

}

#pragma mark - Change Switch

-(void)switchChanged:(UISwitch *)sw{
    switchValue = !switchValue;
    if(!switchValue){
        [self clearMissingDetailsData];
    }
    else{
        [self clearMotivoData];
    }
    [self setContentInFormDictForView:sw];
    [_dutyfreeTableView reloadData];
    [self updateReportDictionary];
    
}

#pragma mark - Clearing Data Methods

-(void)clearMissingDetailsData{
    [missingItemsArray removeAllObjects];
    
    NSDictionary *flightRoasterDraft = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableArray *tempArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    
    
    NSMutableDictionary *reasonDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] init],[[NSString alloc] init], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"REASON"],[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"], nil]];
    
    [[[tempArr firstObject] objectForKey:@"multiEvents"] setObject:[[NSMutableArray alloc] initWithObjects:reasonDictionary, nil] forKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]];
    
    
    [[[[tempArr firstObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"]] removeAllObjects];
    
    [[[tempArr firstObject] objectForKey:@"singleEvents"] setObject:@"" forKey:[appDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]];
    if ([[[tempArr firstObject] objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]]) {
        [[[tempArr firstObject] objectForKey:@"singleEvents"] removeObjectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]];
    }
    
}

-(void)clearMotivoData{
    [reasonsArray removeAllObjects];
    NSDictionary *flightRoasterDraft = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableArray *tempArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    [[[tempArr firstObject] objectForKey:@"singleEvents"] removeObjectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]];
    //[[[[tempArr firstObject] objectForKey:@"singleEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]] removeAllObjects];
    
    [[[[[tempArr firstObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]] firstObject] setObject:@"" forKey:[appDel copyEnglishTextForKey:@"REASON"]];
    
    [[[[[tempArr firstObject] objectForKey:@"multiEvents"] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]] firstObject] setObject:@"" forKey:[appDel copyEnglishTextForKey:@"OBSERVATION"]];
    
}

# pragma mark - Dropdown delegate method

-(void)valueSelectedInPopover:(TestView *)testView{
    [self setContentInFormDictForView:testView];
    if(testView.typeOfDropDown == AlertDropDown){
        [_dutyfreeTableView reloadData];
    }
    [self updateReportDictionary];
    
}

#pragma mark - Form Saving Methods

-(NSString *)getContentInFormDictForView:(id)view
{
    NSString *value;
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VENTAS"];
    if(indexPath.row == 0){
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"];
    }
    else if(indexPath.row == 1){
        if(switchValue){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"];
        }
    }
    else{
        if(switchValue){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"];
            row = indexPath.row - 3;
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"REASON"];
            row = indexPath.row - 2;
        }
    }
    
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    if(indexPath.row == 0 || (indexPath.row == 1 && [view isKindOfClass:[UITextField class]])){
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        
        value = [eventDict objectForKey:rowName];
    }
    
    else if(indexPath.row == 1 && [view isKindOfClass:[TestView class]]){
        
        NSMutableDictionary *eventDict = [[[groupDict objectForKey:@"multiEvents"] objectForKey:rowName] firstObject];
        
        NSString *testViewValue = [eventDict objectForKey:((TestView *)view).key];
        if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"]]){
            value = testViewValue;
        }
        else if([testViewValue containsString:@"-1"])
            value = [testViewValue substringFromIndex:3];
        else
            value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
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
                    value = [testViewValue substringFromIndex:3];
                else
                    value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
            }
        }
        else
            value =  [cellDictionary objectForKey:((UITextField *)view).accessibilityIdentifier];
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
    
    sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VENTAS"];
    if(indexPath.row == 0){
        rowName = [appDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"];
    }
    else if(indexPath.row == 1){
        if(switchValue){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"];
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"];
        }
    }
    else{
        if(switchValue){
            rowName = [appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"];
            row = indexPath.row - 3;
        }
        else{
            rowName = [appDel copyEnglishTextForKey:@"REASON"];
            row = indexPath.row - 2;
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    
    if(indexPath.row == 0 || (indexPath.row == 1 && [view isKindOfClass:[UITextField class]])){
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
        
        if([view isKindOfClass:[UISwitch class]]){
            [eventDict setObject:((switchValue)? @"YES": @"NO")  forKey:rowName];
        }
        else if([view isKindOfClass:[UITextField class]]){
            if (![rowName isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]]) {
                [eventDict setObject:((UITextField *)view).text forKey:rowName];
            }
            
        }
        else if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"]]){
            [eventDict setObject:((TestView *)view).selectedValue  forKey:rowName];
        }
        else{
            [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:rowName];
        }
    }
    else if(indexPath.row == 1 && [view isKindOfClass:[TestView class]]){
        NSMutableDictionary *eventDict = [[[groupDict objectForKey:@"multiEvents"] objectForKey:rowName] firstObject];
        
        if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"]]){
            [eventDict setObject:((TestView *)view).selectedValue forKey:((TestView *)view).key];
        }
        else{
            [eventDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
        }
    }
    
    else{
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArray = [eventDict objectForKey:rowName];
        NSMutableDictionary *cellDict = [cellArray objectAtIndex:row];
        
        if([view isKindOfClass:[TestView class]])
            [cellDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
        else
            [cellDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
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
                int rowVal;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.dutyfreeTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.dutyfreeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]){
                        [[cell viewWithTag:TEXTFIELD_BEGIN_TAG] becomeFirstResponder];
                        isPrevFieldFound = YES;
                        break;
                    }
                    
                }
                if(isPrevFieldFound)
                    break;
            }
        }
        else{
            for(int section = cell.indexPath.section ;section<[self.dutyfreeTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.dutyfreeTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.dutyfreeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG]){
                        [[cell viewWithTag:TEXTFIELD_BEGIN_TAG] becomeFirstResponder];
                        isNextFieldFound = YES;
                        break;
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
    
    id refrence;
    if(ISiOS8)
        refrence = [[textField superview] superview];
    else
        refrence = [[[textField superview] superview] superview];
    
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    currentTxtField = textField;
    CGPoint pointInTable = [refrence convertPoint:textField.frame.origin toView:self.dutyfreeTableView];
    CGPoint contentOffset = self.dutyfreeTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.dutyfreeTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    id refrence;
    if(ISiOS8)
        refrence = [[textField superview] superview];
    else
        refrence = [[[textField superview] superview] superview];
    
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
    if ([refrence isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell = (UITableViewCell*)refrence;
        NSIndexPath *indexPath = [self.dutyfreeTableView indexPathForCell:cell];
        [self.dutyfreeTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
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
    
    textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    if([string length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendReport && textField.tag == MANDATORYTAG) {
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    if([textField.accessibilityIdentifier isEqualToString:[appDel copyEnglishTextForKey:@"AMOUNT"]]) {
        
        if(concatText.length > kDutyFreeAmountLength) {
            textField.text = [concatText substringToIndex:kDutyFreeAmountLength];
            return NO;
        }
        else if(![concatText validateNumeric]) {
            return NO;
        }
    }
    
    if(indexPath.row == 1 && concatText.length > kDutyFreeAmountLength) {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
    }
    
    if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    return YES;
}

#pragma mark - tableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(switchValue) {
        return 3 + [missingItemsArray count];
    }
    
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    
    static NSString *headingIdentifier = @"HeaderCell";
    static NSString *textFieldIdentifier = @"TextFieldNameCell";
    static NSString *twoTextIdentifer = @"TextTextCell";
    static NSString *switchIdentifier = @"SwitchCell";
    static NSString *labelComboObservationIdentifier = @"LabelComboObservationCell";
    OffsetCustomCell *cell;
    
    if(!switchValue){
        if(indexPath.row == 0){
            cell = (SwitchCell *)[self createCellForTableView:tableView withCellID:switchIdentifier];
            cell.leftLabel.text = [appDel copyTextForKey:@"GENERAL_VENTAS_DUTYFREE"];
            cell.indexPath = indexPath;
            switchValue = [[self getContentInFormDictForView:((SwitchCell *)cell).rightSwitch] boolValue];
            ((SwitchCell *)cell).rightSwitch.on = switchValue;
            
        }
        else{
            
            cell = (LabelComboObservationCell *)[self createCellForTableView:tableView withCellID:labelComboObservationIdentifier];
            cell.indexPath = indexPath;
            ((LabelComboObservationCell *)cell).leftLabel.attributedText = [[[appDel copyTextForKey:@"REASON"] stringByAppendingString:@"*"] mandatoryString];
            
            ((LabelComboObservationCell *)cell).reasonCombobox.delegate = self;
            ((LabelComboObservationCell *)cell).reasonCombobox.key = [appDel copyEnglishTextForKey:@"REASON"];
            ((LabelComboObservationCell *)cell).reasonCombobox.selectedTextField.text = [self getContentInFormDictForView:((LabelComboObservationCell *)cell).reasonCombobox];
            
            ((LabelComboObservationCell *)cell).reasonCombobox.dataSource = motivoArray;
            ((LabelComboObservationCell *)cell).reasonCombobox.selectedTextField.tag = MANDATORYTAG;
            
            ((LabelComboObservationCell *)cell).alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            ((LabelComboObservationCell *)cell).reasonLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            ((LabelComboObservationCell *)cell).alertComboView.typeOfDropDown = AlertDropDown;
            ((LabelComboObservationCell *)cell).alertComboView.selectedTextField.hidden = YES;
            ((LabelComboObservationCell *)cell).alertComboView.delegate = self;
            ((LabelComboObservationCell *)cell).alertComboView.selectedValue = [self getContentInFormDictForView:((LabelComboObservationCell *)cell).alertComboView];
            ((LabelComboObservationCell *)cell).alertComboView.notesView.text = [self getContentInFormDictForView:((LabelComboObservationCell *)cell).alertComboView];
            
            
            if([self getContentInFormDictForView:((LabelComboObservationCell *)cell).alertComboView] == NULL || [[self getContentInFormDictForView:((LabelComboObservationCell *)cell).alertComboView] isEqualToString:@""])
            {
                [((LabelComboObservationCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else{
                [((LabelComboObservationCell *)cell).commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            }
        }
    }
    else{
        if(indexPath.row == 0) {
            cell = (SwitchCell *)[self createCellForTableView:tableView withCellID:switchIdentifier];
            cell.leftLabel.text = [appDel copyTextForKey:@"GENERAL_VENTAS_DUTYFREE"];
            cell.indexPath = indexPath;
            switchValue = [[self getContentInFormDictForView:((SwitchCell *)cell).rightSwitch] boolValue];
            ((SwitchCell *)cell).rightSwitch.on = switchValue;
            
        }
        else if(indexPath.row == 1) {
            cell = [self createCellForTableView:tableView withCellID:textFieldIdentifier];
            cell.leftLabel.attributedText = [[[appDel copyTextForKey:@"GENERAL_MONTO_DE_VENTA"] stringByAppendingString:@"*"] mandatoryString];
            cell.indexPath = indexPath;
            ((TextFieldNameCell *)cell).rightTextTextField.tag = MANDATORYTAG;
            ((TextFieldNameCell *)cell).rightTextTextField.delegate = self;
            ((TextFieldNameCell *)cell).rightTextTextField.text = [self getContentInFormDictForView:((TextFieldNameCell *)cell).rightTextTextField];
            ((TextFieldNameCell *)cell).rightTextTextField.font = [UIFont fontWithName:KFontName size:14.0];

        }
        else if(indexPath.row == 2){
            cell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingIdentifier];
            ((AddRowCell *)cell).headingLbl.text = [appDel copyTextForKey:@"GENERAL_ADD_FALTANTES"];
        }
        else{
            cell = [self createCellForTableView:tableView withCellID:twoTextIdentifer];
            cell.indexPath = indexPath;
            ((TextTextCell *)cell).leftTextLabel.attributedText = [[[appDel copyTextForKey:@"CODIGO_PRODUCTO"] stringByAppendingString:@"*"] mandatoryString];
            ((TextTextCell *)cell).rightTextLabel.attributedText = [[[appDel copyTextForKey:@"AMOUNT"] stringByAppendingString:@"*"] mandatoryString];
            
            ((TextTextCell *)cell).productTextField.tag = MANDATORYTAG;
            ((TextTextCell *)cell).quantityTextField.tag = MANDATORYTAG;
            ((TextTextCell *)cell).quantityTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
            ((TextTextCell *)cell).productTextField.accessibilityIdentifier=[appDel copyEnglishTextForKey:@"CODIGO_PRODUCTO"];
            ((TextTextCell *)cell).quantityTextField.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            ((TextTextCell *)cell).quantityTextField.text = [self getContentInFormDictForView:((TextTextCell *)cell).quantityTextField];
            ((TextTextCell *)cell).productTextField.text = [self getContentInFormDictForView:((TextTextCell *)cell).productTextField];
        }
        
        
    }
    if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleInsert){
        //"add" cell
        [[cell controlButton] setImage:[UIImage imageNamed:@"add"]];
    }else if([self tableView:tableView editingStyleForRowAtIndexPath:indexPath]==UITableViewCellEditingStyleDelete){
        //normal cell
        [[cell controlButton] setImage:[UIImage imageNamed:@"remove"]];
    }
    
    
    cell.indexPath = indexPath;
    
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
    else if([cellID isEqualToString:@"TextTextCell"]){
        TextTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextTextCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        cell.productTextField.delegate = self;
        cell.quantityTextField.delegate = self;
        cell.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
        return cell;
    }
    else if([cellID isEqualToString:@"TextFieldNameCell"]){
        TextFieldNameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextFieldNameCell" owner:self options:nil];
            cell = (TextFieldNameCell *)[topLevelObjects objectAtIndex:0];
            cell.rightTextTextField.keyboardType = UIKeyboardTypeNumberPad;
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"ComboBoxTextCell"]){
        ComboBoxTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboBoxTextCell" owner:self options:nil];
            cell = (ComboBoxTextCell *)[topLevelObjects objectAtIndex:0];
            cell.sideView.hidden = YES;
            
        }
        return cell;
    }
    
    else if([cellID isEqualToString:@"SwitchCell"]){
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
    else{
        LabelComboObservationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LabelComboObservationCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
    if(switchValue){
        if(indexPath.row == 2){
            style = UITableViewCellEditingStyleInsert;
        }
        else if(indexPath.row > 2){
            style = UITableViewCellEditingStyleDelete;
        }
    }
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(switchValue){
        if(indexPath.row == 0 || indexPath.row == 1){
            return NO;
        }
    }
    else{
        return NO;
    }
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}





- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    NSString *sectionTitle;
    sectionTitle = [appDel copyTextForKey:@"GENERAL_VENTAS"];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(switchValue){
        if(indexPath.row == 2){
            // return 64;
            return 44;
        }
        else if(indexPath.row >2){
            // return 69;
            return 44;
            
        }
    }
    else{
        //return 69;
        return 44;
        
    }
    //    if(indexPath.row == 0) return 74;
    //return 69;
    return 44;
    
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [currentTxtField resignFirstResponder];
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    NSIndexPath *modifiedIndexpath;
    
    sectionName = [appDel copyEnglishTextForKey:@"GENERAL_VENTAS"];
    
    if(switchValue){
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"];
        if(editingStyle == UITableViewCellEditingStyleInsert){
            [missingItemsArray addObject:[NSNumber numberWithInt:[missingItemsArray count]+1]];
            
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            [cellArr insertObject:cellDict atIndex:0];
            
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
            
            [_dutyfreeTableView beginUpdates];
            [_dutyfreeTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_dutyfreeTableView endUpdates];
            
            NSArray *t= [tableView visibleCells];
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
            NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
            
            
            if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
                [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            
            
        }
        else if(editingStyle == UITableViewCellEditingStyleDelete){
            row = indexPath.row - 3;
            [missingItemsArray removeObjectAtIndex:indexPath.row-3];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            [cellArr removeObjectAtIndex:row];
            
            if(self.leastIndexPath.row == indexPath.row && self.leastIndexPath.section == indexPath.section){
                self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            }
            
            
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.hidden = YES;
            
            NSIndexPath *ip = [[self.ipArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"row == %d && section == %d",indexPath.row,indexPath.section]] firstObject];
            [self.ipArray removeObjectIdenticalTo:ip];
            
            [_dutyfreeTableView beginUpdates];
            [_dutyfreeTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_dutyfreeTableView endUpdates];
           
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        }
        
    }
    else{
        
        rowName =[appDel copyEnglishTextForKey:@"REASON"];
        if(editingStyle == UITableViewCellEditingStyleInsert){
            [reasonsArray addObject:[NSNumber numberWithInt:[reasonsArray count]+1]];
            
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            [cellArr insertObject:cellDict atIndex:0];
            
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
            
            
            [_dutyfreeTableView beginUpdates];
            [_dutyfreeTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_dutyfreeTableView endUpdates];
            
            NSArray *t= [tableView visibleCells];
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            
            NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
            
            
            if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
                [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            
            
        }
        else if(editingStyle == UITableViewCellEditingStyleDelete){
            row = indexPath.row - 2;
            [reasonsArray removeObjectAtIndex:indexPath.row-2];
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            [cellArr removeObjectAtIndex:row];
            
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
            
            [_dutyfreeTableView beginUpdates];
            [_dutyfreeTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_dutyfreeTableView endUpdates];
            
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            
        }
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
