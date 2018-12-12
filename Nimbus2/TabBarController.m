//
//  TabBarController.m
//  Nimbus2
//
//  Created by 720368 on 7/13/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "TabBarController.h"
#import "LegViewController.h"
#import "FlightReportViewController.h"
#import "LTSingleton.h"
#import "SaveFlightData.h"
#import "ManualViewController.h"
#import "CUSReportImages.h"

@interface TabBarController ()
{
    FlightReportViewController *flightReportViewController;
    GADViewController *gadVC;
}
@property (nonatomic) IBOutlet NSLayoutConstraint *legWidth;
@property (nonatomic) IBOutlet NSLayoutConstraint *backButtonLeadingSpaceConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *manualButtonTrailingSpaceConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *manualButtonLeadingSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gadCenterConstraintY;


@property (nonatomic) BOOL animating;

@end

@implementation TabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        self.detailViewLeadingConstraint.constant = 0;
        self.detailViewBottomConstraint.constant = 125;
        
        _bgView.image = nil;
        [_bgView  setImage:[UIImage imageNamed:@"N__0008_Background_port.png"]];
        _landscapeView.hidden = YES;
        _portraitView.hidden = NO;
        _legWidth.constant = 405;
        self.selectedButton=self.flightButton;
        self.flightButton.selected = YES;
        self.flightButton.userInteractionEnabled = NO;
        _backButtonLeadingSpaceConstraint.constant = 2.0f;
        _manualButtonTrailingSpaceConstraint.constant = 2.0f;
        _manualButtonLeadingSpaceConstraint.constant = 0.0f;
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        self.detailViewLeadingConstraint.constant = 80;
        self.detailViewBottomConstraint.constant = 0;
        
        _bgView.image = nil;
        [_bgView  setImage:[UIImage imageNamed:@"N__0008_Background.png"]];
        self.selectedButton=self.flightPortraitButton;
        _portraitView.hidden = YES;
        _landscapeView.hidden = NO;
        _legWidth.constant = 640;
        _backButtonLeadingSpaceConstraint.constant = 8.0f;
        _manualButtonTrailingSpaceConstraint.constant = 14.0f;
        _manualButtonLeadingSpaceConstraint.constant = 10.0f;

        self.flightPortraitButton.selected = YES;
        self.flightPortraitButton.userInteractionEnabled = NO;
    }
    self.selectedTabIndex = 1;
    self.legScrollView.pagingEnabled=TRUE;
    self.legScrollView.type = iCarouselTypeLinear;
    self.legScrollView.clipsToBounds = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollCarousal:) name:@"ContentScroll" object:nil];
    NSDictionary *flightKeyDict = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
    self.flightNumberLabel.text = [NSString stringWithFormat:@"%@ %@",[flightKeyDict objectForKey:@"airlineCode"],[flightKeyDict objectForKey:@"flightNumber"]];
    
    // Do any additional setup after loading the view from its nib.
    vc = [[FlightDetailsViewController alloc] initWithNibName:@"FlightDetailsViewController" bundle:nil];
    [self addChildViewController:vc];
    
    previousViewController = vc;
    vc.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    [self.containerView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.flightLabel.text = [appDel copyTextForKey:@"TAB_FLIGHT"];
    self.crewLabel.text = [appDel copyTextForKey:@"TAB_CREW"];
    self.seatLabel.text = [appDel copyTextForKey:@"TAB_SEAT"];
    self.reportLabel.text = [appDel copyTextForKey:@"TAB_REPORT"];
    self.flightLabelPortrait.text = [appDel copyTextForKey:@"TAB_FLIGHT"];
    self.crewLabelPortrait.text = [appDel copyTextForKey:@"TAB_CREW"];
    self.seatLabelPortrait.text = [appDel copyTextForKey:@"TAB_SEAT"];
    self.reportLabelPortrait.text = [appDel copyTextForKey:@"TAB_REPORT"];
    [LTSingleton getSharedSingletonInstance].legNumber = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    //adding view to scroll
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.selectedButton setSelected:YES];
}

- (void)viewDidLayoutSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        previousViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    });
}

- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (statusVC !=nil) {
            statusVC.view.frame = self.view.frame;
        }
        if (gadVC != nil) {
            UIViewController *vc2= self.navigationController.topViewController;
            gadVC.view.frame = vc2.view.frame;
            [gadVC updateFrames];
            [gadVC.view layoutSubviews];
        }

        [self.view layoutSubviews];
    });
}

-(void)orientationChanged:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        tempViewController = [self.childViewControllers objectAtIndex:0];
        previousViewController = tempViewController;
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            
            self.detailViewLeadingConstraint.constant = 0;
            self.detailViewBottomConstraint.constant = 125;
            
            _bgView.image = nil;
            [_bgView  setImage:[UIImage imageNamed:@"N__0008_Background_port.png"]];
            self.selectedButton.selected = NO;
            _landscapeView.hidden = YES;
            _portraitView.hidden = NO;
            self.selectedButton = (UIButton*)[_portraitView viewWithTag:_selectedTabIndex];
            _legWidth.constant = 405;
            self.selectedButton.selected = YES;
            _backButtonLeadingSpaceConstraint.constant = 2.0f;
            _manualButtonTrailingSpaceConstraint.constant = 2.0f;
            _manualButtonLeadingSpaceConstraint.constant = 0.0f;
            
        }
        else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            
            self.detailViewLeadingConstraint.constant = 80;
            self.detailViewBottomConstraint.constant = 0;
            
            _bgView.image = nil;
            [_bgView  setImage:[UIImage imageNamed:@"N__0008_Background.png"]];
            self.selectedButton.selected = NO;
            _portraitView.hidden = YES;
            _landscapeView.hidden = NO;
            self.selectedButton = (UIButton*)[_landscapeView viewWithTag:_selectedTabIndex];
            self.selectedButton.selected = YES;
            _legWidth.constant = 640;
            _backButtonLeadingSpaceConstraint.constant = 8.0f;
            _manualButtonTrailingSpaceConstraint.constant = 14.0f;
            _manualButtonLeadingSpaceConstraint.constant = 10.0f;
        }
        
        [self.view layoutIfNeeded];
        [self animateSelector:self.selectedButton];
    });
    
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.selectedIndex==4) {
        [self reportButtonClicked:self.reportButton];
    }
}

-(void)animateSelector:(UIButton*)button {
    
    UIImageView *selectorImageTemp = nil;
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        selectorImageTemp = self.selectorImagePortrait;
    }else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        selectorImageTemp = self.selectorImage;
    }
    
    CGRect frame = selectorImageTemp.frame;
    CGRect frame1 = frame;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        frame.size.width = 140;
        frame1.size.width = 140;
        frame1.origin.x = button.frame.origin.x;
        
        if (frame.origin.x > button.frame.origin.x) {
            frame.size.width -= 20;
            frame.origin.x = button.frame.origin.x - 20;
        } else {
            frame.size.width -= 20;
            frame.origin.x = button.frame.origin.x + 30;
        }
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        frame.size.height = 140;
        frame1.size.height = 140;
        frame1.origin.y = button.frame.origin.y;
        
        if (frame.origin.y > button.frame.origin.y) {
            frame.size.height -= 20;
            frame.origin.y = button.frame.origin.y - 20;
        }else{
            frame.size.height -= 20;
            frame.origin.y = button.frame.origin.y + 30;
        }
        
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        selectorImageTemp.frame= frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            selectorImageTemp.frame= frame1;
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayContentController: (UIViewController*) content; {
    previousViewController = content;
    [self addChildViewController:content];                 // 1
    [self.containerView addSubview:content.view];
    [content didMoveToParentViewController:self];          // 3
}

- (void) hideContentController: (UIViewController*) content {
    [content willMoveToParentViewController:nil];  // 1
    [content.view removeFromSuperview];            // 2
    [content removeFromParentViewController];      // 3
}

- (IBAction)statusButtonClicked:(id)sender {
    statusVC = [[SynchStatusViewController alloc] initWithNibName:@"SynchStatusViewController" bundle:nil];
    statusVC.delegate=self;
    statusVC.isSingleFlight=YES;
    statusVC.view.frame = self.view.frame;
    
    [self addChildViewController:statusVC];
    [self.view addSubview:statusVC.view];
    [statusVC didMoveToParentViewController:self];
}
-(void)closePopOverforObject:(UIViewController*)VC{
    [VC willMoveToParentViewController:nil];  // 1
    [VC.view removeFromSuperview];            // 2
    [VC removeFromParentViewController];
    VC=nil;// 3
}

