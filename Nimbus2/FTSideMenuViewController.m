//
//  FTSideMenuViewController.m
//  Nimbus2
//
//  Created by Vishal on 28/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FTSideMenuViewController.h"
#import "FlightReportViewController.h"
#import "CrewDataViewController.h"
#import "SideMenuSectionTableViewCell.h"
#import "SideMenuRowTableViewCell.h"
#import "AppDelegate.h"
#import "LTSingleton.h"

#import "NBEconomyElementAPVViewController.h"
#import "LTSingleton.h"
#import "AppDelegate.h"
#import "NSDate+DateFormat.h"


#import "AlertUtils.h"
#import "SaveFlightData.h"


//Image Names

#define GENERALINFO @"General_Info.png"
#define BOARDING @"Boarding.png"
#define OVERVIEW @"Overview.png"
#define DUTYFREE @"Dutyfree.png"
#define SUGGESTIONS @"Suggestions.png"

#define AIRPORT @"Airport.png"
#define ELEMENTAPV @"APV.png"
#define CABIN @"Cabin.png"
#define CCABIN @"Ccab.png"
#define IFE @"IFE.png"
#define QUALITY @"Quality_Service.png"


@interface FTSideMenuViewController () {
    FlightReportViewController *flightReportViewController;
    NSMutableArray *expandedArray;
    NSMutableArray *sectionArray;
    NSIndexPath *selectedIndexPath;
    NSMutableDictionary * flightReportDictionary;
    AppDelegate *appDel;
    
    NSMutableDictionary *imagesDictionary;
    
    BOOL statusChanged;
    UIView *animateView ;
    
    __weak IBOutlet NSLayoutConstraint *tableViewLeftConstraint;
    __weak IBOutlet NSLayoutConstraint *tableViewWidthConstraint;
}
@end

@implementation FTSideMenuViewController
@synthesize delegate,flightType,sectionArray,flightReportDictionary,roaster,isLegPressedFirstTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)formImageDictionary {
    imagesDictionary = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:GENERALINFO,BOARDING,OVERVIEW,DUTYFREE,SUGGESTIONS,AIRPORT,ELEMENTAPV,CABIN,CCABIN,IFE,QUALITY, nil] forKeys:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Dutyfree",@"Suggestions",@"Airport",@"Elements & CAT APV",@"Cabin",@"Conditioning Cab",@"IFE",@"Quality Service CAT", nil]];
}

-(BOOL)hasDefaultMandatoryFields:(NSString *)controller {
    
    if([roaster.type containsString:@"TAM"]) {
        if([controller isEqualToString:[appDel copyEnglishTextForKey:@"General Information"]] || [controller isEqualToString:[appDel copyEnglishTextForKey:@"Boarding"]] || [controller isEqualToString:[appDel copyEnglishTextForKey:@"Dutyfree"]] || [controller isEqualToString:@"Overview"]) {
            return YES;
        }
    }
    else {
        if([controller isEqualToString:[appDel copyEnglishTextForKey:@"General Information"]] || [controller isEqualToString:[appDel copyEnglishTextForKey:@"Boarding"]] || [controller isEqualToString:[appDel copyEnglishTextForKey:@"Dutyfree"]] || [controller isEqualToString:@"Overview"]) {
            return YES;
        }
    }
    return NO;
}

//Report dictionary - to indicate mandatory fields
-(void)initializeReportDictionary {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Highlight.plist"];
    NSMutableDictionary *highlightingDict = [NSMutableDictionary dictionaryWithContentsOfFile:appFile];
    if(!highlightingDict){
        highlightingDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString *flightDate = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] dateFormat:DATE_FORMAT_yyyy_MM_dd_HH_mm_ss];
    NSString *flightKey = [[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]] stringByAppendingString:flightDate];
    
    if([highlightingDict objectForKey:flightKey]) {
        [LTSingleton getSharedSingletonInstance].reportDictionary = [NSMutableDictionary dictionaryWithDictionary:[highlightingDict objectForKey:flightKey]];
    }
    else {
        [LTSingleton getSharedSingletonInstance].reportDictionary = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *rootDict = [[NSMutableDictionary alloc] init];
        for(NSString *section in sectionArray){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for(NSString *subSection in [flightReportDictionary objectForKey:section]) {
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                if([self hasDefaultMandatoryFields:subSection]){
                    for(int i=0;i<[LTSingleton getSharedSingletonInstance].legCount;i++) {
                        [arr addObject:[NSNumber numberWithInt:i+1]];
                    }
                }
                [dict setObject:arr forKey:subSection];
                
            }
            [rootDict setObject:dict forKey:section];
        }
        [highlightingDict setObject:rootDict forKey:flightKey];
        
        [LTSingleton getSharedSingletonInstance].reportDictionary = [NSMutableDictionary dictionaryWithDictionary:rootDict];
        
        [highlightingDict writeToFile:appFile atomically:YES];
    }
}

