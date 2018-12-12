//
//  TAMSuggestionsViewController.m
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TAMSuggestionsViewController.h"
#import "OnlyTextViewCell.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetLightData.h"

@interface TAMSuggestionsViewController ()
{
    NSMutableArray *sectionArray;
    UITextView *currentTxtField;
    AppDelegate *appDel;
    NSMutableArray *groupArr;
}

@end

@implementation TAMSuggestionsViewController


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
    NSDictionary *flightRoasterDraft = [LTGetLightData getFormReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict forIndex:kCurrentLegNumber];
    DLog(@"dict==%@",flightRoasterDraft);
    
    groupArr = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"];
    
    if ([groupArr count] == 0) {
        
        groupArr = [[NSMutableArray alloc]init];
        
        NSString *name = [[[[[[[flightRoasterDraft objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
        
        NSMutableDictionary *groupDict;
        
        NSMutableDictionary *vueloDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSMutableString alloc] init],[[NSMutableString alloc] init],[[NSMutableString alloc] init] , nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"],[appDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"],[appDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"], nil]];
        
        groupDict = [[NSMutableDictionary alloc] init];
        [groupDict setObject:name forKey:@"name"];
        [groupDict setObject:vueloDict forKey:@"singleEvents"];
        [groupArr addObject:groupDict];
        
    }
    
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = _suggestionsTableView;

    _headingLabel.textColor=kFontColor;
    CGRect frame = _headingLabel.frame;
    frame.origin.y=kyposition_NB_LAN_General;//pass the cordinate which you want
    frame.origin.x=kxposition_NB_LAN_General;
    _headingLabel.frame= frame;
    
    _header_Line.frame = CGRectMake(15, 37,560,8);
    [_headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:25.0]];
    sectionArray = [[NSMutableArray alloc] initWithObjects:[appDel copyTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"],[appDel copyTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"],[appDel copyTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"], nil];
    self.headingLabel.text = [appDel copyTextForKey:@"Suggestions"];
    [self cellsForTableView:_suggestionsTableView];
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

-(BOOL)mandatoryCellsContainsData{
    
    for(int j=0;j<[self.tableView numberOfSections];j++){
        for(int i=0;i<[self.tableView numberOfRowsInSection:j];i++)
        {
            OnlyTextViewCell *cell = (OnlyTextViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:j]];
            if([cell.textView.text isEqualToString:@""]|| [[cell.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
                return NO;
            }
        }
    }
    
    return YES;
}



#pragma mark - Form Saving Methods

-(NSString *)getContentInFormDictForView:(id)view
{
    NSString *value;
    
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OnlyTextViewCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OnlyTextViewCell *)[[[view superview] superview] superview]).indexPath;
    
    NSString *rowName=@"";
    if(indexPath.section == 0){
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"];
    }
    else if(indexPath.section == 1){
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"];
    }
    else{
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"];
    }
    
    NSMutableDictionary *groupDict = [groupArr  objectAtIndex:0];
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
    value = [eventDict objectForKey:rowName];
    return value;
}


-(void)setContentInFormDictForView:(id)view
{
    NSIndexPath *indexPath;
    if(ISiOS8)
        indexPath = ((OnlyTextViewCell *)[[view superview] superview]).indexPath;
    else
        indexPath = ((OnlyTextViewCell *)[[[view superview] superview] superview]).indexPath;
    
    if(indexPath == nil)
    return;
    
    NSString *rowName=@"";
    
    if(indexPath.section == 0){
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"];
    }
    else if(indexPath.section == 1){
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"];
    }
    else{
        rowName =[appDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"];
    }
    
    NSMutableDictionary *groupDict = [groupArr objectAtIndex:0];
    NSMutableDictionary *eventDict = [groupDict objectForKey:@"singleEvents"];
    [eventDict setObject:((UITextView *)view).text forKey:rowName];
    [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber]  objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
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
    OnlyTextViewCell *cell;
    if(ISiOS8)
        cell = ((OnlyTextViewCell *)[[currentTxtField superview] superview]);
    else
        cell = ((OnlyTextViewCell *)([[[currentTxtField superview] superview] superview]));
    
    
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
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row - 1:[self.suggestionsTableView numberOfRowsInSection:section]-1;
                for(int row = rowVal;row >= 0;row--){
                    cell = (OnlyTextViewCell *)[self.suggestionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            for(int section = cell.indexPath.section ;section<[self.suggestionsTableView numberOfSections];section++){
                BOOL isNextFieldFound = NO;
                int rowVal;
                rowVal = (section == cell.indexPath.section)?rowVal=cell.indexPath.row+1:0;
                for(int row = rowVal;row < [self.suggestionsTableView numberOfRowsInSection:section];row++){
                    cell = (OnlyTextViewCell *)[self.suggestionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *concatText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if(range.location == 0 && [text isEqualToString:@" "])
        return NO;
    textView.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    if([text length] == 0 && range.location == 0 && [LTSingleton getSharedSingletonInstance].sendReport  && textView.tag == MANDATORYTAG){
        textView.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    if (concatText.length > TEXTVIEWLENGTH) {
        textView.text = [concatText substringToIndex:TEXTVIEWLENGTH];
        return NO;
    }
    
    
    return YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    id refrence;
    if(ISiOS8)
        refrence = [[textView superview] superview];
    else
        refrence = [[[textView superview] superview] superview];
    
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    
    currentTxtField = textView;
    CGPoint pointInTable = [refrence convertPoint:textView.frame.origin toView:self.suggestionsTableView];
    CGPoint contentOffset = self.suggestionsTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset + 55);
    
    [UIView beginAnimations:@"tableviewAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [self.suggestionsTableView setContentOffset:contentOffset animated:NO];
    [UIView commitAnimations];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    textView.text = [textView.text substringToIndex: MIN(255, [textView.text length])];
    
    id refrence;
    if(ISiOS8)
        refrence = [[textView superview] superview];
    else
        refrence = [[[textView superview] superview] superview];
    
    
    if([LTSingleton getSharedSingletonInstance].legPressed == YES) {
        [self setContentInFormDictForView:textView];
    }
    else {
        return;
    }
    
    if([LTSingleton getSharedSingletonInstance].isFromMasterScreen == YES) {
        [LTSingleton getSharedSingletonInstance].isFromMasterScreen = NO;
        return;
    }
    
    if ([refrence isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)refrence;
        NSIndexPath *indexPath = [self.suggestionsTableView indexPathForCell:cell];
        [self.suggestionsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - tableview methods
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([LTSingleton getSharedSingletonInstance].sendReport && !([NSStringFromClass([cell class]) isEqualToString:@"AddRowCell"])) {
        self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] validateCell:(OffsetCustomCell *)cell withLeastIndexPath:self.leastIndexPath];
        DLog(@"ID:%@",self.leastIndexPath);
    }
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OnlyTextViewCell *cell;
    static NSString *Cellidentifer = @"OnlyTextViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifer];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OnlyTextViewCell" owner:self options:nil] objectAtIndex:0];
    }
    ((OnlyTextViewCell *)cell).textView.delegate = self;
    cell.indexPath = indexPath;
    ((OnlyTextViewCell *)cell).textView.text = [self getContentInFormDictForView:((OnlyTextViewCell *)cell).textView] ;

    BOOL temp = [LTSingleton getSharedSingletonInstance].enableCells;
    [cell setUserInteractionEnabled:temp];
    cell.contentView.alpha = 0.439216f;

    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];;

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    headerView.backgroundColor = [UIColor colorWithRed:246.0f/256.0 green:246.0f/256 blue:246.0f/256 alpha:1];
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kSectionalFooterImage]];
    imageView.frame = CGRectMake(41, 0, kSectionalFooterWidth , 3);
    [imageView setBackgroundColor:[UIColor clearColor]];
    [footerView addSubview:imageView];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
