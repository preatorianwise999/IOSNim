//
//  TDOMEconomyElementAPVViewController.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TDOMEconomyElementAPVViewController.h"
#import "OtherComboNumText.h"
#import "AddRowCell.h"
#import "OffsetCustomCell.h"
#import "OtherComboNumTextCamera.h"
#import "ComboComboComboNumTextCamera.h"
#import "NSString+Validation.h"
#import "LTGetDropDownvalue.h"
#import "Groups.h"
#import "Events.h"
#import "LTSingleton.h"
#import "AppDelegate.h"
#import "LTGetLightData.h"
#import "LTCreateFlightReport.h"
#import "LTGetDropDownvalue.h"

@interface TDOMEconomyElementAPVViewController ()
{
    UITextField *currentTxtField;
    NSMutableArray *groupArr;
    NSArray *arr;
    AppDelegate *appDel;
    NSDictionary *dropDownDict;
}
@property(nonatomic, weak)IBOutlet UITableView *apvElementsTableView;
@property(nonatomic, weak) IBOutlet UILabel *headlingLbl;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end

@implementation TDOMEconomyElementAPVViewController
@synthesize apvElementsArr, catElementsArr, securityElementsArr, bathElementsArr, galleyElementsArr, liquidsElementsArr, mealsElementsArr;


#pragma mark- View Life Cycle Methods
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
    
    self.tableView = self.apvElementsTableView;
    self.ipArray = [[NSMutableArray alloc] init];
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];


    
    [self.apvElementsTableView setEditing:YES animated:YES];
    [self initializeIndexPathArray];
    _headlingLbl.textColor=kFontColor;
    [_headlingLbl setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headlingLbl.text = [appDel copyTextForKey:@"ELEMENT_CAT_APV"];
    CGRect frame = _headlingLbl.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    _headlingLbl.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    
    

    _apvElementsTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

}