-(void)statusChanged:(NSNotification *)notification {
    NSInteger status = [[[notification userInfo] objectForKey:@"status"] integerValue];
    [self changeStatusForStatus:status WithFlag:YES];
}

-(void)changeStatusForStatus:(NSInteger)status WithFlag:(BOOL)flag {
    [[LTSingleton getSharedSingletonInstance].flightRoasterDict setObject:[NSNumber numberWithInt:status] forKey:@"status"];
    if(status != 0 && status != draft) {
        self.reportButton.hidden = YES;
        
        self.sendIcon.hidden = YES;
        //        status = eror;
        if(status == inqueue || status == received || status == sent || status == ok || status == ea || status== ee || status == wf) {
            [self.view addSubview:_viewSummaryView];
            CGRect fr = _viewSummaryView.frame;
            fr.origin = CGPointMake(4, 575);
            _viewSummaryView.frame = fr;
            [LTSingleton getSharedSingletonInstance].enableCells = NO;
        }
        
        else if(status == eror) {
            if(_viewSummaryView) {
                [_viewSummaryView removeFromSuperview];
            }
            [_viewSummaryView setHidden:YES];
            [_viewSummaryBtn setHidden:YES];
            [_reportButton setHidden:YES];
            [self.view addSubview:_bothSummarySendView];
            CGRect fr = _bothSummarySendView.frame;
            fr.origin = CGPointMake(0, 575);
            _bothSummarySendView.frame = fr;
            [LTSingleton getSharedSingletonInstance].enableCells = YES;
            
        }
        statusChanged = YES;
        if(flag) {
            [self tableView:_reportTableView didSelectRowAtIndexPath:selectedIndexPath];
        }
        [_reportTableView reloadData];
    }
    else {
        self.reportButton.hidden =NO;
        //        self.sendIcon.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLegPressedFirstTime = YES;
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [_reportButton setTitle:[appDel copyTextForKey:@"SEND_REPORT"] forState:UIControlStateNormal];
    [_reportButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_reportButton.titleLabel setFont:KRobotoFontSize14];
    
    [_viewSummaryBtn setTitle:[appDel copyTextForKey:@"VIEW_SUMMARY"] forState:UIControlStateNormal];
    [_viewSummaryBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_viewSummaryBtn.titleLabel setFont:KRobotoFontSize16];
    
    [_viewSummaryResendBtn setTitle:[appDel copyTextForKey:@"VIEW_SUMMARY"] forState:UIControlStateNormal];
    [_viewSummaryResendBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_viewSummaryResendBtn.titleLabel setFont:KRobotoFontSize12];
    
    [_resendReportBtn setTitle:[appDel copyTextForKey:@"RESEND_REPORT"] forState:UIControlStateNormal];
    [_resendReportBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [_resendReportBtn.titleLabel setFont:KRobotoFontSize12];
    statusChanged = NO;
    
    _sideMenu_TableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    _bothSummarySendView.backgroundColor = [UIColor clearColor];
    
    expandedArray = [[NSMutableArray alloc] init];
    flightReportDictionary = [[NSMutableDictionary alloc] init];
    [self formImageDictionary];
    NSInteger status = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"status"] integerValue];
    if(status != 0 && status != 1) {
        self.reportButton.hidden = YES;
        self.sendIcon.hidden = YES;
        
        if(status == 2 || status == 3 || status == 4 || status == ok || status == ea || status == ee || status==wf) {
            [LTSingleton getSharedSingletonInstance].enableCells = NO;
            [self.view addSubview:_viewSummaryView];
            CGRect fr = _viewSummaryView.frame;
            fr.origin = CGPointMake(0, 575);
            
            _viewSummaryView.frame = fr;
        }
        
        else if(status == 5) {
            [LTSingleton getSharedSingletonInstance].enableCells = YES;
            [self.view addSubview:_bothSummarySendView];
            CGRect fr = _bothSummarySendView.frame;
            fr.origin = CGPointMake(0, 575);

            _bothSummarySendView.frame = fr;
        }
    }
    else {
        self.reportButton.hidden = NO;
        self.sendIcon.hidden = NO;
    }
    
    if ([[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"] boolValue]==NO) {
        self.reportButton.hidden = YES;
        self.sendIcon.hidden = YES;
    }
    
    if([flightType isEqualToString:NBLAN]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"PREMIUM ECONOMY",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Dutyfree",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:1]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:2]];
    }
    else if([flightType isEqualToString:WBLAN]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Dutyfree",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin",@"IFE", nil] forKey:[sectionArray objectAtIndex:1]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin",@"IFE", nil] forKey:[sectionArray objectAtIndex:2]];
    }
    else if([flightType isEqualToString:DOMLAN]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:1]];
    }
    else if([flightType isEqualToString:NBTAM]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Dutyfree",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:1]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:2]];
    }
    else if([flightType isEqualToString:WBTAM]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Dutyfree",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin",@"IFE", nil] forKey:[sectionArray objectAtIndex:1]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin",@"IFE", nil] forKey:[sectionArray objectAtIndex:2]];
    }
    else if([flightType isEqualToString:DOMTAM]) {
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"ECONOMY",nil];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"General Information",@"Boarding",@"Overview",@"Suggestions", nil] forKey:[sectionArray objectAtIndex:0]];
        [flightReportDictionary setObject:[NSArray arrayWithObjects:@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin", nil] forKey:[sectionArray objectAtIndex:1]];
    }
    
    [self initializeReportDictionary];
    selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [_sideMenu_TableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self tableView:_sideMenu_TableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [self tableView:_sideMenu_TableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    [_sideMenu_TableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        tableViewLeftConstraint.constant=10;
    } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        tableViewLeftConstraint.constant=0;
    }
}

-(void)orientationChanged:(NSNotification *)notification {
    [self arrangeFramesOfItemsAccordingToOrientation];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view updateConstraints];
    });
}

