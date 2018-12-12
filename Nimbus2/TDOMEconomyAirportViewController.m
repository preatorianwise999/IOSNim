//
//  NBEconomyAirportViewController.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TDOMEconomyAirportViewController.h"
#import "OffsetCustomCell.h"
#import "OtherCell.h"
#import "OtherNumTextCamera.h"
#import "OtherText.h"
#import "AddRowCell.h"
#import "NSString+Validation.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"
#import "NSString+Validation.h"


@interface TDOMEconomyAirportViewController ()
{
    UITextField *currentTxtField;
    NSMutableArray *groupArr;
    AppDelegate *appDel;
    NSMutableDictionary *dropDownDict;
}
@property(nonatomic,weak) IBOutlet UITableView *economyAirportTableView;
@property(nonatomic, weak) IBOutlet UILabel *headlingLbl;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end

@implementation TDOMEconomyAirportViewController
@synthesize mallAssignedSeatsArr,duplicateSeatArr,propertyInfoSeatArr,handLuggageArr;
@synthesize headlingLbl;
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
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    self.tableView = self.economyAirportTableView;
    self.ipArray = [[NSMutableArray alloc] init];

    [self.economyAirportTableView setEditing:YES animated:YES];
    [self initializeIndexPathArray];
    headlingLbl.textColor=kFontColor;
    [headlingLbl setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    headlingLbl.text = [appDel copyTextForKey:@"AIRPORT"];

    CGRect frame = headlingLbl.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    headlingLbl.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    

    _economyAirportTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

    
}

//Update mandatory fields dictionary whenever keyboard is dismissed
-(void)keyboardDidHide:(NSNotification *)notif{
    
    [self updateReportDictionary];
    
}

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

#pragma mark - Internal Methods