//-(void)viewWillDisappear:(BOOL)animated{
//
//    //[DatabaseOperations saveTheEvent:groupArr withGroupArray:[LTSingleton getSharedSingletonInstance].flightRoasterDict];
//
//    [DatabaseOperations saveEventWithFlightRoasterDict:[LTSingleton getSharedSingletonInstance].flightRoasterDict withArray:(NSMutableArray*)arr];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Internal Methods
- (void)initializeData
{
        appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.headlingLbl.text = [appDel copyTextForKey:@"ELEMENT_CAT_APV"];
    
    apvElementsArr          = [[NSMutableArray alloc] init];
    catElementsArr          = [[NSMutableArray alloc] init];
    securityElementsArr     = [[NSMutableArray alloc] init];
    bathElementsArr         = [[NSMutableArray alloc] init];
    galleyElementsArr       = [[NSMutableArray alloc] init];
    liquidsElementsArr      = [[NSMutableArray alloc] init];
    mealsElementsArr        = [[NSMutableArray alloc] init];
    
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
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_APV"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"]] )
                        {
                            [apvElementsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_CABIN"]] )
                        {
                            [catElementsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"]] )
                        {
                            [securityElementsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_BATH"]] )
                        {
                            [bathElementsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"]] )
                        {
                            [galleyElementsArr addObject:@"1"];
                        }
                        
                    }
                    else
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"]] )
                        {
                            [liquidsElementsArr addObject:@"1"];
                        }
                        else if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"ELEMENT_MEALS"]] )
                        {
                            [mealsElementsArr addObject:@"1"];
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
        
        NSMutableDictionary *apvDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], [[NSMutableArray alloc] init], [[NSMutableArray alloc] init], [[NSMutableArray alloc] init], nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"], [appDel copyEnglishTextForKey:@"ELEMENT_CABIN"], [appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"], [appDel copyEnglishTextForKey:@"ELEMENT_BATH"], [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"], nil]];
        
        NSMutableDictionary *cateringDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"], [appDel copyEnglishTextForKey:@"ELEMENT_MEALS"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"ELEMENT_APV"] forKey:@"name"];
        [groupDict setObject:apvDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"ELEMENT_CATERING"] forKey:@"name"];
        [groupDict setObject:cateringDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
    }
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
    NSDictionary *flightRoaster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    NSString *type = [flightRoaster objectForKey:@"flightReportType"];
    NSString *report = [[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"name"];
    NSString *section = [[[[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"name"];
    
    
    dropDownDict = [LTGetDropDownvalue getDictForReportType:type FlightReport:report Section:section];
    DLog(@"dropDownDict=%@",dropDownDict);
}

-(NSArray *)getDropDownDataForGroup:(NSString *)group event:(NSString *)event content:(NSString *)content
{
    return [[[dropDownDict objectForKey:[appDel copyEnglishTextForKey:group]]objectForKey:[appDel copyEnglishTextForKey:event]] objectForKey:[appDel copyEnglishTextForKey:content]];
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
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OffsetCustomCell *)[[testView superview] superview]).indexPath;
    else
        indexPath = ((OffsetCustomCell *)[[[testView superview] superview] superview]).indexPath;
    
    if (!testView.deleteImage) {
        [self.apvElementsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    //if([LTSingleton getSharedSingletonInstance].sendReport){
    [self updateReportDictionary];
    //}
    
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
        sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_APV"];
        if(indexPath.row <= apvElementsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"];
            row = indexPath.row;
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_CABIN"];
            row = indexPath.row - ( apvElementsArr.count + 1 );
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 2)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + 2);
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 3)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_BATH"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3);
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4) ;
            
        }
        
    }
    else
    {
        sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_CATERING"];
        if(indexPath.row <= liquidsElementsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"];
            row = indexPath.row;
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MEALS"];
            row = indexPath.row - (liquidsElementsArr.count + 1);
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
        sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_APV"];
        if(indexPath.row <= apvElementsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"];
            row = indexPath.row;
            
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + 1)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_CABIN"];
            row = indexPath.row - ( apvElementsArr.count + 1 );
            
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 2)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + 2);
            
        }
        else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 3)
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_BATH"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3);
            
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
            row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4) ;
            
        }
        
    }
    else
    {
        sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_CATERING"];
        if(indexPath.row <= liquidsElementsArr.count )
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"];
            row = indexPath.row;
            
        }
        else
        {
            rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MEALS"];
            row = indexPath.row - (liquidsElementsArr.count + 1);
            
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
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.apvElementsTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OffsetCustomCell *)[self.apvElementsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            for(int section = cell.indexPath.section ;section<[self.apvElementsTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;int tempTag=0;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.apvElementsTableView numberOfRowsInSection:section];row++){
                    cell = (OffsetCustomCell *)[self.apvElementsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;    currentTxtField = textField;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.apvElementsTableView];
    CGPoint contentOffset = self.apvElementsTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    //    CGSize newContentSize = self.apvElementsTableView.contentSize;
    //    newContentSize.height += kKeyboardFrame;
    //    self.apvElementsTableView.contentSize = newContentSize;
    
    [self.apvElementsTableView setContentOffset:contentOffset animated:NO];
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
        //        [UIView animateWithDuration:kTableViewTransitionSpeed animations:^{
        //            CGSize newContentSize = self.apvElementsTableView.contentSize;
        //            newContentSize.height -= kKeyboardFrame;
        //            self.apvElementsTableView.contentSize = newContentSize;
        //        }];
        //
        UITableViewCell *cell;
        
        if(ISiOS8)
        {
            cell = (UITableViewCell*)textField.superview.superview;
            
        }
        else
            cell = (UITableViewCell*)textField.superview.superview.superview;
        
        NSIndexPath *indexPath = [self.apvElementsTableView indexPathForCell:cell];
        [self.apvElementsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
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
        rowCount = apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + galleyElementsArr.count + 5;
    }
    else
    {
        rowCount = liquidsElementsArr.count + mealsElementsArr.count  + 2;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    
    static NSString *headingCellCellID                      = @"HeadingCellCellID";
    static NSString *otherComboNumTextCellID                = @"OtherComboNumTextCellID";
    static NSString *otherComboNumTextCameraCellID          = @"OtherComboNumTextCameraCellID";
    static NSString *comboComboComboNumTextCameraCellID     = @"ComboComboComboNumTextCameraCellID";
    
    
    OffsetCustomCell                *cell = nil;
    OtherComboNumText               *otherComboNumTextCell = nil;
    AddRowCell                      *headingCell = nil;
    OtherComboNumTextCamera         *otherComboNumTextCameraCell = nil;
    ComboComboComboNumTextCamera    *comboComboComboNumTextCameraCell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_MATERIAL_APV_CAT"];
        }
        else if (indexPath.row == apvElementsArr.count + 1)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_CABIN"];
        }
        else if (indexPath.row == apvElementsArr.count + catElementsArr.count + 2)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_SECURITY"];
        }
        else if (indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_BATH"];
        }
        else if (indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_GALLEY"];
        }
        else if(indexPath.row < apvElementsArr.count + 1)
        {
            otherComboNumTextCameraCell = (OtherComboNumTextCamera *)[self createCellForTableView:tableView withCellID:otherComboNumTextCameraCellID];
            cell = otherComboNumTextCameraCell;
            otherComboNumTextCameraCell.indexPath = indexPath;
            
            //otherComboNumTextCameraCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCameraCell.amountTxt.delegate = self;
            otherComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            //otherComboNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.reportTxt.delegate = self;
            otherComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_MATERIAL_APV_CAT" content:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_MATERIAL_APV_CAT" content:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.delegate = self;
            otherComboNumTextCameraCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCameraCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCameraCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.elementTxt];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.reportTxt];
            otherComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherComboNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.alertComboView.delegate = self;
            otherComboNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            otherComboNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherComboNumTextCameraCell.cameraView.key = @"CAMERA";
            otherComboNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherComboNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.cameraView.delegate = self;
            otherComboNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherComboNumTextCameraCell.cameraView];
            if(otherComboNumTextCameraCell.cameraView.imageName==nil || [otherComboNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
            
        }
        else if(indexPath.row < apvElementsArr.count + catElementsArr.count + 2)
        {
            otherComboNumTextCameraCell = (OtherComboNumTextCamera *)[self createCellForTableView:tableView withCellID:otherComboNumTextCameraCellID];
            cell = otherComboNumTextCameraCell;
            otherComboNumTextCameraCell.indexPath = indexPath;
            
            //otherComboNumTextCameraCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCameraCell.amountTxt.delegate = self;
            otherComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            // otherComboNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.reportTxt.delegate = self;
            otherComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_CABIN" content:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_CABIN" content:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.delegate = self;
            otherComboNumTextCameraCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCameraCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCameraCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.elementTxt];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.reportTxt];
            otherComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];
            

            otherComboNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.alertComboView.delegate = self;
            otherComboNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            otherComboNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            
            otherComboNumTextCameraCell.cameraView.key = @"CAMERA";
            otherComboNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherComboNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.cameraView.delegate = self;
            otherComboNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherComboNumTextCameraCell.cameraView];
            if(otherComboNumTextCameraCell.cameraView.imageName==nil || [otherComboNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
        }
        else if(indexPath.row < apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3)
        {
            otherComboNumTextCell = (OtherComboNumText *)[self createCellForTableView:tableView withCellID:otherComboNumTextCellID];
            cell = otherComboNumTextCell;
            otherComboNumTextCell.indexPath = indexPath;
            
            //otherComboNumTextCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCell.amountTxt.delegate = self;
            otherComboNumTextCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            // otherComboNumTextCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_SECURITY" content:@"REPORT"];
            otherComboNumTextCell.reportTxt.delegate = self;
            otherComboNumTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_SECURITY" content:@"ELEMENT"];
            otherComboNumTextCell.elementTxt.delegate = self;
            otherComboNumTextCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCell.elementTxt];
            otherComboNumTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCell.reportTxt];
            otherComboNumTextCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherComboNumTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCell.alertComboView.delegate = self;
            otherComboNumTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCell.alertComboView];
            otherComboNumTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
        }
        else if(indexPath.row < apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4)
        {
            otherComboNumTextCameraCell = (OtherComboNumTextCamera *)[self createCellForTableView:tableView withCellID:otherComboNumTextCameraCellID];
            cell = otherComboNumTextCameraCell;
            otherComboNumTextCameraCell.indexPath = indexPath;
            
            //otherComboNumTextCameraCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCameraCell.amountTxt.delegate = self;
            otherComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            //otherComboNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.reportTxt.delegate = self;
            otherComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_BATH" content:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_BATH" content:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.delegate = self;
            otherComboNumTextCameraCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCameraCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            
            otherComboNumTextCameraCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCameraCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.elementTxt];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.reportTxt];
            otherComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherComboNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.alertComboView.delegate = self;
            otherComboNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            otherComboNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            otherComboNumTextCameraCell.cameraView.key = @"CAMERA";
            otherComboNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherComboNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.cameraView.delegate = self;
            otherComboNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherComboNumTextCameraCell.cameraView];
            if(otherComboNumTextCameraCell.cameraView.imageName==nil || [otherComboNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
        }
        else
        {
            otherComboNumTextCell = (OtherComboNumText *)[self createCellForTableView:tableView withCellID:otherComboNumTextCellID];
            cell = otherComboNumTextCell;
            otherComboNumTextCell.indexPath = indexPath;
            
            //otherComboNumTextCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCell.amountTxt.delegate = self;
            otherComboNumTextCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            //otherComboNumTextCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_GALLEY" content:@"REPORT"];
            otherComboNumTextCell.reportTxt.delegate = self;
            otherComboNumTextCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_APV" event:@"ELEMENT_GALLEY" content:@"ELEMENT"];
            otherComboNumTextCell.elementTxt.delegate = self;
            otherComboNumTextCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            otherComboNumTextCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCell.elementTxt];
            otherComboNumTextCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCell.reportTxt];
            otherComboNumTextCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherComboNumTextCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCell.alertComboView.delegate = self;
            otherComboNumTextCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCell.alertComboView];
            otherComboNumTextCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
        }
    }
    else
    {
        
        if(indexPath.row == 0)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_LIQUIDS"];
        }
        else if (indexPath.row == liquidsElementsArr.count + 1)
        {
            headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
            headingCell.headingLbl.text = [appDel copyTextForKey:@"ELEMENT_MEALS"];
        }
        else if(indexPath.row < liquidsElementsArr.count + 1)
        {
            otherComboNumTextCameraCell = (OtherComboNumTextCamera *)[self createCellForTableView:tableView withCellID:otherComboNumTextCameraCellID];
            cell = otherComboNumTextCameraCell;
            otherComboNumTextCameraCell.indexPath = indexPath;
            
            //otherComboNumTextCameraCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            otherComboNumTextCameraCell.amountTxt.delegate = self;
            otherComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            otherComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            //otherComboNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            
            otherComboNumTextCameraCell.reportTxt.delegate = self;
            otherComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_CATERING" event:@"ELEMENT_LIQUIDS" content:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
            otherComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            //wrong
            otherComboNumTextCameraCell.elementTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_CATERING" event:@"ELEMENT_LIQUIDS" content:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.delegate = self;
            otherComboNumTextCameraCell.elementTxt.typeOfDropDown = OtherDropDown;
            otherComboNumTextCameraCell.elementTxt.key = [appDel copyEnglishTextForKey:@"ELEMENT"];
            otherComboNumTextCameraCell.elementTxt.selectedTextField.tag = MANDATORYTAG;
            
            
            otherComboNumTextCameraCell.elementLbl.attributedText = [[[appDel copyTextForKey:@"ELEMENT"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            otherComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            otherComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            otherComboNumTextCameraCell.elementTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.elementTxt];
            otherComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.reportTxt];
            otherComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.amountTxt];
            otherComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

            otherComboNumTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"OBSERVATION"];
            otherComboNumTextCameraCell.alertComboView.typeOfDropDown = AlertDropDown;
            otherComboNumTextCameraCell.alertComboView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.alertComboView.delegate = self;
            otherComboNumTextCameraCell.alertComboView.selectedValue = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            otherComboNumTextCameraCell.alertComboView.notesView.text = [self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView];
            
            if([self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] == NULL || [[self getContentInFormDictForView:otherComboNumTextCameraCell.alertComboView] isEqualToString:@""])
            {
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_empty"]];
            }
            else
                [otherComboNumTextCameraCell.commentBtn setImage:[UIImage imageNamed:@"icon_comment_filled"]];
            
            
            otherComboNumTextCameraCell.cameraView.key = @"CAMERA";
            otherComboNumTextCameraCell.cameraView.typeOfDropDown = CameraDropDown;
            otherComboNumTextCameraCell.cameraView.selectedTextField.hidden = YES;
            otherComboNumTextCameraCell.cameraView.delegate = self;
            otherComboNumTextCameraCell.cameraView.imageName=[self getContentInFormDictForView:otherComboNumTextCameraCell.cameraView];
            if(otherComboNumTextCameraCell.cameraView.imageName==nil || [otherComboNumTextCameraCell.cameraView.imageName isEqualToString:@""]){
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [otherComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
        }
        else
        {
            comboComboComboNumTextCameraCell = (ComboComboComboNumTextCamera *)[self createCellForTableView:tableView withCellID:comboComboComboNumTextCameraCellID];
            cell = comboComboComboNumTextCameraCell;
            comboComboComboNumTextCameraCell.indexPath = indexPath;
            //comboComboComboNumTextCameraCell.amountTxt.inputAccessoryView = [self keyboardToolBar];
            comboComboComboNumTextCameraCell.amountTxt.keyboardType = UIKeyboardTypeNumberPad;
            comboComboComboNumTextCameraCell.amountTxt.delegate = self;
            comboComboComboNumTextCameraCell.amountTxt.accessibilityIdentifier = [appDel copyEnglishTextForKey:@"AMOUNT"];
            comboComboComboNumTextCameraCell.amountTxt.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
            
            //comboComboComboNumTextCameraCell.amountTxt.tag = MANDATORYTAG;
            
            comboComboComboNumTextCameraCell.serviceTxt.typeOfDropDown = NormalDropDown;
            comboComboComboNumTextCameraCell.serviceTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_CATERING" event:@"ELEMENT_MEALS" content:@"SERVICE"];
            comboComboComboNumTextCameraCell.serviceTxt.delegate = self;
            comboComboComboNumTextCameraCell.serviceTxt.key = [appDel copyEnglishTextForKey:@"SERVICE"];
            comboComboComboNumTextCameraCell.serviceTxt.selectedTextField.tag = MANDATORYTAG;
            
            comboComboComboNumTextCameraCell.optionTxt.typeOfDropDown = OtherDropDown;//Changing to other =====Palash
            comboComboComboNumTextCameraCell.optionTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_CATERING" event:@"ELEMENT_MEALS" content:@"OPTION"];
            comboComboComboNumTextCameraCell.optionTxt.delegate = self;
            comboComboComboNumTextCameraCell.optionTxt.key = [appDel copyEnglishTextForKey:@"OPTION"];
            comboComboComboNumTextCameraCell.optionTxt.selectedTextField.tag = MANDATORYTAG;
            
            
            comboComboComboNumTextCameraCell.reportTxt.typeOfDropDown = NormalDropDown;
            comboComboComboNumTextCameraCell.reportTxt.dataSource = [self getDropDownDataForGroup:@"ELEMENT_CATERING" event:@"ELEMENT_MEALS" content:@"REPORT"];
            comboComboComboNumTextCameraCell.reportTxt.delegate = self;
            comboComboComboNumTextCameraCell.reportTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
            comboComboComboNumTextCameraCell.reportTxt.selectedTextField.tag = MANDATORYTAG;
            
            
            comboComboComboNumTextCameraCell.serviceLbl.attributedText = [[[appDel copyTextForKey:@"SERVICE"] stringByAppendingString:@"*"] mandatoryString];
            comboComboComboNumTextCameraCell.optionLbl.attributedText = [[[appDel copyTextForKey:@"OPTION"] stringByAppendingString:@"*"] mandatoryString];
            comboComboComboNumTextCameraCell.reportLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
            comboComboComboNumTextCameraCell.amountLbl.text = [appDel copyTextForKey:@"AMOUNT"];
            comboComboComboNumTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
            
            comboComboComboNumTextCameraCell.serviceTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.serviceTxt];
            comboComboComboNumTextCameraCell.optionTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.optionTxt];
            comboComboComboNumTextCameraCell.reportTxt.selectedTextField.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.reportTxt];
            comboComboComboNumTextCameraCell.amountTxt.text = [self getContentInFormDictForView:comboComboComboNumTextCameraCell.amountTxt];
            comboComboComboNumTextCameraCell.amountTxt.font=[UIFont fontWithName:KFontName size:14.0];

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
//                [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
                [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

            }
            else{
//                [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
                [comboComboComboNumTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

                
            }
            
        }
        
        
    }
    
    if(headingCell)
    {
        cell = headingCell;
        cell.indexPath = indexPath;
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
    else if([cellID isEqualToString:@"OtherComboNumTextCellID"])
    {
        OtherComboNumText *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherComboNumText" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    else if([cellID isEqualToString:@"ComboComboComboNumTextCameraCellID"])
    {
        ComboComboComboNumTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ComboComboComboNumTextCamera" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
        }
        return cell;
        
    }
    else
    {
        OtherComboNumTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherComboNumTextCamera" owner:self options:nil];
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
        sectionTitle = [appDel copyTextForKey:@"ELEMENT_APV"];
    }
    else if (section == 1)
    {
        sectionTitle = [appDel copyTextForKey:@"ELEMENT_CATERING"];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0 || indexPath.row == apvElementsArr.count + 1 || indexPath.row == apvElementsArr.count + catElementsArr.count  + 2 || indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3 || indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4 )
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
        if(indexPath.row == 0 || indexPath.row == liquidsElementsArr.count + 1 || indexPath.row == liquidsElementsArr.count + mealsElementsArr.count  + 2)
        {
            height = 64.0;
            
        }
        else
        {
            height = 69.0;
        }
        
        
    }
    
    height = 44; //Added Pavan
    return height;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [currentTxtField resignFirstResponder];
    int row = 0;
    NSString *sectionName;
    NSString *rowName = @"";
    NSIndexPath *modifiedIndexpath;
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_APV"];
            if(indexPath.row <= apvElementsArr.count )
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"];
                row = indexPath.row;
                [apvElementsArr removeObjectAtIndex:apvElementsArr.count  - indexPath.row];
                
                
            }
            else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_CABIN"];
                row = indexPath.row - (apvElementsArr.count + 1);
                [catElementsArr removeObjectAtIndex:apvElementsArr.count + catElementsArr.count + 1 - indexPath.row];
                
            }
            else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"];
                row = indexPath.row - (apvElementsArr.count + catElementsArr.count + 2);
                [securityElementsArr removeObjectAtIndex:apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 2 - indexPath.row ];
                
            }
            else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 3)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_BATH"];
                row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3);
                [bathElementsArr removeObjectAtIndex:apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 3 - indexPath.row ];
                
            }
            else if(indexPath.row <= apvElementsArr.count + catElementsArr.count + securityElementsArr.count +  bathElementsArr.count + galleyElementsArr.count + 4)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
                row = indexPath.row - (apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4);
                
                [galleyElementsArr removeObjectAtIndex:apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + galleyElementsArr.count + 4 - indexPath.row ];
                
            }
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_CATERING"];
            if(indexPath.row <= liquidsElementsArr.count )
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"];
                row = indexPath.row;
                [liquidsElementsArr removeObjectAtIndex:liquidsElementsArr.count  - indexPath.row];
                
            }
            else if(indexPath.row <= liquidsElementsArr.count + mealsElementsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MEALS"];
                row = indexPath.row - (liquidsElementsArr.count + 1);
                [mealsElementsArr removeObjectAtIndex:liquidsElementsArr.count + mealsElementsArr.count + 1 - indexPath.row];
                
            }
            
            
        }
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        //[cellArr removeObjectAtIndex:row - 1];
        if([[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"]){
            
            NSString *imageName = [[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"];
            
            [self deleteImage:imageName];
        }
        [cellArr removeObjectAtIndex:row - 1];
        
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        
        [self.apvElementsTableView beginUpdates];
        [self.apvElementsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.apvElementsTableView endUpdates];
        
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        
        //if([LTSingleton getSharedSingletonInstance].sendReport){
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        //}
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_APV"];
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"];
                [apvElementsArr addObject:@"1"];
            }
            else if(indexPath.row == apvElementsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_CABIN"];
                [catElementsArr addObject:@"1"];
            }
            else if(indexPath.row == apvElementsArr.count + catElementsArr.count + 2)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_SECURITY"];
                [securityElementsArr addObject:@"1"];
            }
            else if(indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_BATH"];
                [bathElementsArr addObject:@"1"];
            }
            else if(indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_GALLEY"];
                [galleyElementsArr addObject:@"1"];
            }
            
            
        }
        else
        {
            sectionName = [appDel copyEnglishTextForKey:@"ELEMENT_CATERING"];
            if(indexPath.row == 0 )
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"];
                [liquidsElementsArr addObject:@"1"];
            }
            else if(indexPath.row == liquidsElementsArr.count + 1)
            {
                rowName = [appDel copyEnglishTextForKey:@"ELEMENT_MEALS"];
                [mealsElementsArr addObject:@"1"];
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
        //[cellArr addObject:cellDict]; [cellArr insertObject:cellDict atIndex:0];
        //        [cellArr addObject:cellDict];
        [cellArr insertObject:cellDict atIndex:0];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [self.apvElementsTableView beginUpdates];
        [self.apvElementsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.apvElementsTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
       [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
       
        //if([LTSingleton getSharedSingletonInstance].sendReport){
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        //}
        
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
        if(indexPath.row == 0 || indexPath.row == apvElementsArr.count + 1 || indexPath.row == apvElementsArr.count + catElementsArr.count  + 2 || indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + 3 || indexPath.row == apvElementsArr.count + catElementsArr.count + securityElementsArr.count + bathElementsArr.count + 4 )
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
        
        if(indexPath.row == 0 || indexPath.row == liquidsElementsArr.count + 1 || indexPath.row == liquidsElementsArr.count + mealsElementsArr.count  + 2)
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



- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [appDel copyTextForKey:@"TABLEVIEW_DELETE"];
}
@end