-(void)arrangeFramesOfItemsAccordingToOrientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            tableViewWidthConstraint.constant = 230;
            self.footerBtnWidthConstraint.constant = 0;
            self.viewSummaryBtnWidthConstarint.constant = 230;
            _viewSummaryView.frame = CGRectMake(_viewSummaryView.frame.origin.x, _viewSummaryView.frame.origin.y - 10, 230, _viewSummaryView.frame.size.height);
            self.bothviewSummaryBtnWidthConstarint.constant = 110;
            self.bothviewresendBtnWidthConstarint.constant = 120;
            
            _bothSummarySendView.frame = CGRectMake(_bothSummarySendView.frame.origin.x, _bothSummarySendView.frame.origin.y - 10, 230, _bothSummarySendView.frame.size.height);
        }
        else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            tableViewWidthConstraint.constant = 180;
            self.footerBtnWidthConstraint.constant = 50;
            self.viewSummaryBtnWidthConstarint.constant = 180;
            _viewSummaryView.frame = CGRectMake(_viewSummaryView.frame.origin.x, _viewSummaryView.frame.origin.y - 10, 180, _viewSummaryView.frame.size.height);
            self.bothviewSummaryBtnWidthConstarint.constant = 90;
            self.bothviewresendBtnWidthConstarint.constant = 90;
            _bothSummarySendView.frame = CGRectMake(_bothSummarySendView.frame.origin.x, _bothSummarySendView.frame.origin.y - 10, 180, _bothSummarySendView.frame.size.height);
            //_viewSummaryResendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChanged:) name:kStatusChanged object:nil];
    [self orientationChanged:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

//Save form data whenever switching away from the form
- (void)saveDraft {
    NSMutableDictionary *legsDictionary = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber];
    
    if([[legsDictionary objectForKey:@"reports"] count]>0
       &&
       [[[[legsDictionary objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] count] > 0
       &&
       [[[[[[legsDictionary objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] count] > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[legsDictionary objectForKey:@"destination"] forKey:@"destination"];
        [dict setObject:[legsDictionary objectForKey:@"origin"] forKey:@"origin"];
        [SaveFlightData saveEventWithFlightRoasterDict:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:dict];
    }
}


-(void)loadSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(animateView) {
            [animateView removeFromSuperview];
        }
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
            
        } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        }
        
        [animateView setBackgroundColor:[UIColor blackColor]];
        animateView.alpha = 0.3;
        
        UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityInd.center = animateView.center;
        [animateView addSubview:activityInd];
        
        [activityInd startAnimating];
        
        [self.view.window addSubview:animateView];
    });
}

