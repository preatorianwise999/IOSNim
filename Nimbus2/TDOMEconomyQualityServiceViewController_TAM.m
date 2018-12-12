//
//  TDOMEconomyQualityServiceViewController_TAM.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TDOMEconomyQualityServiceViewController_TAM.h"
#import "AddRowCell.h"
#import "ComboOtherComboNumTextCamera.h"
#import "NSString+Validation.h"
#import "LTGetDropDownvalue.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"


@interface TDOMEconomyQualityServiceViewController_TAM ()<UITextFieldDelegate,PopoverDelegate> {
    UITextField *currentTxtField;
    NSArray *arr;
    NSMutableArray *groupArr;
    AppDelegate *appDel;
    NSDictionary *dropDownDict;
    
}
@property(nonatomic,weak) IBOutlet UITableView *qualityServiceTableView;
@property(nonatomic,weak) IBOutlet UILabel *headlingLbl;
@end

@implementation TDOMEconomyQualityServiceViewController_TAM
@synthesize qualityCateringServiceArr;

#pragma mark - View Life Cycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    self.tableView = self.qualityServiceTableView;
    self.ipArray = [[NSMutableArray alloc] init];

    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _headlingLbl.textColor=kFontColor;
    [_headlingLbl setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headlingLbl.text = [appDel copyTextForKey:@"QUALITY_SERVICE_CAT"];

    CGRect frame = _headlingLbl.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;//pass the cordinate which you want
    _headlingLbl.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    [self.qualityServiceTableView setEditing:YES animated:YES];
    [self initializeIndexPathArray];
    _qualityServiceTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal Methods
//Initialize data esp group array and drop down dictionary
- (void)initializeData
{
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    qualityCateringServiceArr    = [[NSMutableArray alloc] init];
    self.headlingLbl.text = [appDel copyTextForKey:@"QUALITY_SERVICE_CAT"];
    
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
                    
                    DLog(@"rowDict %@",rowDict);
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"]] )
                        {
                            [qualityCateringServiceArr addObject:@"1"];
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
        
        NSMutableDictionary *apvDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"] forKey:@"name"];
        [groupDict setObject:apvDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
    }
    
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
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.qualityServiceTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.qualityServiceTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            for(int section = cell.indexPath.section ;section<[self.qualityServiceTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.qualityServiceTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.qualityServiceTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
#pragma mark - Popover Delegate Methods
//Called whenever a drop down value is selected - updates main dictionary
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
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;    //MADHU ADDED
    if (!testView.deleteImage) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if([LTSingleton getSharedSingletonInstance].sendReport){
        [self updateReportDictionary];
        
    }
    //
    
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
    
    sectionName = [appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"];
    
    if(indexPath.row <= qualityCateringServiceArr.count )
    {
        rowName = [appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"];
        row = indexPath.row;
    }else{
        rowName = [appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"];
        row = indexPath.row;
    }
    @try {
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        NSMutableDictionary *cellDict = [cellArr objectAtIndex:row - 1];
        
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
            }
        }
        else
            value =  [cellDict objectForKey:((UITextField *)view).accessibilityIdentifier];
        
        DLog(@"value ---> %@",value);
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
    
    
    sectionName = [appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"];
    
    
    rowName = [appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"];
    row = indexPath.row ;
    
    NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
    
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
    NSMutableArray *cellArr = [eventDict objectForKey:rowName];
    NSMutableDictionary *cellDict = [cellArr objectAtIndex:row - 1];
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
    }    else
        [cellDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}
#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;    currentTxtField = textField;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.qualityServiceTableView];
    CGPoint contentOffset = self.qualityServiceTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.qualityServiceTableView setContentOffset:contentOffset animated:NO];
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
        NSIndexPath *indexPath = [self.qualityServiceTableView indexPathForCell:cell];
        [self.qualityServiceTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    
    rowCount = qualityCateringServiceArr.count + 1;
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    static NSString *headingCellCellID             = @"HeadingCellCellID";
    static NSString *comboComboComboNumTextCameraCellID  = @"ComboOtherComboNumTextCamera";
    
    OffsetCustomCell *cell = nil;
    AddRowCell *headingCell = nil;
    ComboOtherComboNumTextCamera *comboComboComboNumTextCameraCell = nil;
    
    if(indexPath.row == 0)
    {
        headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
        headingCell.headingLbl.text = [appDel copyTextForKey:@"QUALITY_OF_SERVICE"];
    }
    else
    {
        comboComboComboNumTextCameraCell = (ComboOtherComboNumTextCamera *)[self createCellForTableView:tableView withCellID:comboComboComboNumTextCameraCellID];
    }
    
    if(headingCell)
    {
        cell = headingCell;
        headingCell.indexPath = indexPath;
    }
    else if(comboComboComboNumTextCameraCell)
    {
        cell = comboComboComboNumTextCameraCell;
        comboComboComboNumTextCameraCell.indexPath = indexPath;
        comboComboComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
        comboComboComboNumTextCameraCell.amountTxt.delegate = self;
        comboComboComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
        comboComboComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.amountTxt];
        comboComboComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];
        comboComboComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
        
        
        comboComboComboNumTextCameraCell.serviceTxt.typeOfDropDown = NormalDropDown;
        comboComboComboNumTextCameraCell.serviceTxt.dataSource = [self getDropDownDataForGroup:@"QUALITY_CATERING_SERVICE" event:@"QUALITY_OF_SERVICE" content:@"SERVICE"];
        comboComboComboNumTextCameraCell.serviceTxt.delegate = self;
        comboComboComboNumTextCameraCell.serviceTxt.key = [appDel copyEnglishTextForKey:@"SERVICE"];
        comboComboComboNumTextCameraCell.serviceTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.serviceTxt];
        comboComboComboNumTextCameraCell.serviceTxt.selectedTextField.tag = MANDATORYTAG;
        
        comboComboComboNumTextCameraCell.optionTxt.typeOfDropDown = OtherDropDown;
        comboComboComboNumTextCameraCell.optionTxt.dataSource = [self getDropDownDataForGroup:@"QUALITY_CATERING_SERVICE" event:@"QUALITY_OF_SERVICE" content:@"OPTION"];
        comboComboComboNumTextCameraCell.optionTxt.delegate = self;
        comboComboComboNumTextCameraCell.optionTxt.key = [appDel copyEnglishTextForKey:@"OPTION"];
        comboComboComboNumTextCameraCell.optionTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.optionTxt];
        comboComboComboNumTextCameraCell.optionTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        
        comboComboComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
        comboComboComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"QUALITY_CATERING_SERVICE" event:@"QUALITY_OF_SERVICE" content:@"OCCURRENCE_TAM"];
        comboComboComboNumTextCameraCell.reportTxt.delegate = self;
        comboComboComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"OCCURRENCE_TAM"];
        comboComboComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.reportTxt];
        comboComboComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
        
        
        comboComboComboNumTextCameraCell.serviceLbl.attributedText = [[[appDel copyTextForKey:@"SERVICE"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboNumTextCameraCell.optionLbl.attributedText = [[[appDel copyTextForKey:@"OPTION"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
        comboComboComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
        
        comboComboComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        
        comboComboComboNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
        comboComboComboNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
        comboComboComboNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
        comboComboComboNumTextCameraCell.alertComboView.delegate = self;
        comboComboComboNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.alertComboView];
        comboComboComboNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.alertComboView];
        
        
        if([self getContentInFormDictForView:comboComboComboNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:comboComboComboNumTextCameraCell.alertComboView] isEqualToString:@""])
        {
            [comboComboComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
        }
        else
            [comboComboComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
        
        comboComboComboNumTextCameraCell.cameraView.key = @"CAMERA";
        comboComboComboNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
        comboComboComboNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
        comboComboComboNumTextCameraCell.cameraView.delegate = self;
        
        comboComboComboNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:comboComboComboNumTextCameraCell.cameraView];
        if(comboComboComboNumTextCameraCell.cameraView.imageName==nil || [comboComboComboNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
            [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];
        }
        else{
            [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];
            
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
    else
    {
        ComboOtherComboNumTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboOtherComboNumTextCamera" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
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
            sectionName = [appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"];
            
            rowName = [appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"];
            row = indexPath.row;
            [qualityCateringServiceArr removeObjectAtIndex:indexPath.row - 1];
            
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
        
        [self.qualityServiceTableView beginUpdates];
        [self.qualityServiceTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.qualityServiceTableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"];
            
            rowName = [appDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"];
            
            [qualityCateringServiceArr addObject:@"1"];
            
        }
        NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        
        [cellArr insertObject:cellDict atIndex:0];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [self.qualityServiceTableView beginUpdates];
        [self.qualityServiceTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.qualityServiceTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        
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
    
    if(indexPath.row == 0)
    {
        cellEditingStyle = UITableViewCellEditingStyleInsert;
    }
    else
    {
        cellEditingStyle = UITableViewCellEditingStyleDelete;
    }
    
    
    return cellEditingStyle;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    NSString *sectionTitle;
    if(section == 0)
    {
        sectionTitle = [appDel copyTextForKey:@"QUALITY_CATERING_SERVICE"];
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
    
    if(indexPath.row == 0)
    {
        height = 64.0;
    }
    else
    {
        height = 69.0;
    }
    
    height = 44; //Added Pavan
    return height;
}

@end
