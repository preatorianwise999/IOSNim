//
//  TDOMEconomyCabConditionViewController.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TDOMEconomyCabConditionViewController.h"
#import "AddRowCell.h"
#import "OtherTextCamera.h"
#import "NSString+Validation.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"
#import "LTGetDropDownvalue.h"



@interface TDOMEconomyCabConditionViewController ()<UITextFieldDelegate,PopoverDelegate>
{
    UITextField *currentTxtField;
    NSMutableArray *groupArr;
    AppDelegate *appDel;
    NSDictionary *dropDownDict;
}

@property(nonatomic,weak)IBOutlet UITableView *stateCabConditionTableView;
@property(nonatomic,weak) IBOutlet UILabel *headlingLbl;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end

@implementation TDOMEconomyCabConditionViewController
@synthesize stateCabConditioningArr;
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
    self.tableView = self.stateCabConditionTableView;
    self.ipArray = [[NSMutableArray alloc] init];
    self.leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    [self.stateCabConditionTableView setEditing:YES animated:YES];
    [self initializeIndexPathArray];
    headlingLbl.textColor=kFontColor;
    [headlingLbl setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    self.headlingLbl.text = [appDel copyTextForKey:@"CONDITIONING_CAB"];

    CGRect frame = headlingLbl.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    headlingLbl.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    

    _stateCabConditionTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Internal Methods
//Initialize data esp group array and drop down dictionary
- (void)initializeData
{
    
    
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.headlingLbl.text = [appDel copyTextForKey:@"CONDITIONING_CAB"];
    
    stateCabConditioningArr    = [[NSMutableArray alloc] init];
    
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    groupArr = [[NSMutableArray alloc]init];
    if(flightRoasterDraft != nil)
    {
        groupArr = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
        for(NSDictionary *groupDict in groupArr)
        {
            NSString *sectionName = [groupDict objectForKey:@"name"];
            
            for(NSString *rowName in [[groupDict objectForKey:@"multiEvents"] allKeys])
            {
                for(NSDictionary *rowDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:rowName])
                {
                    DLog(@"%@",rowDict);
                    if([sectionName isEqualToString:[appDel copyEnglishTextForKey:@"CONDITIONING_CAB"]])
                    {
                        
                        if([rowName isEqualToString:[appDel copyEnglishTextForKey:@"CAB_STATECAB"]] )
                        {
                            [stateCabConditioningArr addObject:@"1"];
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
        
        NSMutableDictionary *stateCabConditionDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableArray alloc] init],  nil] forKeys:[[NSMutableArray alloc] initWithObjects:[appDel copyEnglishTextForKey:@"CAB_STATECAB"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:[appDel copyEnglishTextForKey:@"CONDITIONING_CAB"] forKey:@"name"];
        [groupDict setObject:stateCabConditionDict forKey:@"multiEvents"];
        [groupArr addObject:groupDict];
        
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
    
    NSDictionary *flightRoaster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    NSString *type = [flightRoaster objectForKey:@"flightReportType"];
    NSString *report = [[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"name"];
    NSString *section = [[[[[[[flightRoaster objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"name"];
    
    
    dropDownDict = [LTGetDropDownvalue getDictForReportType:type FlightReport:report Section:section];
}

-(NSArray *)getDropDownDataForGroup:(NSString *)group event:(NSString *)event content:(NSString *)content
{
    return [[[dropDownDict objectForKey:[appDel copyEnglishTextForKey:group]]objectForKey:[appDel copyEnglishTextForKey:event]] objectForKey:[appDel copyEnglishTextForKey:content]];
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    
    rowCount = stateCabConditioningArr.count + 1;
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(indexPath.row > [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
        return nil;
    }
    
    static NSString *headingCellCellID            = @"HeadingCellCellID";
    static NSString *otherTextCameraCellID        = @"OtherTextCameraCellID";
    
    OffsetCustomCell *cell = nil;
    AddRowCell *headingCell = nil;
    OtherTextCamera *otherTextCameraCell = nil;
    
    if(indexPath.row == 0)
    {
        headingCell = (AddRowCell *)[self createCellForTableView:tableView withCellID:headingCellCellID];
        headingCell.headingLbl.text = [appDel copyTextForKey:@"CAB_STATECAB"];
    }
    else
    {
        otherTextCameraCell = (OtherTextCamera *)[self createCellForTableView:tableView withCellID:otherTextCameraCellID];
        
        
    }
    
    if(headingCell)
    {
        cell = headingCell;
        headingCell.indexPath = indexPath;
    }
    else if(otherTextCameraCell)
    {
        cell = otherTextCameraCell;
        otherTextCameraCell.indexPath = indexPath;
        
        otherTextCameraCell.reasonTxt.typeOfDropDown = OtherDropDown;
        otherTextCameraCell.reasonTxt.dataSource = [self getDropDownDataForGroup:@"CONDITIONING_CAB" event:@"CAB_STATECAB" content:@"REPORT"];
        otherTextCameraCell.reasonTxt.delegate = self;
        otherTextCameraCell.reasonTxt.key = [appDel copyEnglishTextForKey:@"REPORT"];
        otherTextCameraCell.reasonTxt.selectedTextField.tag = MANDATORYTAG;
        
        otherTextCameraCell.reasonLbl.attributedText = [[[appDel copyTextForKey:@"OCCURRENCE_TAM"] stringByAppendingString:@"*"] mandatoryString];
        otherTextCameraCell.observationLbl.text = [appDel copyTextForKey:@"OBSERVATION"];
        
        otherTextCameraCell.reasonTxt.selectedTextField.text = [self getContentInFormDictForView:otherTextCameraCell.reasonTxt];
        
        otherTextCameraCell.alertComboView.key = [appDel copyEnglishTextForKey:@"GENERAL_OBSERVATIONS"];
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
//            [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraBtn"]];
            [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_empty"]];

        }
        else{
//            [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"cameraFill"]];
            [otherTextCameraCell.cameraImageView setImage:[UIImage imageNamed:@"icon_camera_filled"]];

            
        }
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
    else
    {
        OtherTextCamera *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherTextCamera" owner:self options:nil];
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
    NSString *rowName = @"";
    NSIndexPath *modifiedIndexpath;
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"CONDITIONING_CAB"];
            rowName = [appDel copyEnglishTextForKey:@"CAB_STATECAB"];
            row = indexPath.row;
            [stateCabConditioningArr removeObjectAtIndex:indexPath.row - 1];
            
        }
        
        NSMutableDictionary *groupDict = [[groupArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",sectionName]] objectAtIndex:0];
        NSMutableDictionary *eventDict = [groupDict objectForKey:@"multiEvents"];
        if([[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"]){
            
            NSString *imageName = [[[eventDict objectForKey:rowName] objectAtIndex:row-1] objectForKey:@"CAMERA"];
            
            [self deleteImage:imageName];
        }
        NSMutableArray *cellArr = [eventDict objectForKey:rowName];
        [cellArr removeObjectAtIndex:row - 1];
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.hidden = YES;
        
        [self.stateCabConditionTableView beginUpdates];
        [self.stateCabConditionTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.stateCabConditionTableView endUpdates];
        if (!ISiOS8) {
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        }
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(updateReportDictionary) withObject:nil afterDelay:0.3 ];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        if (indexPath.section == 0)
        {
            sectionName = [appDel copyEnglishTextForKey:@"CONDITIONING_CAB"];
            rowName = [appDel copyEnglishTextForKey:@"CAB_STATECAB"];
            [stateCabConditioningArr addObject:@"1"];
            
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
        [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
        
        modifiedIndexpath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
        
        
        [self.stateCabConditionTableView beginUpdates];
        [self.stateCabConditionTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.stateCabConditionTableView endUpdates];
        
        NSArray *t= [tableView visibleCells];
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
        sectionTitle = [appDel copyTextForKey:@"CAB_STATECAB"];
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
    
    if(indexPath.row == 0)
    {
//        height = 64.0;
         height = 44.0;
    }
    else
    {
//        height = 69.0;
        height = 44.0;
    }
    
    return height;
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
        [self.stateCabConditionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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
        sectionName = [appDel copyEnglishTextForKey:@"CONDITIONING_CAB"];
        rowName = [appDel copyEnglishTextForKey:@"CAB_STATECAB"];
        row = indexPath.row;
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
    
    int row = 0;
    
    NSString *sectionName;
    NSString *rowName=@"";
    
    if (indexPath.section == 0)
    {
        sectionName = [appDel copyEnglishTextForKey:@"CONDITIONING_CAB"];
        
        rowName = [appDel copyEnglishTextForKey:@"CAB_STATECAB"];
        row = indexPath.row;
        
        
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
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;    currentTxtField = textField;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:self.stateCabConditionTableView];
    CGPoint contentOffset = self.stateCabConditionTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    CGSize newContentSize = self.stateCabConditionTableView.contentSize;
    newContentSize.height += kKeyboardFrame;
    self.stateCabConditionTableView.contentSize = newContentSize;
    
    [self.stateCabConditionTableView setContentOffset:contentOffset animated:NO];
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
    
    id textfieldCellRef;
    if(ISiOS8)
    {
        textfieldCellRef = textField.superview.superview;
        
    }
    else
        textfieldCellRef = textField.superview.superview.superview;
    
    if ([textfieldCellRef isKindOfClass:[UITableViewCell class]])
    {
        [UIView animateWithDuration:kTableViewTransitionSpeed animations:^{
            CGSize newContentSize = self.stateCabConditionTableView.contentSize;
            newContentSize.height -= kKeyboardFrame;
            self.stateCabConditionTableView.contentSize = newContentSize;
        }];
        
        UITableViewCell *cell;
        
        if(ISiOS8)
        {
            cell = (UITableViewCell*)textField.superview.superview;
            
        }
        else
            cell = (UITableViewCell*)textField.superview.superview.superview;
        
        NSIndexPath *indexPath = [self.stateCabConditionTableView indexPathForCell:cell];
        [self.stateCabConditionTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
    return YES;
}
@end