-(void)scrollToCUSReportFromVC:(UIViewController *)VC forFlight:(NSMutableDictionary *)flightDict andCUSDict:(NSDictionary*)cusDict {
    [self closePopOverforObject:VC];
    CUSReportViewController *CUSVC = [[CUSReportViewController alloc] initWithNibName:@"CUSReportViewController" bundle:nil];
    
    if ([[cusDict objectForKey:@"status"] integerValue]==draft || [[cusDict objectForKey:@"status"] integerValue]==0 || [[cusDict objectForKey:@"status"] integerValue] == eror) {
        CUSVC.readonly = NO;
    } else {
        CUSVC.readonly = YES;
        
    }
    
    NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
    if ([numJSB integerValue]==0) {
        CUSVC.readonly=YES;
    }
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    
    Customer *currentCustomer = [UserInformationParser getCustomerForFlight:flightDict andCusyomerDict:cusDict forMoc:managedObjectContext];
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"reportId==%@",[cusDict objectForKey:@"reportId"]];
    CusReport *report = [[[currentCustomer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];
    NSMutableDictionary *cusDict1 = [[NSMutableDictionary alloc] init];
    [cusDict1 setObject:currentCustomer.firstName forKey:@"FIRST_NAME"];
    [cusDict1 setObject:currentCustomer.lastName forKey:@"LAST_NAME"];
    if(currentCustomer.secondLastName)
        [cusDict1 setObject:currentCustomer.secondLastName forKey:@"SECOND_LAST_NAME"];
    if (currentCustomer.date) {
        [cusDict1 setObject:currentCustomer.date forKey:@"DATE"];
    }
    if (currentCustomer.seatNumber) {
        [cusDict1 setObject:currentCustomer.seatNumber forKey:@"SEAT_NUMBER"];
    }
    if(currentCustomer.docType){
        [cusDict1 setObject:currentCustomer.docType forKey:@"DOCUMENT_TYPE"];
        [cusDict1 setObject:currentCustomer.docNumber forKey:@"DOCUMENT_NUMBER"];
    }
    if(currentCustomer.freqFlyerNum)
        [cusDict1 setObject:currentCustomer.freqFlyerNum forKey:@"FREQUENTFLYER_NUMBER"];
    if(currentCustomer.freqFlyerCategory)
        [cusDict1 setObject:currentCustomer.freqFlyerCategory forKey:@"FREQUENTFLYER_CATEGORY"];
    if (currentCustomer.language) {
        [cusDict1 setObject:currentCustomer.language forKey:@"LANGUAGE"];
    }
    if (currentCustomer.address) {
        [cusDict1 setObject:currentCustomer.address forKey:@"ADDRESS"];
    }
    if (currentCustomer.email) {
        [cusDict1 setObject:currentCustomer.email forKey:@"EMAIL"];
    }
    if (currentCustomer.customerId) {
        [cusDict1 setObject:currentCustomer.customerId forKey:@"CUSTOMERID"];
    }
    if (report.reportId) {
        [cusDict1 setObject:report.reportId forKey:@"REPORTID"];
    }
    
    CUSReportImages *cusimages;
    if (report.reportCusImages) {
        cusimages = [[CUSReportImages alloc] init];
        cusimages.image1 = report.reportCusImages.image1;
        cusimages.image2 = report.reportCusImages.image2;
        cusimages.image3 = report.reportCusImages.image3;
        cusimages.image4 = report.reportCusImages.image4;
        cusimages.image5 = report.reportCusImages.image5;
        
        
    }
    NSMutableDictionary *flightRoster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    if([cusDict1[@"DOCUMENT_NUMBER"] isEqualToString:@""]) {
        cusDict1[@"DOCUMENT_NUMBER"] = currentCustomer.freqFlyerNum;
    }
    
    CUSVC.customerDict = cusDict1;
    CUSVC.customer = currentCustomer;
    CUSVC.flightDict = flightRoster;
    CUSVC.cusReportImages = cusimages;
    CUSVC.report = report;
    
    UIViewController *vc1 = self.navigationController.topViewController;
    [vc1 addChildViewController:CUSVC];
    
    [self.navigationController.topViewController.view addSubview:CUSVC.view];
    [CUSVC didMoveToParentViewController:vc1];
}

-(void)scrollToFlightReportFromVC:(UIViewController*)VC forFlight:(NSDictionary*)flightDict{
    [self closePopOverforObject:VC];
    [self reportButtonClicked:self.reportButton];
}

-(void)scrollToGADReportFromVC:(UIViewController *)VC forFlight:(NSDictionary *)flightDict andGADDict:(NSDictionary*)gadDict {
    [self closePopOverforObject:VC];
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *fDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    NSString *materialType = [UserInformationParser getMaterialType:fDict[@"material"]];
    if(materialType == nil || (![materialType isEqualToString:@"NB"] && ![materialType isEqualToString:@"WB"])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"RELOAD_FLIGHT_ALERT"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightKey.airlineCode == %@ AND flightKey.flightDate==%@ AND flightKey.flightNumber==%@",[flightDict objectForKey:@"airlineCode"],[flightDict objectForKey:@"flightDate"],[flightDict objectForKey:@"flightNumber"]];
    //    NSArray *filterArray = [self.flightArray filteredArrayUsingPredicate:predicate];
    //    if ([filterArray count]>0) {
    GADViewController *gadVC = [[GADViewController alloc] initWithNibName:@"GADViewController" bundle:nil];
    NSString * name = [[gadDict valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[gadDict   valueForKey:@"lastName"]]];
    
    gadVC.bpIDforCrew = [gadDict valueForKey:@"bp"];
    NSMutableArray *legArr = [[NSMutableArray alloc] init];
    NSArray *temparr = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"legs"];
    NSMutableDictionary *legDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"origin":[gadDict objectForKey:@"legOrigin"], @"destination":[gadDict objectForKey:@"legDestination"], @"legArrivalLocal":[gadDict objectForKey:@"legArrivalLocal"], @"legDepartureLocal":[gadDict objectForKey:@"legDepartureLocal"]}];
    [legArr addObject:legDict];
    gadVC.legArray = legArr;
    NSInteger sections = gadVC.GADTableView.numberOfSections;
    if([[gadDict objectForKey:@"status"] intValue] < 2){
        gadVC.isForReport = YES;
        gadVC.sendBtn.hidden = YES;
        for (int section = 0; section < sections; section++) {
            NSInteger rows = [gadVC.GADTableView numberOfRowsInSection:section];
            for (int row = 0; row < rows; row++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                UITableViewCell *cell = [gadVC.GADTableView cellForRowAtIndexPath:indexPath];//**here, for those cells not in current screen, cell is nil**
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setUserInteractionEnabled:NO];
            }
        }
    }
    
    else {
        gadVC.isForReport = NO;
    }
    
    UIViewController *vc1= self.navigationController.topViewController;
    [vc1 addChildViewController:gadVC];
    [self.navigationController.topViewController.view addSubview:gadVC.view];
    [gadVC didMoveToParentViewController:vc1];

    gadVC.indexForLeg=[[gadDict objectForKey:@"legNumber"] integerValue];
    
    gadVC.designationLabel.text = [gadDict valueForKey:@"activeRank"];
    
    gadVC.crewNumberLabel.text = [gadDict valueForKey:@"specialRank"];
    gadVC.crewFirstName = [gadDict valueForKey:@"firstName"];
    gadVC.crewLastName = [gadDict   valueForKey:@"lastName"];
    gadVC.crewNameLabel.text = name;
    gadVC.bpIdLabel.text =[gadDict valueForKey:@"bp"];
    
    [gadVC.GADTableView reloadData];
    [self updatePopupFrame];
}