-(IBAction)summaryReport:(UIButton *)sender {
    [LTSingleton getSharedSingletonInstance].isFromViewSummary = NO;
    if([self.delegate respondsToSelector:@selector(viewSummarySelected)]) {
        [self.delegate viewSummarySelected];
    }
}

- (IBAction)resendReport:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(resendReport)]) {
        [self sendReport:nil];
    }
}

-(void)stopSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [animateView removeFromSuperview];
    });
}

#pragma mark - Alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        
        [LTSingleton getSharedSingletonInstance].isFromViewSummary = YES;
        
        if([self.delegate respondsToSelector:@selector(sendReportSelected)]) {
            [self.delegate sendReportSelected];
        }
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([expandedArray containsObject:[sectionArray objectAtIndex:section]]){
        return 1 + [[flightReportDictionary objectForKey:[sectionArray objectAtIndex:section]] count];
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SideMenuSectionTableViewCell *sectionTableViewCell = nil;
    SideMenuRowTableViewCell *rowTableViewCell = nil;
    
    UITableViewCell *cell;
    if(indexPath.row == 0) {
        
        sectionTableViewCell = (SideMenuSectionTableViewCell *)[self createCellForTableView:tableView withCellID:@"SideMenuSectionTableViewCell"];
        sectionTableViewCell.sectionTitle.text = [sectionArray objectAtIndex:indexPath.section];
        //      sectionTableViewCell.sectionTitle.textColor = kFlightReportCellTextColor;
        sectionTableViewCell.sectionTitle.font = KRobotoFontSize20;
        sectionTableViewCell.sectionTitle.text = [appDel copyTextForKey:[sectionArray objectAtIndex:indexPath.section]];
        cell = sectionTableViewCell;
    }
    else {
        
        rowTableViewCell = (SideMenuRowTableViewCell *)[self createCellForTableView:tableView withCellID:@"SideMenuRowTableViewCell"];
        rowTableViewCell.rowTitle.text = [[flightReportDictionary objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1];
        //        rowTableViewCell.rowTitle.textColor = kFlightReportCellTextColor;
        rowTableViewCell.rowTitle.font =  KRobotoFontSize14;
        
        NSString *key = [[flightReportDictionary objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1];
        
        rowTableViewCell.rowTitle.text = [appDel copyTextForKey:key];
        cell = rowTableViewCell;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //to save while switching from detail to master
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = YES;
    UIView *currentResponder = (UIView *)[[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)];
    [currentResponder resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:nil];
    [LTSingleton getSharedSingletonInstance].legPressed = NO;
    [self saveDraft];
    //end
    
    if(indexPath.row == 0) {
        NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [[flightReportDictionary objectForKey:[sectionArray objectAtIndex:indexPath.section]] count]; i++) {
            [indexPathArray addObject:[NSIndexPath indexPathForItem:i + 1 inSection:indexPath.section]];
        }
        
        if([expandedArray containsObject:[sectionArray objectAtIndex:indexPath.section]]) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:0.25 animations:^{((UIButton *)[cell viewWithTag:1000]).transform = CGAffineTransformMakeRotation(M_PI);}];
            
            [expandedArray removeObject:[sectionArray objectAtIndex:indexPath.section]];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
            [tableView endUpdates];
            [tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:0.25 animations:^{((UIButton *)[cell viewWithTag:1000]).transform = CGAffineTransformMakeRotation(0);}];
            
            [expandedArray addObject:[sectionArray objectAtIndex:indexPath.section]];
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
            [tableView endUpdates];
            
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else {
        if(indexPath.section == selectedIndexPath.section && indexPath.row == selectedIndexPath.row && !statusChanged){
            return;
        }
        if(!self.isLegPressedFirstTime) {
            [NSThread detachNewThreadSelector:@selector(loadSpinner) toTarget:self withObject:nil];
        }
        
        selectedIndexPath = indexPath;
        for (int i = 0; i < [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] count]; i++) {
            NSMutableArray *sectionArr = [[NSMutableArray alloc]init];
            NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc]init];
            [sectionDict setObject:[appDel copyEnglishTextForKey:[[flightReportDictionary objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1]] forKey:@"name"];
            [sectionDict setObject:[[NSMutableArray alloc] init] forKey:@"groups"];
            [sectionArr addObject:sectionDict];
            
            NSMutableArray *reportArr = [[NSMutableArray alloc]init];
            NSMutableDictionary *reportDict = [[NSMutableDictionary alloc]init];
            [reportDict setObject:[sectionArray objectAtIndex:indexPath.section] forKey:@"name"];
            [reportDict setObject:[[NSMutableArray alloc] init] forKey:@"sections"];
            [reportArr addObject:reportDict];
            
            
            [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:i] setObject:reportArr forKey:@"reports"];
            
            [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] objectAtIndex:0] setObject:sectionArr forKey:@"sections"];
        }
        
        selectedIndexPath = indexPath;
        
        [self.delegate didSelectSectionAtIndex:[sectionArray objectAtIndex:indexPath.section] flightType:flightType selection:[[flightReportDictionary objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1] ]; //atIndex:0
        
        
        DLog(@"didSelectSectionAtIndex %s ",__PRETTY_FUNCTION__);
        
        if(!self.isLegPressedFirstTime) {
            if([LTSingleton getSharedSingletonInstance].sendReport)
                [self performSelector:@selector(stopSpinner) withObject:nil afterDelay:0.4];
            else
                [self performSelector:@selector(stopSpinner) withObject:nil afterDelay:0.1];
        }
        self.isLegPressedFirstTime = NO;
        return;
    }
}