//Initialize data esp group array and drop down dictionary
- (void)initializeData
{

    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    headlingLbl.text = [appDel copyTextForKey:@"AIRPORT"];
    
    mallAssignedSeatsArr    = [[NSMutableArray alloc] init];
    duplicateSeatArr        = [[NSMutableArray alloc] init];
    propertyInfoSeatArr     = [[NSMutableArray alloc] init];
    handLuggageArr          = [[NSMutableArray alloc] init];
    
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
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"]] )
                        {
                            [handLuggageArr addObject:@"1"];
                        }
                    }
                    else
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"]] )
                        {
                            [mallAssignedSeatsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"]] )
                        {
                            [propertyInfoSeatArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"]] )
                        {
                            [duplicateSeatArr addObject:@"1"];
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
        
        NSMutableDictionary *handLuggageDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init],  nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"], nil]];
        
        NSMutableDictionary *malAssignedDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init],[[NSMutableArray alloc] init],nil] forKeys:[[NSMutableArray alloc] initWithObjects: [appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"], [appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"], [appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"] forKey:@"name"];
        [groupDict setObject:handLuggageDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"] forKey:@"name"];
        [groupDict setObject:malAssignedDict forKey:@"multiEvents"];
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
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.economyAirportTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.economyAirportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            for(int section = cell.indexPath.section ;section<[self.economyAirportTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.economyAirportTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.economyAirportTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
        rowCount = handLuggageArr.count + 1;
    }
    else
    {
        rowCount = mallAssignedSeatsArr.count + propertyInfoSeatArr.count + duplicateSeatArr.count + 3;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    
    static NSString *headingCellCellID          = @"HeadingCellCellID";
    static NSString *otherCellID                = @"OtherCellID";
    static NSString *otherNumTextCameraCellID   = @"OtherNumTextCameraCellID";
    static NSString *otherTextCellID            = @"OtherTextCellID";
    
    
    OffsetCustomCell *cell = nil;
    AddRowCell *headingCell = nil;
    OtherText *otherTextCell = nil;
    OtherNumTextCamera *otherNumTextCameraCell = nil;
    OtherCell *otherCell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"AIRPORT_HANDLUGGAGE"];
        }
        else
        {
            otherNumTextCameraCell = (OtherNumTextCamera *)[self createCellForTableView:tableView withCellID:otherNumTextCameraCellID];
            cell = otherNumTextCameraCell;
            otherNumTextCameraCell.indexPath = indexPath;
            
            otherNumTextCameraCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherNumTextCameraCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"AIRPORT_BAGGAGE" event:@"AIRPORT_HANDLUGGAGE" content:@"REASON"];
            otherNumTextCameraCell.reasonTxt.delegate = self;
            otherNumTextCameraCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REASON"];
            otherNumTextCameraCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherNumTextCameraCell.amountTxt.delegate = self;
            otherNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            otherNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            
            otherNumTextCameraCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"REASON"] stringByAppendingString:@"*"] mandatoryString];
            otherNumTextCameraCell.amountLbl.attributedText = [[[appDel copyTextForKey:@"AMOUNT"] stringByAppendingString:@"*"] mandatoryString];
            otherNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherNumTextCameraCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherNumTextCameraCell.reasonTxt];
            otherNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:otherNumTextCameraCell.amountTxt];
            otherNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherNumTextCameraCell.alertComboView.delegate = self;
            otherNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherNumTextCameraCell.alertComboView];
            otherNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherNumTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherNumTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherNumTextCameraCell.cameraView.key = @"CAMERA";
            otherNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherNumTextCameraCell.cameraView.delegate = self;
            otherNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherNumTextCameraCell.cameraView];
            if(otherNumTextCameraCell.cameraView.imageName==nil || [otherNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
                [otherNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];
            }
            else{
                [otherNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];
                
            }
            
            
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"AIRPORT_MALASSIGNED"] ;
        }
        else if (indexPath.row == mallAssignedSeatsArr.count + 1)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"AIRPORT_PROPERTYINFOSEAT"];
        }
        else if (indexPath.row == mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"AIRPORT_DUPLICATESEAT"];
        }
        else if(indexPath.row < mallAssignedSeatsArr.count + 1)
        {
            otherCell = (OtherCell *)[self createCellForTableView:tableView withCellID:otherCellID];
            cell = otherCell;
            otherCell.indexPath = indexPath;
            
            otherCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"AIRPORT_ASSIGNSEAT" event:@"AIRPORT_MALASSIGNED" content:@"REASON"];
            otherCell.reasonTxt.delegate = self;
            otherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REASON"];
            otherCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"REASON"] stringByAppendingString:@"*"] mandatoryString];
            
            otherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherCell.reasonTxt];
        }
        else if(indexPath.row < mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2)
        {
            otherCell = (OtherCell *)[self createCellForTableView:tableView withCellID:otherCellID];
            cell = otherCell;
            otherCell.indexPath = indexPath;
            
            otherCell.reasonTxt.typeOfDropDown = OtherDropDown;
            otherCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"AIRPORT_ASSIGNSEAT" event:@"AIRPORT_PROPERTYINFOSEAT" content:@"REPORT"];
            otherCell.reasonTxt.delegate = self;
            otherCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"REPORT_TAM"] stringByAppendingString:@"*"] mandatoryString];
            
            otherCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherCell.reasonTxt];
        }
        else
        {
            otherTextCell = (OtherText *)[self createCellForTableView:tableView withCellID:otherTextCellID];
            cell = otherTextCell;
            otherTextCell.indexPath = indexPath;
            
            otherTextCell.reportTxt.delegate = self;
            otherTextCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"AIRPORT_ASSIGNSEAT" event:@"AIRPORT_DUPLICATESEAT" content:@"REPORT"];
            otherTextCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherTextCell.fullNameTxt.delegate = self;
            otherTextCell.fullNameTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AIRPORT_FULLNAME"];
            otherTextCell.fullNameTxt.tag = MANDATORYTAG;
            
            otherTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"REPORT_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherTextCell.passengerNameLbl.attributedText = [[[appDel copyTextForKey:@"AIRPORT_FULLNAME"] stringByAppendingString:@"*"] mandatoryString];
            otherTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherTextCell.reportTxt];
            otherTextCell.fullNameTxt.text = [self getContentInFormDictForView:otherTextCell.fullNameTxt];
            otherTextCell.fullNameTxt.font=[UIFont fontWithName:KFontName size:14.0];

            
        }
        
        
    }
        
    if(headingCell)
    {
        cell = headingCell;
        headingCell.indexPath = indexPath;
    }
    
    
    // Configure the cell...
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
    else if([cellID isEqualToString:@"OtherTextCellID"]){
        OtherText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"OtherNumTextCameraCellID"]){
        OtherNumTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherNumTextCamera" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    else{
        OtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    NSString *sectionTitle;
    if(section == 0)
    {
        sectionTitle = [appDel copyTextForKey:@"AIRPORT_BAGGAGE"];
    }
    else if (section == 1)
    {
        sectionTitle = [appDel copyTextForKey:@"AIRPORT_ASSIGNSEAT"];
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
    return 35;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [currentTxtField resignFirstResponder];
    
    NSInteger row = 0;
    NSString *sectionName;
    NSString *rowName = @"";
    NSIndexPath *modifiedIndexpath;
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0)
        {
            
            sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"];
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"];
            row = indexPath.row;
            [handLuggageArr removeObjectAtIndex:indexPath.row - 1];
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"];
            if(indexPath.row <= mallAssignedSeatsArr.count )
            {
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"];
                row = indexPath.row;
                [mallAssignedSeatsArr removeObjectAtIndex:mallAssignedSeatsArr.count  - indexPath.row];
                
            }
            else if(indexPath.row <= mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 1)
            {
                
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"];
                row = indexPath.row - (mallAssignedSeatsArr.count + 1);
                [propertyInfoSeatArr removeObjectAtIndex:mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 1 - indexPath.row];
                
            }
            else if(indexPath.row <= mallAssignedSeatsArr.count + propertyInfoSeatArr.count + duplicateSeatArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"];
                row = indexPath.row - (mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2);
                [duplicateSeatArr removeObjectAtIndex:mallAssignedSeatsArr.count + propertyInfoSeatArr.count + duplicateSeatArr.count + 2 - indexPath.row ];
                
            }
            
        }
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        if([[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"]){
            
            NSString *imageName = [[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"];
            
            [self deleteImage:imageName];
        }        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        [cellArr removeObjectAtIndex:row - 1];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        
        [self.economyAirportTableView beginUpdates];
        [self.economyAirportTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.economyAirportTableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"];
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"];
            [handLuggageArr addObject:@"1"];
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"];
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"];
                [mallAssignedSeatsArr addObject:@"1"];
                
            }
            else if(indexPath.row == mallAssignedSeatsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"];
                [propertyInfoSeatArr addObject:@"1"];
                
            }
            else if(indexPath.row == mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"];
                [duplicateSeatArr addObject:@"1"];
                
            }
            
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
        [cellArr insertObject:cellDict atIndex:0];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [self.economyAirportTableView beginUpdates];
        [self.economyAirportTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.economyAirportTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
        if (!ISiOS8) {
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        }
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        
        NSArray *res = [t filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath.row == %d && indexPath.section == %d",modifiedIndexpath.row,modifiedIndexpath.section]];
        
        
        if([res count] == 0 || (((OffsetCustomCell *)[t lastObject]).indexPath.row == modifiedIndexpath.row && ((OffsetCustomCell *)[t lastObject]).indexPath.section == modifiedIndexpath.section)){
            [tableView scrollToRowAtIndexPath:modifiedIndexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellEditingStyle cellEditingStyle;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
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
        else if (indexPath.row == mallAssignedSeatsArr.count + 1){
            cellEditingStyle = UITableViewCellEditingStyleInsert;
        }
        else if (indexPath.row == mallAssignedSeatsArr.count + propertyInfoSeatArr.count  + 2)
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            height = 64.0;
        }
        else
        {
            height = 69.0;
        }
    }
    else
    {
        if(indexPath.row == 0 || indexPath.row == mallAssignedSeatsArr.count + 1 || indexPath.row == mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2)
        {
            height = 64.0;
        }
        else
        {
            height = 69.0;
        }
        
        
    }
    
    //return height;
    return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
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
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    if (!testView.deleteImage) {
        [self.economyAirportTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self updateReportDictionary];
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
    
    int row = 0;
    NSString *sectionName;
    NSString *rowName=@"";
    
    
    if (indexPath.section == 0)
    {
        sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"];
        rowName = [appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"];
        row = indexPath.row;
        
        
    }
    else
    {
        sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"];
        if(indexPath.row <= mallAssignedSeatsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"];
            row = indexPath.row;
        }
        else if(indexPath.row <= mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"];
            row = indexPath.row - ( mallAssignedSeatsArr.count + 1 );
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"];
            row = indexPath.row - (mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2);
        }
        
        
    }
    
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
    DLog(@"Leg- %d",kCurrentLegNumber);

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
    
    int row = 0;
    
    NSString *sectionName;
    NSString *rowName=@"";
    
    if (indexPath.section == 0)
    {
        sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"];
        
        rowName = [appDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"];
        row = indexPath.row;
    }
    else
    {
        sectionName = [appDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"];
        if(indexPath.row <= mallAssignedSeatsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"];
            row = indexPath.row;
        }
        else if(indexPath.row <= mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"];
            row = indexPath.row - ( mallAssignedSeatsArr.count + 1 );
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"];
            row = indexPath.row - (mallAssignedSeatsArr.count + propertyInfoSeatArr.count + 2);
        }
    }
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
    }
    else
        [cellDict setObject:((UITextField *)view).text forKey:((UITextField *)view).accessibilityIdentifier];
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    DLog(@"Leg- %d",kCurrentLegNumber);
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    currentTxtField = textField;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.economyAirportTableView];
    CGPoint contentOffset = self.economyAirportTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self.economyAirportTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
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
    
    if(isKeyboardUp)
        return;
    
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
        
        NSIndexPath *indexPath = [self.economyAirportTableView indexPathForCell:cell];
        [self.economyAirportTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.location == 0 && [string isEqualToString:@" "])
        return NO;
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

@end