- (IBAction)backButtonClicked:(id)sender {
    [LTSingleton getSharedSingletonInstance].sendReport = NO;
    [self saveDraft];
    [[LTSingleton getSharedSingletonInstance].legExecutedDict removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)manualButtonClicked:(id)sender {
    ManualViewController *manual = [[ManualViewController alloc] initWithNibName:@"ManualViewController" bundle:nil];
    [self.navigationController pushViewController:manual animated:YES];
}

- (void)saveDraft {
    
    int index = kCurrentLegNumber;  
    if(index < 0 || index >= [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] count]) {
        index = 0;
    }
    
    NSMutableDictionary *legsDictionary =[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:index];
    if([[legsDictionary objectForKey:@"reports"] count] > 0 &&
       [[[[legsDictionary objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] count] > 0 &&
       [[[[[[legsDictionary objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] count] > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[legsDictionary objectForKey:@"destination"] forKey:@"destination"];
        [dict setObject:[legsDictionary objectForKey:@"origin"] forKey:@"origin"];
        [SaveFlightData saveEventWithFlightRoasterDict:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:dict];
    }
}

- (void)deselectPreviousTabButtonIndex: (NSInteger)index {
    UIButton *btnLandscape = (UIButton*)[_landscapeView viewWithTag:index];
    btnLandscape.selected = NO;
    btnLandscape.userInteractionEnabled = YES;
    
    UIButton *btnPortrait = (UIButton*)[_portraitView viewWithTag:index];
    btnPortrait.selected = NO;
    btnPortrait.userInteractionEnabled = YES;
}

- (void)selectTabButton: (UIButton*)btn {
    if (_selectedTabIndex != [btn tag]) {
        [self deselectPreviousTabButtonIndex:_selectedTabIndex];
    }
    _selectedTabIndex = [btn tag];
    self.selectedButton = btn;
    self.selectedButton.userInteractionEnabled=FALSE;
    [self animateSelector:self.selectedButton];
    self.selectedButton.selected=TRUE;
}

- (IBAction)flightButtonClicked:(id)sender {
    if (vc == nil) {
        vc = [[FlightDetailsViewController alloc] initWithNibName:@"FlightDetailsViewController" bundle:nil];
    }
    vc.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self selectTabButton:(UIButton*)sender];
    [self hideContentController:previousViewController];
    [self displayContentController:vc];
}

- (IBAction)crewButtonClicked:(id)sender {
    
    if (cvc == nil) {
        cvc = [[CrewViewController alloc] initWithNibName:@"CrewViewController" bundle:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SeatButtonClicked" object:nil];
        [cvc updateCurrentViewFrame];
    }
    cvc.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self selectTabButton:(UIButton*)sender];
    [self hideContentController:previousViewController];
    [self displayContentController:cvc];
}

- (IBAction)seatButtonClicked:(id)sender {
    
    if (svc == nil) {
        svc = [[SeatMapViewController alloc] initWithNibName:@"SeatMapViewController" bundle:nil];
    }
    
    svc.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self selectTabButton:(UIButton*)sender];
    [self hideContentController:previousViewController];
    [self displayContentController:svc];
}

- (IBAction)reportButtonClicked:(id)sender {
    if (flightReportViewController == nil) {
        flightReportViewController = [[FlightReportViewController alloc] initWithNibName:@"FlightReportViewController" bundle:nil];
    }
    flightReportViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self selectTabButton:(UIButton*)sender];
    [self hideContentController:previousViewController];
    [self displayContentController:flightReportViewController];
}

-(void)scrollCarousal:(NSNotification*)notification{
    NSDictionary *dic = notification.userInfo;
    NSInteger index = [[dic objectForKey:@"index"] integerValue];
    [self.legScrollView scrollToItemAtIndex:index animated:YES];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return [[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"legs"] count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    LegViewController *legVC = [[LegViewController alloc] initWithNibName:@"LegViewController" bundle:nil];
    legVC.index=index;
    return legVC.view;
    //    return view;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 3;
}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 70)];
    }
    else {
        
    }
    
    return view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.legScrollView.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return FALSE;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.legScrollView.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    
    NSNotification *notification = [[NSNotification alloc] initWithName:@"TabLegScroll" object:nil userInfo:@{@"index":@(self.legScrollView.currentItemIndex)}];
    
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    
    [LTSingleton getSharedSingletonInstance].legNumber = [@(self.legScrollView.currentItemIndex) intValue];
}

@end
