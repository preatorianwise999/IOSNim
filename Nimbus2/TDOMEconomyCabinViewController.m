//
//  TDOMEconomyCabinViewController.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TDOMEconomyCabinViewController.h"
#import "AddRowCell.h"
#import "OtherTextCamera.h"
#import "ComboText.h"
#import "ComboNumTextText.h"
#import "NSString+Validation.h"

//#import "DatabaseOperations.h" //Added pavan
#import "CabinLabelComboObservationCell.h"

#import "LTGetDropDownvalue.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"

@interface TDOMEconomyCabinViewController ()<UITextFieldDelegate,PopoverDelegate,ComboNumTextTextDelegate>
{
    UITextField *currentTxtField;
    NSArray *arr;
    NSMutableArray *groupArr;
    AppDelegate *appDel;
    NSDictionary *dropDownDict;
}

@property(nonatomic,weak) IBOutlet UITableView *cabinTableView;
@property(nonatomic,weak) IBOutlet UILabel *headlingLbl;

@end

@implementation TDOMEconomyCabinViewController
@synthesize bathroomsArr, galleyArr, cabinArr,faultySeatArr,tempratureArr;

#pragma mark - View Life Cycle Methods

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
    self.tableView = self.cabinTableView;
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _headlingLbl.textColor=kFontColor;
    [_headlingLbl setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    CGRect frame = _headlingLbl.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    _headlingLbl.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);

    [self.cabinTableView setEditing:YES animated:YES];
    [self initializeIndexPathArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Internal Methods

//Initialize data esp group array and drop down dictionary
#pragma mark - Data Initialization

-(void)initializeData{
    self.ipArray = [[NSMutableArray alloc] init];
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    bathroomsArr            = [[NSMutableArray alloc] init];
    galleyArr               = [[NSMutableArray alloc] init];
    cabinArr                = [[NSMutableArray alloc] init];
    faultySeatArr           = [[NSMutableArray alloc] init];
    tempratureArr           = [[NSMutableArray alloc] init];
    
    
    self.headlingLbl.text = [appDel copyTextForKey:@"CABIN"];
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    groupArr = [[NSMutableArray alloc]init];
    if(flightRoasterDraft != nil)
    {
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        for(NSDictionary *groupDict in groupArr)
        {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys])
            {
                for(NSDictionary *rowDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:rowName])
                {
                    DLog(@"%@",rowDict);
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"TOILETS"]] )
                        {
                            [bathroomsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"GALLEY"]] )
                        {
                            [galleyArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"CABIN"]] )
                        {
                            [cabinArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"TEMPERATURE"]] )
                        {
                            [tempratureArr addObject:@"1"];
                        }
                    }
                    else
                    {
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"]] )
                        {
                            [faultySeatArr addObject:@"1"];
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    //Create the main form dictionary
    
    if ([groupArr count] == 0 ) {
        
        groupArr = [[NSMutableArray alloc]init];
        
        NSMutableDictionary *groupDict;
        
        NSMutableDictionary *apvDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], [[NSMutableArray alloc] init],[[NSMutableArray alloc] init], nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"TOILETS"],[appDel copyEnglishTextForKey:@"GALLEY"],[appDel copyEnglishTextForKey:@"CABIN"],[appDel copyEnglishTextForKey:@"TEMPERATURE"], nil]];
        
        NSMutableDictionary *cateringDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"] forKey:@"name"];
        [groupDict setObject:apvDict forKey:@"multiEvents"];
        
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"] forKey:@"name"];
        [groupDict setObject:cateringDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    NSDictionary *flightRoaster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    NSString *type = [flightRoaster objectForKey:@"flightReportType"];
    NSString *report = [[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"name"];
    NSString *section = [[[[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"name"];
    
    
    dropDownDict = [LTGetDropDownvalue getDictForReportType:type FlightReport:report Section:section];
}

-(NSArray *)getDropDownDataForGroup:(NSString *)group event:(NSString *)event content:(NSString *)content
{
    return [[[dropDownDict objectForKey:[appDel copyEnglishTextForKey:group]]objectForKey:[appDel copyEnglishTextForKey:event]] objectForKey:[appDel copyEnglishTextForKey:content]];
}
#pragma mark - Keyboard Navigation Methods
//Display (prev, next) buttons as a tool bar on the top of keyboard

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

//Navigation between prev and next text field on the form

#pragma mark - Navigate Field for Segment Control

-(void)navigateField:(UISegmentedControl *)segControl
{
    OffsetCustomCell *cell = ((OffsetCustomCell *)([[[currentTxtField superview] superview] superview]));
    id view;
    //Navigating within the cell
    if(segControl.selectedSegmentIndex == 0)
    {
        view = [cell viewWithTag:currentTxtField.tag - 1];
    }
    else
    {
        view = [cell viewWithTag:currentTxtField.tag + 1];
    }
    //Navigating among other cells
    if(view == nil)
    {
        //Previous button selected
        if(segControl.selectedSegmentIndex == 0)
        {
            for(int section = cell.indexPath.section ;section >= 0;section--)
            {
                BOOL isPrevFieldFound = NO;
                int rowVal;
                rowVal = (section == cell.indexPath.section) ? rowVal = cell.indexPath.row - 1:[self.tableView numberOfRowsInSection:section] - 1;
                for(int row = rowVal;row >= 0;row--)
                {
                    cell = (OffsetCustomCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG])
                    {
                        [[cell viewWithTag:TEXTFIELD_BEGIN_TAG] becomeFirstResponder];
                        isPrevFieldFound = YES;
                        break;
                    }
                    
                }
                if(isPrevFieldFound)
                    break;
            }
            
            
        }
        //Next button selected
        else
        {
            for(int section = cell.indexPath.section ;section < [self.tableView numberOfSections];section++)
            {
                BOOL isNextFieldFound = NO;
                int rowVal;
                rowVal = (section == cell.indexPath.section) ? rowVal = cell.indexPath.row + 1:0;
                for(int row = rowVal;row < [self.tableView numberOfRowsInSection:section];row++)
                {
                    cell = (OffsetCustomCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    if([cell viewWithTag:TEXTFIELD_BEGIN_TAG])
                    {
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
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}

#pragma mark - Form Data Storage Methods

//Get the form elements from the dictionary
-(NSString *)getContentInFormDictForView:(id)view
{
    NSString *value;
    NSIndexPath *indexPath ;
    
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[view superview] superview] superview]).indexPath;
    
    int row=0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    if (indexPath.section == 0)
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"];
        if(indexPath.row <= bathroomsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"TOILETS"];
            row = indexPath.row;
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"GALLEY"];
            row = indexPath.row - ( bathroomsArr.count + 1 );
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + cabinArr.count + 2)
        {
            rowName = [appDel copyEnglishTextForKey:@"CABIN"];
            row = indexPath.row - (bathroomsArr.count + galleyArr.count + 2);
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + cabinArr.count + 3)
        {
            rowName = [appDel copyEnglishTextForKey:@"TEMPERATURE"];
            row = indexPath.row - (bathroomsArr.count + galleyArr.count + cabinArr.count + 2);
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
            row = 0 ;
        }
    }
    else
    {
        sectionName = [appDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"];
        
        if(indexPath.row <= faultySeatArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
            row = indexPath.row;
        }else {
            rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
            row = indexPath.row;
            
        }
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    NSMutableDictionary *cellDict;
    {
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        if([cellArr count]>0) {
            cellDict = [cellArr objectAtIndex:row - 1];
        }
    }
    
    if([view isKindOfClass:[TestView class]])
    {
        NSString *testViewValue = [cellDict objectForKey:((TestView *)view).key];
        if(testViewValue)
        {
            
            if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]] || [((TestView *)view).key isEqualToString:@"CAMERA"])
                value = [testViewValue lastPathComponent];
            else if([testViewValue containsString:@"-1"]){
                NSString *other = [testViewValue substringFromIndex:3];
                
                value = [[other componentsSeparatedByString:@"||"] firstObject];
            }
            else
                value = [[testViewValue componentsSeparatedByString:@"||"] lastObject];
            //
        }
    }
    else
        value =  [cellDict objectForKey:((UITextField *)view).accessibilityIdentifier];
    
    DLog(@"value ---> %@",value);
    
    
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
        
        sectionName = [appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"];
        if(indexPath.row <= bathroomsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"TOILETS"];
            row = indexPath.row;
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"GALLEY"];
            row = indexPath.row - ( bathroomsArr.count + 1 );
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + cabinArr.count + 2)
        {
            rowName = [appDel copyEnglishTextForKey:@"CABIN"];
            row = indexPath.row - (bathroomsArr.count + galleyArr.count + 2);
        }
        else if(indexPath.row <= bathroomsArr.count + galleyArr.count + cabinArr.count +  3)
        {
            rowName = [appDel copyEnglishTextForKey:@"TEMPERATURE"];
            row = indexPath.row - (bathroomsArr.count + galleyArr.count + cabinArr.count + 2);
            NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
            
            NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
            
            NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
            NSMutableArray *cellArr = [eventDict objectForKey:rowName];
            if(cellArr == nil || [cellArr count]==0)
            {
                [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
                cellArr = [eventDict objectForKey:rowName];
                [cellArr addObject:cellDict];
                
            }
            [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
            row = indexPath.row - (bathroomsArr.count + galleyArr.count + cabinArr.count  + 4) ;
        }
    }
    else
    {
        
        sectionName = [appDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"];
        
        if(indexPath.row <= faultySeatArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
            row = indexPath.row;
        }else {
            rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
            row = indexPath.row;
            
        }
        
    }
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    NSMutableDictionary *cellDict;
    {
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        cellDict= [cellArr objectAtIndex:row - 1];
    }
    if([view isKindOfClass:[TestView class]])
    {
        
        if ([((TestView *)view).key isEqualToString:@"CAMERA"]) {
            [cellDict setObject:((TestView *)view).imageName forKey:((TestView *)view).key];
            
        }
        else if([((TestView *)view).key isEqualToString:[appDel copyEnglishTextForKey:@"OBSERVATION"]])
        {
            [cellDict setObject:((TestView *)view).selectedValue forKey:((TestView *)view).key];
        }
        else
            [cellDict setObject:[((TestView *)view).selectedValue stringByAppendingFormat:@"||%@",((TestView *)view).selectedTextField.text] forKey:((TestView *)view).key];
    }
    else
        [cellDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;    currentTxtField = textField;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.cabinTableView];
    CGPoint contentOffset = self.cabinTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.cabinTableView setContentOffset:contentOffset animated:NO];
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
        
        
        
        NSIndexPath *indexPath = [self.cabinTableView indexPathForCell:cell];
        [self.cabinTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
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

#pragma mark - Popover Delegate Methods
-(void)valueSelectedInPopover:(TestView *)testView
{
    if (self.activeTestView.typeOfDropDown == CameraDropDownImage) {
        self.cameraVC.selectedOption = self.activeTestView.selectedValue;
        [self.cameraVC setImagePickerProperties];
        self.cameraVC.testView = self.activeTestView;
        self.cameraVC.cameraDelegate = self;
        [self performSelector:@selector(presentCameraVC) withObject:nil afterDelay:0.2];
        return;
    }

    [self setContentInFormDictForView:testView];
    
    
    NSIndexPath *indexPath ;
    
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    if (!testView.deleteImage) {
        [self.cabinTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self updateReportDictionary];
    
}
-(void)valuesSelectedInPopOver:(UITextField *)textFields {
    [self setContentInFormDictForView:textFields];
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[textFields superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[textFields superview] superview] superview]).indexPath;
    [self.cabinTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self updateReportDictionary];
    
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
        rowCount = bathroomsArr.count + galleyArr.count + cabinArr.count  + 4;
    }
    else
    {
        rowCount = faultySeatArr.count + 1;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    static NSString *headingCellCellID  = @"HeadingCellCellID";
    static NSString *otherTextCameraCellID  = @"OtherTextCameraCellID";
    static NSString *comboTextCellID    = @"ComboTextCellID";
    static NSString *comboNumTextTextCellID  = @"ComboNumTextTextCellID";
    static NSString *CabinLabelComboObservationCellId = @"LabelComboObservationCellID";
    
    OffsetCustomCell *cell              = nil;
    AddRowCell       *headingCell       = nil;
    OtherTextCamera      *otherTextCameraCell   = nil;
    ComboText        *comboTextCell     = nil;
    ComboNumTextText *comboNumTextTextCell = nil;
    CabinLabelComboObservationCell *labelComboObservationCell = nil;
    
    
    if(indexPath.section == 0)
    {
        
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"TOILETS"];
            
        }
        else if (indexPath.row == bathroomsArr.count + 1)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"GALLEY"];
        }
        else if (indexPath.row == bathroomsArr.count + galleyArr.count + 2)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"CABIN"];
        }
        else if (indexPath.row == bathroomsArr.count + galleyArr.count + cabinArr.count + 3)
        {
            labelComboObservationCell = (CabinLabelComboObservationCell *)[self createCellForTableView:tableView withCellID:CabinLabelComboObservationCellId];
            
        }
        else if(indexPath.row < bathroomsArr.count + 1)
        {
            otherTextCameraCell = (OtherTextCamera *)[self createCellForTableView:tableView withCellID:otherTextCameraCellID];
            cell = otherTextCameraCell;
            otherTextCameraCell.indexPath = indexPath;
            
            otherTextCameraCell.reasonTxt.delegate = self;
            otherTextCameraCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"IMPECCABILITY_OF_CAB" event:@"TOILETS" content:@"REPORT"];
            otherTextCameraCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherTextCameraCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            
            otherTextCameraCell.reasonLbl.attributedText =[[[appDel copyTextForKey:@"REPORT"] stringByAppendingString:@"*"] mandatoryString] ;
            otherTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            otherTextCameraCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherTextCameraCell.reasonTxt];
            otherTextCameraCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            otherTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherTextCameraCell.alertComboView.delegate = self;
            otherTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            otherTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherTextCameraCell.cameraView.key = @"CAMERA";
            otherTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherTextCameraCell.cameraView.delegate = self;
            otherTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherTextCameraCell.cameraView];
            if(otherTextCameraCell.cameraView.imageName==nil || [otherTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
            
        }
        else if(indexPath.row < bathroomsArr.count + galleyArr.count + 2)
        {
            otherTextCameraCell = (OtherTextCamera *)[self createCellForTableView:tableView withCellID:otherTextCameraCellID];
            cell = otherTextCameraCell;
            otherTextCameraCell.indexPath = indexPath;
            
            otherTextCameraCell.reasonTxt.delegate = self;
            otherTextCameraCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"IMPECCABILITY_OF_CAB" event:@"GALLEY" content:@"REPORT"];
            otherTextCameraCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherTextCameraCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            
            otherTextCameraCell.reasonLbl.attributedText =[[[appDel copyTextForKey:@"REPORT"] stringByAppendingString:@"*"] mandatoryString] ;
            otherTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            otherTextCameraCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherTextCameraCell.reasonTxt];
            otherTextCameraCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            otherTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherTextCameraCell.alertComboView.delegate = self;
            otherTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            otherTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherTextCameraCell.cameraView.key = @"CAMERA";
            otherTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherTextCameraCell.cameraView.delegate = self;
            otherTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherTextCameraCell.cameraView];
            if(otherTextCameraCell.cameraView.imageName==nil || [otherTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

            }
            
            
        }
        else if(indexPath.row < bathroomsArr.count + galleyArr.count + cabinArr.count + 3)
        {
            otherTextCameraCell = (OtherTextCamera *)[self createCellForTableView:tableView withCellID:otherTextCameraCellID];
            
            cell = otherTextCameraCell;
            otherTextCameraCell.indexPath = indexPath;
            
            otherTextCameraCell.reasonTxt.delegate = self;
            otherTextCameraCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"IMPECCABILITY_OF_CAB" event:@"CABIN" content:@"REPORT"];
            otherTextCameraCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherTextCameraCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            
            otherTextCameraCell.reasonLbl.attributedText =[[[appDel copyTextForKey:@"REPORT"] stringByAppendingString:@"*"] mandatoryString] ;
            otherTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            otherTextCameraCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherTextCameraCell.reasonTxt];
            otherTextCameraCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            otherTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherTextCameraCell.alertComboView.delegate = self;
            otherTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            otherTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherTextCameraCell.cameraView.key = @"CAMERA";
            otherTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherTextCameraCell.cameraView.delegate = self;
            otherTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherTextCameraCell.cameraView];
            if(otherTextCameraCell.cameraView.imageName==nil || [otherTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
            
        }
        else
        {
            comboTextCell = (ComboText *)[self createCellForTableView:tableView withCellID:comboTextCellID];
            
        }
        
    }
    else
    {
        
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
        }
        else
        {
            comboNumTextTextCell = (ComboNumTextText *)[self createCellForTableView:tableView withCellID:comboNumTextTextCellID];
            comboNumTextTextCell.delegate = self;
        }
    }
    
    if(headingCell)
    {
        cell = headingCell;
        headingCell.indexPath = indexPath;
    }
    
    else if(comboTextCell)
    {
        cell = comboTextCell;
        comboTextCell.indexPath = indexPath;
        
        comboTextCell.reportTxt.delegate = self;
        comboTextCell.reportTxt.dataSource = [NSArray arrayWithObjects:@"A340",@"B767",@"B787",@"B789", nil];
        comboTextCell.reportTxt.typeOfDropDown = NormalDropDown;
        comboTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
        
        comboTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"REPORT"] stringByAppendingString:@"*"] mandatoryString];
        comboTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        comboTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboTextCell.reportTxt];
        comboTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
        comboTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        comboTextCell.alertComboView.typeOfDropDown = AlertDropDown;
        comboTextCell.alertComboView.selectedTextField.hidden = YES;
        comboTextCell.alertComboView.delegate = self;
        comboTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:comboTextCell.alertComboView];
        comboTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:comboTextCell.alertComboView];
        
        if([self getContentInFormDictForView:comboTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:comboTextCell.alertComboView] isEqualToString:@""])
        {
            [comboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [comboTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        
    }
    else if(comboNumTextTextCell)
    {
        cell = comboNumTextTextCell;
        comboNumTextTextCell.delegate = self;
        comboNumTextTextCell.indexPath = indexPath;
        
        comboNumTextTextCell.failureTxt.delegate = self;
        comboNumTextTextCell.failureTxt.dataSource = [self getDropDownDataForGroup:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT" event:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT" content:@"FAILURE"];
        comboNumTextTextCell.failureTxt.typeOfDropDown = NormalDropDown;
        comboNumTextTextCell.failureTxt.key = [appDel copyEnglishTextForKey:@"FAILURE"];
        comboNumTextTextCell.failureTxt.selectedTextField.tag = MANDATORYTAG;
        //comboNumTextTextCell.seatLetterTxt.inputAccessoryView = [self keyboardToolBar];
        comboNumTextTextCell.seatLetterTxt.delegate = self;
        comboNumTextTextCell.seatLetterTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_LETTER"];
        [comboNumTextTextCell.seatLetterTxt setText:[self getContentInFormDictForView:comboNumTextTextCell.seatLetterTxt]];
        [comboNumTextTextCell.seatLetterTxt setFont:[UIFont fontWithName:KFontName size:14.0]];

        comboNumTextTextCell.seatLetterTxt.tag = MANDATORYTAG;
        
        comboNumTextTextCell.seatRowTxt.delegate = self;
        //comboNumTextTextCell.seatRowTxt.inputAccessoryView = [self keyboardToolBar];
        
        comboNumTextTextCell.seatRowTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"SEAT_ROW"];
        comboNumTextTextCell.seatRowTxt.tag = MANDATORYTAG;
        
        [comboNumTextTextCell.seatRowTxt setText:[self getContentInFormDictForView:comboNumTextTextCell.seatRowTxt]];
        [comboNumTextTextCell.seatRowTxt setFont:[UIFont fontWithName:KFontName size:14.0]];

        comboNumTextTextCell.failureLbl.attributedText = [[[appDel copyTextForKey:@"FAILURE"] stringByAppendingString:@"*"] mandatoryString];
        comboNumTextTextCell.seatLetterLbl.attributedText = [[[appDel copyTextForKey:@"SEAT_LETTER"] stringByAppendingString:@"*"] mandatoryString];
        comboNumTextTextCell.seatRowLbl.attributedText = [[[appDel copyTextForKey:@"SEAT_ROW"] stringByAppendingString:@"*"] mandatoryString];;
        comboNumTextTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        
        comboNumTextTextCell.failureTxt.selectedTextField.text = [self getContentInFormDictForView:comboNumTextTextCell.failureTxt];
        
        comboNumTextTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        comboNumTextTextCell.alertComboView.typeOfDropDown = AlertDropDown;
        comboNumTextTextCell.alertComboView.selectedTextField.hidden = YES;
        comboNumTextTextCell.alertComboView.delegate = self;
        comboNumTextTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:comboNumTextTextCell.alertComboView];
        comboNumTextTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:comboNumTextTextCell.alertComboView];
        
        if([self getContentInFormDictForView:comboNumTextTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:comboNumTextTextCell.alertComboView] isEqualToString:@""])
        {
            [comboNumTextTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [comboNumTextTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
    }
    else if(labelComboObservationCell)
    {
        cell = labelComboObservationCell;
        labelComboObservationCell.indexPath = indexPath;
        labelComboObservationCell.leftLabel.text = [appDel copyTextForKey:@"TEMPERATURE"];
        labelComboObservationCell.reasonCombobox.delegate = self;
        labelComboObservationCell.reasonCombobox.dataSource = [self getDropDownDataForGroup:@"IMPECCABILITY_OF_CAB" event:@"TEMPERATURE" content:@"REPORT"];
        labelComboObservationCell.reasonCombobox.typeOfDropDown = NormalDropDown;
        labelComboObservationCell.reasonCombobox.key = [appDel copyEnglishTextForKey:@"REPORT"];
        labelComboObservationCell.reasonCombobox.selectedTextField.text = [self getContentInFormDictForView:labelComboObservationCell.reasonCombobox];
        
        
        labelComboObservationCell.reasonCombobox.selectedValue = [self getContentInFormDictForView:labelComboObservationCell.reasonCombobox];
        
        labelComboObservationCell.reasonLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        labelComboObservationCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        labelComboObservationCell.alertComboView.typeOfDropDown = AlertDropDown;
        labelComboObservationCell.alertComboView.selectedTextField.hidden = YES;
        labelComboObservationCell.alertComboView.delegate = self;
        labelComboObservationCell.alertComboView.selectedValue = [self getContentInFormDictForView:labelComboObservationCell.alertComboView];
        labelComboObservationCell.alertComboView.notesView.text = [self getContentInFormDictForView:labelComboObservationCell.alertComboView];
        
        if([self getContentInFormDictForView:labelComboObservationCell.alertComboView] == NULL || [[self getContentInFormDictForView:labelComboObservationCell.alertComboView] isEqualToString:@""])
        {
            [labelComboObservationCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [labelComboObservationCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    
    NSString *sectionTitle;
    if(section == 0)
    {
        sectionTitle = [appDel copyTextForKey:@"IMPECCABILITY_OF_CAB"];
    }
    else if (section == 1)
    {
        sectionTitle = [appDel copyTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"];
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
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0 || indexPath.row == bathroomsArr.count + 1 || indexPath.row == bathroomsArr.count + galleyArr.count  + 2 || indexPath.row == bathroomsArr.count + galleyArr.count + cabinArr.count + 3)
        {
            height = 44.0;
        }
        else
        {
            height = 44.0;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            height = 44.0;
        }
        else
        {
            height = 44.0;
        }
        
        
    }
    
    return 44;
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
    
    if([cellID isEqualToString:@"HeadingCellCellID"])
    {
        AddRowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddRowCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
    }
    else if([cellID isEqualToString:@"OtherTextCameraCellID"])
    {
        OtherTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherTextCamera" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"ComboTextCellID"])
    {
        ComboText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    
    else if([cellID isEqualToString:@"ComboNumTextTextCellID"])
    {
        ComboNumTextText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboNumTextText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }else if([cellID isEqualToString:@"LabelComboObservationCellID"]){
        CabinLabelComboObservationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CabinLabelComboObservationCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    return nil;
    
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
            
            sectionName = [appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"];
            if(indexPath.row <= bathroomsArr.count )
            {
                rowName = [appDel copyEnglishTextForKey:@"TOILETS"];
                row = indexPath.row;
                [bathroomsArr removeObjectAtIndex:bathroomsArr.count  - indexPath.row];
                
                
            }
            else if(indexPath.row <= bathroomsArr.count + galleyArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"GALLEY"];
                row = indexPath.row - (bathroomsArr.count + 1);
                [galleyArr removeObjectAtIndex:bathroomsArr.count + galleyArr.count + 1 - indexPath.row];
                
            }
            else if(indexPath.row <= bathroomsArr.count + galleyArr.count + cabinArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"CABIN"];
                row = indexPath.row - (bathroomsArr.count + galleyArr.count + 2);
                [cabinArr removeObjectAtIndex:bathroomsArr.count + galleyArr.count + cabinArr.count + 2 - indexPath.row ];
                
            }
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"];
            if(indexPath.row <= faultySeatArr.count )
            {
                rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
                row = indexPath.row;
                [faultySeatArr removeObjectAtIndex:faultySeatArr.count  - indexPath.row];
                
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
            [eventDict setObject:[[NSMutableArray alloc]init] forKey:rowName];
            cellArr = [eventDict objectForKey:rowName];
        }
        
        [cellArr removeObjectAtIndex:row - 1];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        [self.cabinTableView beginUpdates];
        [self.cabinTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.cabinTableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        if([LTSingleton getSharedSingletonInstance].sendReport){
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"];
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"TOILETS"];
                [bathroomsArr addObject:@"1"];
            }
            else if(indexPath.row == bathroomsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"GALLEY"];
                [galleyArr addObject:@"1"];
            }
            else if(indexPath.row == bathroomsArr.count + galleyArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"CABIN"];
                [cabinArr addObject:@"1"];
            }
            
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"];
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"];
                [faultySeatArr addObject:@"1"];
            }
            
        }
        
        
        NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        
        [cellArr insertObject:cellDict atIndex:0];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [self.cabinTableView beginUpdates];
        [self.cabinTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.cabinTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        
        if([LTSingleton getSharedSingletonInstance].sendReport){
            [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        }
        
        NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
        
        
        if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
            [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellEditingStyle cellEditingStyle;
    if(indexPath.section == 0)
    {
        if(indexPath.row == bathroomsArr.count + galleyArr.count + cabinArr.count + 3) {
            cellEditingStyle = UITableViewCellEditingStyleNone;
            
        }
        else if(indexPath.row == 0 || indexPath.row == bathroomsArr.count + 1 || indexPath.row == bathroomsArr.count + galleyArr.count  + 2  )
        {
            cellEditingStyle = UITableViewCellEditingStyleInsert;
        }
        else
        {
            cellEditingStyle = UITableViewCellEditingStyleDelete;
        }
        
    }
    else
    {
        
        if(indexPath.row == 0 )
        {
            cellEditingStyle = UITableViewCellEditingStyleInsert;
        }
        else
        {
            cellEditingStyle = UITableViewCellEditingStyleDelete;
        }
        
    }
    return cellEditingStyle;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        if(indexPath.row  == bathroomsArr.count + galleyArr.count + cabinArr.count + 3 ){
            return NO;
        }
    }
    return YES;
}




@end