- (UITableViewCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID {
    if([cellID isEqualToString:@"SideMenuSectionTableViewCell"]){
        SideMenuSectionTableViewCell* sectionTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuSectionTableViewCell"];
        if (sectionTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SideMenuSectionTableViewCell" owner:self options:nil];
            sectionTableViewCell = [topLevelObjects objectAtIndex:0];
            sectionTableViewCell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        return sectionTableViewCell;
    }
    
    else if ([cellID isEqualToString:@"SideMenuRowTableViewCell"]) {
        SideMenuRowTableViewCell *rowTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuRowTableViewCell"];
        if (rowTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SideMenuRowTableViewCell" owner:self options:nil];
            rowTableViewCell = [topLevelObjects objectAtIndex:0];
            rowTableViewCell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        return rowTableViewCell;
    }
    return nil;
}

- (IBAction)sendReport:(UIButton *)sender {
    NSMutableDictionary *flightRoasterDict  = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([[flightRoasterDict objectForKey:@"isManualyEntered"] intValue] == manuFlightErrored) {
        [AlertUtils showErrorAlertWithTitle:[apDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"ALERT_SENDERRORREPORT"]];
        return;
    }
    NSDate *currentDate = [NSDate date];
    NSMutableDictionary *legAtCurrentIndex  = [[flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber];
    double diff = [[legAtCurrentIndex objectForKey:@"departureLocal"] timeIntervalSinceDate:currentDate];
    
    if(diff > 0) {
        [AlertUtils showErrorAlertWithOKCancel:[apDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"ALERT_FLIGHTNOTDEPARTED"] withDelegate:self];
        return;
    }
    if([flightRoasterDict objectForKey:@"isManualyEntered"])
        [LTSingleton getSharedSingletonInstance].isFromViewSummary = YES;
    
    if([self.delegate respondsToSelector:@selector(sendReportSelected)]) {
        [self.delegate sendReportSelected];
    }
}

@end
