//
//  FlightViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightViewController.h"
#import "ManualViewController.h"
#import "TestView.h"
#import "SMPageControl.h"
#import "Customer.h"
#import "NSDate+Utils.h"
#import "LTCUSData.h"

@interface FlightViewController (){
    UIViewController *oldChild;
    UIViewController *newChild;
    IBOutlet SMPageControl *_pageController;
    IBOutlet UILabel *pageIndicatorLbl;
    IBOutlet UIImageView *backgroundImage;
}

@property (weak, nonatomic) IBOutlet UIButton *notJsbBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateDataBtn;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (strong, nonatomic) StoreManuals *storeManuals;
@property (nonatomic) BOOL showDropView;
@property (nonatomic) IBOutlet NSLayoutConstraint *addFlightLeadingSpaceConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *ManualBtnLeadingSpaceConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *ManualBtnTrailingSpaceConstraint;


@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL isActive;

@end

@implementation FlightViewController


- (void)setUp {
    //set up data
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // pageControl.frame = CGRectMake(200, 600, 620, 37);
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapOutside)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    SynchronizationController *sync = [[SynchronizationController alloc] init];
    if([sync checkForWifiAvailability]) {
        [self startDownloadingManuals];
    }
    
    self.statArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedSynchronizing) name:kNotifSyncFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(briefingDownloaded:) name:kNotifBriefingDownloaded object:nil];
    self.statArray = [UserInformationParser getStatusForAllFlights];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.userNameLabel.text = [LTSingleton getSharedSingletonInstance].user;
    [self.notJsbBtn setTitle:[appDel copyTextForKey:@"FVC_NOT_JSB"] forState:UIControlStateNormal];
    [self.notJsbBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.updateDataBtn setTitle:[appDel copyTextForKey:@"FVC_UPDATE_DATA"] forState:UIControlStateNormal];
    [self.updateDataBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    self.carousel.pagingEnabled=TRUE;
    self.carousel.type = iCarouselTypeCoverFlow;
    _dropDonwView = [[DropDownViewController alloc]initWithData:[NSArray arrayWithObjects:[appDel copyTextForKey:@"FVC_NOT_JSB"],[appDel copyTextForKey:@"FVC_UPDATE_DATA"],nil]];
    _dropDonwView.delegate = self;
    _dropDonwView.tableView.frame = CGRectMake(0, 0, 50, 50);
    self.languageSegment.transform = CGAffineTransformMakeScale(0.85, 0.65);
    [self.languageSegment.layer setBorderWidth:2.0];
    //[self.languageSegment.layer setBorderColor:self.languageSegment.backgroundColor.CGColor];
    
    LanguageSelected language = (LanguageSelected)[[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] integerValue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSpin) name:kServerSynchStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedSynchronizing) name:kServerSynchStop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    int selectedSegmentIndex = 0;
    if(language == LANG_PORTUGUESE) {
        selectedSegmentIndex = 1;
    }
    [self.languageSegment setSelectedSegmentIndex:selectedSegmentIndex];
    
    [self adjustLanguageLabelsForLanguage:language];
    
    self.dropDownPopoverController = [[UIPopoverController alloc] initWithContentViewController:_dropDonwView];
    manualFlight = [[AddManualFlightViewController alloc] initWithFlightDataObject:nil WithMode:Add];
    manualFlight.delegate=self;
    NSInteger nextFlyIndex = [self getIndexOfNextFly];
    
    if(noFlightForNext7days) {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"NEXT_FLIGHT"] message:[appDel copyTextForKey:@"ALERT_NO_NEXTFLY_7"]];
    }
    
    [self paintUserIcon];
    
    [self.carousel scrollToItemAtIndex:nextFlyIndex animated:NO];
    [self pageController];
    [self synchBtnClicked:nil];
    
    [self arrangeFramesOfItemsAccordingToOrientation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)startDownloadingManuals {
    
    if(!self.storeManuals) {
        self.storeManuals = [[StoreManuals alloc] init];
        self.storeManuals.delegate = self;
    }
    
    [self.storeManuals synchManualData];
}

-(void)arrangeFramesOfItemsAccordingToOrientation {
    
    void (^arrangeThings)(void) = ^{
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            _dropView.frame = CGRectMake(self.view.frame.size.width-150 - _dropView.frame.size.width, _carousel.frame.origin.y+50, _dropView.frame.size.width, _dropView.frame.size.height);
            if (statusVC) {
                statusVC.cancelBtn.frame = CGRectMake(statusVC.statusTableView.frame.origin.x + 5, statusVC.statusTableView.frame.origin.y + 2 , statusVC.cancelBtn.frame.size.width, statusVC.cancelBtn.frame.size.height);        }
            _nameLabelWidth.constant = 128;
            backgroundImage.image = [UIImage imageNamed:@"N__0007_Background.png"];
            _addFlightLeadingSpaceConstraint.constant = 3.0f;
            _ManualBtnLeadingSpaceConstraint.constant = 24.0f;
            _ManualBtnTrailingSpaceConstraint.constant = 14.0f;
        } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            
            _dropView.frame = CGRectMake(497, 428, _dropView.frame.size.width, _dropView.frame.size.height);
            
            if (statusVC) {
                statusVC.cancelBtn.frame = CGRectMake(statusVC.statusTableView.frame.origin.x + 5, statusVC.statusTableView.frame.origin.y + 2 , statusVC.cancelBtn.frame.size.width, statusVC.cancelBtn.frame.size.height);
            }
            
            backgroundImage.image = [UIImage imageNamed:@"N__0007_Background_port.png"];
            _nameLabelWidth.constant = 98;
            _addFlightLeadingSpaceConstraint.constant = -1.0f;
            _ManualBtnLeadingSpaceConstraint.constant = 9.0f;
            _ManualBtnTrailingSpaceConstraint.constant = 4.0f;
        }
    };
    
    if([NSThread isMainThread]) {
        arrangeThings();
    }
    
    else {
        dispatch_async(dispatch_get_main_queue(), arrangeThings);
    }
}

- (void)orientationChanged {
    if (!_dropView.hidden) {
        _dropView.hidden = YES;
        self.showDropView = YES;
    }
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
}

- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (manualFlight !=nil) {
            manualFlight.view.frame = self.view.frame;
        }
        if (statusVC !=nil) {
            statusVC.view.frame = self.view.frame;
        }
        UIButton *btn = (UIButton *) [_carousel.currentItemView viewWithTag:111];
        if (self.showDropView) {
            self.showDropView = NO;
            [self cardBtnPressedWithOutAnimation:btn];
        }
        [self.view layoutSubviews];
        [self arrangeFramesOfItemsAccordingToOrientation];
    });
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if(!self.langview.hidden && CGRectContainsPoint(self.langview.frame, [touch locationInView:self.view])) {
        return NO;
    }
    if(!self.dropView.hidden && CGRectContainsPoint(self.dropView.frame, [touch locationInView:self.view])) {
        return NO;
    }
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}

- (void)tapOutside {
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.dropView setAlpha:0.0];
        [self.langview setAlpha:0.0];
    } completion:^(BOOL finished) {
        self.dropView.hidden = YES;
        self.langview.hidden = YES;
    }];
}

//Calculate Index of Next Fly
- (NSInteger)getIndexOfNextFly {
    int minIndex = 0;
    if([self.flightArray count] > 0) {
        NSDate *currentDate = [NSDate date];
        NSDictionary *lastLeg;
        double min = 0;
        NSDate *bufferDate;
        int i;
        for (i = 0; i < [self.flightArray count]; i++) {
            NSDictionary *flightDict = [self.flightArray objectAtIndex:i];
            if ([[flightDict objectForKey:@"legs"] count] > 0) {
                lastLeg = [[flightDict objectForKey:@"legs"] objectAtIndex:[[flightDict objectForKey:@"legs"] count] - 1];
            }
            
            bufferDate = [[lastLeg objectForKey:@"arrivalLocal"] dateByAddingTimeInterval:2*60*60];
            min = [bufferDate timeIntervalSinceDate:currentDate];
            if(min > 0)
                break;
        }
        
        minIndex = i;
        for (; i < [self.flightArray count]; i++) {
            NSDictionary *flightDict = [self.flightArray objectAtIndex:i];
            if ([[flightDict objectForKey:@"legs"] count] > 0) {
                lastLeg = [[flightDict objectForKey:@"legs"] objectAtIndex:[[flightDict objectForKey:@"legs"] count] - 1];
            }
            
            bufferDate = [[lastLeg objectForKey:@"arrivalLocal"] dateByAddingTimeInterval:2*60*60];
            double currentmin = [bufferDate timeIntervalSinceDate:currentDate];
            if(currentmin < 0)
                continue;
            
            if (currentmin < min) {
                min = currentmin;
                minIndex = i;
            }
        }
        
        if(min >= 7*24*60*60) {
            noFlightForNext7days = YES;
        }
    }
    else {
        noFlightForNext7days = YES;
    }
    return MIN(minIndex, self.flightArray.count - 1);
}

-(void)finishedSyncingManualData {
    [self.storeManuals startDownloadingManuals];
}

-(void)finishedDownloadingManuals {
    
}

-(void)selectedValueInDropdown:(DropDownViewController *)obj{
    
}

- (void)pageController {
    
    _pageController.numberOfPages = [self.flightArray count];
    _pageController.indicatorMargin = 10.0f;
    _pageController.indicatorDiameter = 10.0f;
    _pageController.alignment = SMPageControlAlignmentCenter;
    [_pageController setPageIndicatorImage:[UIImage imageNamed:@"desel.png"]];
    [_pageController setCurrentPageIndicatorImage:[UIImage imageNamed:@"sel.png"]];
    _pageController.currentPage = self.carousel.currentItemIndex;
    //   [_pageController addTarget:self action:@selector(spacePageControl:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.animating = NO;
    self.isActive = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.isActive = YES;
    
    if([LTSingleton getSharedSingletonInstance].synchStatus && [self.flightArray count] > 0) {
        [self startSpin];
    } else {
        [LTSingleton getSharedSingletonInstance].synchStatus = NO;
    }
    self.statArray = [UserInformationParser getStatusForAllFlights];
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    self.flightArray = [synch getFlightroaster];
    
    [self updateCarousal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {
    return [self.flightArray count];
}


- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    if (index >= [self.flightArray count]) {
        return nil;
    }
    
    NSDictionary *flightDict = [self.flightArray objectAtIndex:index];
    NSArray *legArray = [flightDict objectForKey:@"legs"];
    NSInteger x = [legArray count];
    
    if (x == 1) {
        fcView = [[FlightCardViewController alloc] initWithNibName:@"FlightCardViewController" bundle:nil];
    } else if(x == 2) {
        fcView = [[FlightCardViewController alloc] initWithNibName:@"FlightCardViewController~2" bundle:nil];
    } else if (x == 3) {
        fcView = [[FlightCardViewController alloc] initWithNibName:@"FlightCardViewController~3" bundle:nil];
    } else if (x == 4) {
        fcView = [[FlightCardViewController alloc] initWithNibName:@"FlightCardViewController~4" bundle:nil];
    }
    fcView.flightDict = flightDict;
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSDictionary *flightKey = [flightDict objectForKey:@"flightKey"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"airlineCode == %@ AND flightDate==%@ AND flightNumber==%@",[flightKey objectForKey:@"airlineCode"],[flightKey objectForKey:@"flightDate"],[flightKey objectForKey:@"flightNumber"]];
    NSArray *filAry = [[self.statArray filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if ([[flightDict objectForKey:@"isManualyEntered"] intValue] > 0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(474, 22, 197, 41)];
        [button.titleLabel setFont:KRobotoFontSize18];
        [button setTitle:[appDel copyTextForKey:@"FLIGHT_MANUALLY_ADDED"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(editFlight) forControlEvents:UIControlEventTouchUpInside];
        [fcView.view addSubview:button];
        if ([[flightDict objectForKey:@"isManualyEntered"] intValue]==manuFlightErrored) {//error flight
            [button setTitle:[appDel copyTextForKey:@"INVALID_FLIGHT"] forState:UIControlStateNormal];
            [button setTitleColor:kManualFlightFontRed forState:UIControlStateNormal];
        }
        else {//good flight
            [button setTitleColor:kManualFlightFontBlue forState:UIControlStateNormal];
            if ([filAry count] > 0) {
                [button setEnabled:FALSE];
            }
        }
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(685, 20, 41, 43)];
    [button setImage:[UIImage imageNamed:@"cardButton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cardBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [fcView.view addSubview:button];
    
    NSDate *date = [flightDict objectForKey:@"lastSynchTime"];
    
    NSDateFormatter *dateDF = [[NSDateFormatter alloc] init];
    dateDF.dateFormat = @"dd-MM-yyyy";
    NSDateFormatter *timeDF = [[NSDateFormatter alloc] init];
    timeDF.dateFormat = @"HH:mm";
    
    fcView.lastSynchTime.text = [NSString stringWithFormat:@"%@ %@ %@ %@", [appDel copyTextForKey:@"FVC_UPDATED_ON"], [dateDF stringFromDate:date], [appDel copyTextForKey:@"FVC_UPDATED_AT"], [timeDF stringFromDate:date]];
    
    if ([[flightDict objectForKey:@"isPublicationSynched"] boolValue]) {
        [fcView.breifinInfoIndicator setAlpha:1.0];
    }
    if ([[flightDict objectForKey:@"isFlightSeatMapSynched"] boolValue]) {
        [fcView.seatMapIndicator setAlpha:1.0];
    }
    return fcView.view;
    
}

-(void)editFlight {
    manualFlight = [[AddManualFlightViewController alloc] initWithFlightDataObject:[self.flightArray objectAtIndex:self.carousel.currentItemIndex] WithMode:Modify];
    manualFlight.delegate=self;
    [self addChildViewController:manualFlight];
    UIViewController *vc= self.navigationController.topViewController;
    manualFlight.view.frame = vc.view.frame;
    [self.view addSubview:manualFlight.view];
    [manualFlight didMoveToParentViewController:self];
}

- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel {
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    //create new view if no view is available for recycling
    if (view == nil) {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 754, 348)];
    }
    else {
        //get a reference to the label in the recycled view
        //label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //label.text = (index == 0)? @"[": @"]";
    
    return view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return FALSE;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 4.05f;
        }
        case iCarouselOptionFadeMax: {
            if (self.carousel.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default: {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index>=[self.flightArray count]) {
        return;
    }
    if (!self.dropView.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.dropView setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.dropView.hidden=TRUE;
        }];
    }
    [self CarousalIdexSelectedForIndex:index forSelectedIndex:0];
}

-(void)CarousalIdexSelectedForIndex:(NSInteger)index forSelectedIndex:(NSInteger)sIndex {
    NSDictionary *flightDict = [self.flightArray objectAtIndex:index];
    NSDictionary *fkeyDict = [flightDict objectForKey:@"flightKey"];
    
    self.flightType = [flightDict objectForKey:@"flightReportType"];
    self.materialType = [flightDict objectForKey:@"materialType"];
    self.businessUnit = [flightDict objectForKey:@"businessUnit"];
    DLog(@"flight type : %@",self.flightType);
    [LTSingleton getSharedSingletonInstance].flightName= [NSString stringWithFormat:@"%@%@",[fkeyDict objectForKey:@"airlineCode"],[fkeyDict objectForKey:@"flightNumber"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    [LTSingleton getSharedSingletonInstance].flightDate = [dateFormatter stringFromDate:[fkeyDict objectForKey:@"flightDate"]];
    
    [LTSingleton getSharedSingletonInstance].materialType = [flightDict objectForKey:@"materialType"];
    if (self.flightArray.count > 0 && self.flightArray && [[self.flightArray objectAtIndex:index] count] > 0) {
        //        [LTSingleton getSharedSingletonInstance].legCount = [[[self.flightArray objectAtIndex:index]objectForKey:@"legs" ] count];
        
        NSDictionary *flightDict = [self.flightArray objectAtIndex:index];
        NSMutableArray *legsArrray = [flightDict objectForKey:@"legs"];
        [LTSingleton getSharedSingletonInstance].legCount = legsArrray.count;
    }
    
    //self.flightType = @"";
    if([[flightDict objectForKey:@"material"] isEqualToString:@""] || [flightDict objectForKey:@"material"] == nil || [self.businessUnit isEqualToString:@""] || self.businessUnit == nil ) {
        flightTypeMessageBox = [[FlightTypeMessageBox alloc] initWithNibName:@"FlightTypeMessageBox" bundle:nil];
        flightTypeMessageBox.modalPresentationStyle = UIModalPresentationFormSheet;
        flightTypeMessageBox.delegate = self;
        flightTypeMessageBox.airlineCode = [fkeyDict objectForKey:@"airlineCode"];
        
        NSString *businessUnitStr = @"";
        if([self.businessUnit containsString:@"INT"]) {
            businessUnitStr = LONGHAUL;
        }
        else if([self.businessUnit containsString:@"REG"]) {
            businessUnitStr = SHORTHAUL;
        }
        else if([self.businessUnit containsString:@"DOM"]) {
            businessUnitStr = DOMESTIC;
        }
        flightTypeMessageBox.bUnit = businessUnitStr;
        
        flightTypeMessageBox.materialVal = [flightDict objectForKey:@"material"];
        
        [self presentViewController:flightTypeMessageBox animated:YES completion:nil];
        flightTypeMessageBox.view.superview.bounds = CGRectMake(0, 0, 523, 270);
        if (ISiOS8) {
            flightTypeMessageBox.preferredContentSize = CGSizeMake(523, 270);
        }
    }
    else {
        NSDictionary *flightDict = [self.flightArray objectAtIndex:index];
        NSMutableArray *legsArrray = [flightDict objectForKey:@"legs"];
        
        for (int i = 0; i < [legsArrray count]; i++) {
            NSMutableDictionary *legsDict = [legsArrray objectAtIndex:i];
            if([[[[flightDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] count] > 0) {
                [[[[[[[[flightDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] removeAllObjects];
                
                [legsDict setObject:[[[flightDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] forKey:@"reports"];
            }
            else {
                [legsDict setObject:[[NSMutableArray alloc]init] forKey:@"reports"];
            }
        }
        
        [LTSingleton getSharedSingletonInstance].flightKeyDict = [flightDict mutableCopy];
        
        [LTSingleton getSharedSingletonInstance].flightRoasterDict = [flightDict mutableCopy];
        //[self flightSelected:index];
        TabBarController *tabVC = [[TabBarController alloc] initWithNibName:@"TabBarController" bundle:nil];
        tabVC.selectedTabIndex=sIndex;
        [self.navigationController pushViewController:tabVC animated:YES];
    }
}

//Setting flight type manually by calculting on the basis of business unit and material type
- (void)setFlightTypeManually:(NSString *)flightTypeStr andBusinessUnit:(NSString *)businessUnit andMaterialType:(NSString *)materialType {
    self.flightType = flightTypeStr;
    self.materialType = materialType;
    self.businessUnit = businessUnit;
    
    NSMutableDictionary *flightDict = [self.flightArray objectAtIndex:self.carousel.currentItemIndex];
    [flightDict setObject:flightTypeStr forKey:@"flightReportType"];
    [flightDict setObject:materialType forKey:@"material"];
    [flightDict setObject:[UserInformationParser getMaterialType:materialType] forKey:@"materialType"];
    [flightDict setObject:businessUnit forKey:@"businessUnit"];
    [LTSingleton getSharedSingletonInstance].flightRoasterDict = [flightDict mutableCopy];
    [LTSingleton getSharedSingletonInstance].flightKeyDict = [flightDict mutableCopy];
    [UserInformationParser updateFlightType:[LTSingleton getSharedSingletonInstance].flightRoasterDict];
    [flightTypeMessageBox dismissViewControllerAnimated:YES completion:nil];
    
    //Refresh Content
    TabBarController *tabVC = [[TabBarController alloc] initWithNibName:@"TabBarController" bundle:nil];
    [self.navigationController pushViewController:tabVC animated:YES];
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    NSLog(@"Index: %@ count=%d", @(self.carousel.currentItemIndex), [[self childViewControllers] count]);
    pageIndicatorLbl.text = [NSString stringWithFormat:@"%d of %d",self.carousel.currentItemIndex + 1, 4];
    [_pageController setPageIndicatorImage:[UIImage imageNamed:@"desel"]];
    [_pageController setCurrentPageIndicatorImage:[UIImage imageNamed:@"sel"]];
    _pageController.currentPage = self.carousel.currentItemIndex;
    
    [self reloadPageControllerView];
}

-(void)reloadPageControllerView {
    [_pageController setPageIndicatorImage:[UIImage imageNamed:@"desel"]];
    _pageController.currentPageIndicatorImage = [UIImage imageNamed:@"sel"];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    if (!self.dropView.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.dropView setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.dropView.hidden=YES;
        }];
    }
    if (!self.langview.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.langview setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.langview.hidden=YES;
        }];
    }
}

-(void)cardBtnPressedWithOutAnimation:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.dropView.hidden) {
            
            NSDictionary *flightDict = [self.flightArray objectAtIndex:self.carousel.currentItemIndex];
            
            // disable no volado como jsb button
            
            self.notJsbBtn.enabled = [flightDict[@"isFlownAsJSB"] boolValue];
            
            // disable actualizar datos button
            
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            SynchronizationController *sync =  [[SynchronizationController alloc] init];
            int diff = [appDel compareDate:[NSDate date] :[[flightDict objectForKey:@"sortTime"] toGlobalTime]];
            self.updateDataBtn.enabled = (diff > 0 && ([sync shouldSyncFlight:flightDict] || [sync shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]));
            
            // show popup
            [self.dropView setAlpha:1.0];
            
            self.dropView.hidden = NO;
            [self arrangeFramesOfItemsAccordingToOrientation];
        }
        else {
            [self.dropView setAlpha:0.0];
            self.dropView.hidden = YES;
        }
    });
}

-(void)cardBtnPressed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.dropView.hidden) {
            
            NSDictionary *flightDict = [self.flightArray objectAtIndex:self.carousel.currentItemIndex];
            
            // disable no volado como jsb button
            
            self.notJsbBtn.enabled = [flightDict[@"isFlownAsJSB"] boolValue];
            
            // disable actualizar datos button
            SynchronizationController *sync = [[SynchronizationController alloc] init];
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
            int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"arrivalLocal"] toGlobalTime]];
            self.updateDataBtn.enabled = (diff > 0 && ([sync shouldSyncFlight:flightDict] || [sync shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]));
            
            // show popup
            
            self.dropView.hidden = NO;
            [self arrangeFramesOfItemsAccordingToOrientation];
            [UIView animateWithDuration:0.2 animations:^{
                [self.dropView setAlpha:1.0];
            }];
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                [self.dropView setAlpha:0.0];
            } completion:^(BOOL finished) {
                self.dropView.hidden = YES;
            }];
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [appDel copyTextForKey:@"FVC_NOT_JSB"];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = [appDel copyTextForKey:@"FVC_UPDATE_DATA"];
    }
    
    return cell;
}

- (IBAction)userBtnTapped:(id)sender {
    
    if (self.langview.hidden) {
        self.langview.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [self.langview setAlpha:1.0];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            [self.langview setAlpha:0.0];
        } completion:^(BOOL finished) {
            self.langview.hidden = YES;
        }];
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.synchBtn.transform = CGAffineTransformRotate(self.synchBtn.transform, -M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (self.animating) {
                             // if flag still set, keep spinning with constant speed
                             [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                         } else if (options != UIViewAnimationOptionCurveEaseOut) {
                             // one last spin, with deceleration
                             [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                         }
                     }];
}

- (void)reachabilityChanged:(NSNotification *)notif {
    
    [self paintUserIcon];
}

- (void)paintUserIcon {
    
    UIImage *img = [UIImage imageNamed:@"icon_login.png"];
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NetworkStatus internetStatus = [appDel.hostReachability currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            img = [UIImage imageNamed:@"icon_login_gray.png"];
        } break;
        case ReachableViaWiFi: {
            
        } break;
        case ReachableViaWWAN: {
        } break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.userButton setImage:img forState:UIControlStateNormal];
    });
}

- (void)startSpin {
    
    if (self.isActive) {
        
        if (!self.animating) {
            
            self.animating = YES;
            [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
        }
    }
}

- (void)stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.animating = NO;
}

- (IBAction)synchBtnClicked:(id)sender {
    
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![synch checkForInternetAvailability]) {
        if(sender) {
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"STATUS_ERROR"] message:[appDel copyTextForKey:@"ALERT_UNABLETOCONNECT"]];
        }
        return;
    }
    
    if(sender != nil) {
        
        if([LTSingleton getSharedSingletonInstance].synchStatus) {
            return;
        }
        
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
        [self startSpin];
        [synch initiateSynchronization];
    } else if([self.flightArray count] > 0) {
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startSpin];
        });
        [synch synchBasicInfos:self.flightArray forIndex:0 Oncomplete:^{
            [synch synchFlightSeatMapOnComplete:^{
                [synch synchAllPassengerDataOnComplete:^{
                    [synch syncAllGadReportsOncomplete:^{
                        [synch synchCreateFlightForStatus:inqueue Oncomplete:^{
                            [synch syncCusReportWithCompletionHandler:^{
                                [synch synchCheckStatusOncomplete:^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    } else {
        [self stopSpin];
    }
}

-(void)synchCompletedWithSuccess {
    
    SynchronizationController * synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
    self.flightArray = [synch getFlightroaster];
    [self startSpin];
    [LTSingleton getSharedSingletonInstance].synchStatus = YES;
    
    if ([self.flightArray count] > 0) {
        [synch synchBasicInfos:self.flightArray forIndex:0 Oncomplete:^{
            [synch synchFlightSeatMapOnComplete:^{
                [synch synchAllPassengerDataOnComplete:^{
                    [synch syncAllGadReportsOncomplete:^{
                        [synch synchCreateFlightForStatus:inqueue Oncomplete:^{
                            [synch syncCusReportWithCompletionHandler:^{
                                [synch synchCheckStatusOncomplete:^{
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    } else {
        [self stopSpin];
    }
}

- (void)finishedSynchronizing {
    [LTSingleton getSharedSingletonInstance].synchStatus = NO;
    NSLog(@"finished synchronizing");
    
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *title = [appdel copyTextForKey:@"ALERT_MSG"];
    NSMutableString *msg = [NSMutableString stringWithString:@""];
    
    NSMutableDictionary *errorDict = [LTSingleton getSharedSingletonInstance].errorDict;
    for(NSString *key in errorDict) {
        [msg appendString:[NSString stringWithFormat:@"\n%@ : %@", key, errorDict[key]]];
    }
    
    [errorDict removeAllObjects];
    
    if(![msg isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:KOkButtonTitle otherButtonTitles: nil];
        [alert show];
    }
    
    [self stopSpin];
    
    [self updateCarousal];
    [self scrollToCurrentFlight];
    self.userNameLabel.text = [LTSingleton getSharedSingletonInstance].user;
    [self pageController];
    
    SynchronizationController * synch = [[SynchronizationController alloc] init];
    [synch synchNotFlownAsJSB];
}

- (void)briefingDownloaded:(NSNotification*)notif {
    
    [self updateFlightCardForPublication:notif.userInfo];
}

- (IBAction)noFlyingJSBBtnClicked:(id)sender {
    
    self.dropView.hidden = YES;
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[apDel copyTextForKey:@"ALERT_MSG"] message:[apDel copyTextForKey:@"FLIGHT_JSB_CONFIRMATION"] delegate:self cancelButtonTitle:[apDel copyTextForKey:@"CANCEL"] otherButtonTitles:[apDel copyTextForKey:@"ALERT_OK"], nil];
    alert.tag = 102;
    [alert show];
}

- (IBAction)actualizaDataBtnClicked:(id)sender {
    
    if([LTSingleton getSharedSingletonInstance].synchStatus) {
        return;
    }
    
    self.dropView.hidden = YES;
    [self startSpin];
    
    [self syncFlight:self.carousel.currentItemIndex];
}

- (IBAction)languageChanged:(id)sender {
    
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if (seg.selectedSegmentIndex == 0) {
        [self adjustLanguageLabelsForLanguage:LANG_SPANISH];
        [appDel switchToLocale:LANG_SPANISH];
    }
    else if (seg.selectedSegmentIndex == 1) {
        [self adjustLanguageLabelsForLanguage:LANG_PORTUGUESE];
        [appDel switchToLocale:LANG_PORTUGUESE];
    }
    
    [self.carousel reloadData];
    [manualFlight.legTableView reloadData];
    
    [self.notJsbBtn setTitle:[appDel copyTextForKey:@"FVC_NOT_JSB"] forState:UIControlStateNormal];
    [self.updateDataBtn setTitle:[appDel copyTextForKey:@"FVC_UPDATE_DATA"] forState:UIControlStateNormal];
}

- (void)adjustLanguageLabelsForLanguage:(LanguageSelected)language {
    
    UILabel *pt = (UILabel*)[self.langview viewWithTag:10];
    UILabel *es = (UILabel*)[self.langview viewWithTag:11];
    
    if(language == LANG_SPANISH) {
        pt.alpha = 0.5;
        es.alpha = 1.0;
    }
    else if(language == LANG_PORTUGUESE) {
        pt.alpha = 1.0;
        es.alpha = 0.5;
    }
}

- (IBAction)signOutBtnTapped:(id)sender {
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[apDel copyTextForKey:@"ALERT_MSG"] message:[apDel copyTextForKey:@"ALERT_LOGOUT_MSG"] delegate:self cancelButtonTitle:[apDel copyTextForKey:@"CANCEL"] otherButtonTitles:[apDel copyTextForKey:@"ALERT_OK"], nil];
    alert.tag = 101;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else if(alertView.tag == 102) {
        
        if(buttonIndex == 1) {
            AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            SynchronizationController *sync =  [[SynchronizationController alloc] init];
            NSDictionary *flightDict = [self.flightArray objectAtIndex:self.carousel.currentItemIndex];
            
            NSDictionary *flightKey = [flightDict objectForKey:@"flightKey"];
            NSMutableArray *statArray = [UserInformationParser getStatusForAllFlights];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"airlineCode == %@ AND flightDate==%@ AND flightNumber==%@",[flightKey objectForKey:@"airlineCode"],[flightKey objectForKey:@"flightDate"],[flightKey objectForKey:@"flightNumber"]];
            NSArray *filtArray = [[statArray filteredArrayUsingPredicate:predicate] mutableCopy];
            BOOL ShouldChange = YES;
            if([statArray count] > 0) {
                NSDictionary *statDict = [filtArray firstObject];
                
                if([[statDict objectForKey:@"flightStatus"] integerValue] > draft)
                    ShouldChange = NO;
                for (NSDictionary *cusDict in [statDict objectForKey:@"CUS"]) {
                    if([[cusDict objectForKey:@"status"] integerValue] > draft)
                        ShouldChange = NO;
                }
                for (NSDictionary *GADDict in [statDict objectForKey:@"GAD"]) {
                    if([[GADDict objectForKey:@"status"] integerValue] > draft)
                        ShouldChange = NO;
                }
            }
            
            if (ShouldChange) {
                [sync notFlowanAsJSB:flightDict completion:^{
                    [self updateCarousal];
                }];
                [self updateCarousal];
            } else {
                [AlertUtils showErrorAlertWithTitle:[appdel copyTextForKey:@"ERROR_LABEL"] message:[appdel copyTextForKey:@"CANT_SEND_CUS"]];
            }
        }
    }
}

- (IBAction)StatusBtnTapped:(id)sender {
    if (!_dropView.hidden) {
        _dropView.hidden = YES;
    }
    statusVC = [[SynchStatusViewController alloc] initWithNibName:@"SynchStatusViewController" bundle:nil];
    statusVC.delegate = self;
    statusVC.isSingleFlight = NO;
    statusVC.view.frame = self.view.frame;
    [self addChildViewController:statusVC];
    statusVC.view.alpha = 0.0;
    [self.view addSubview:statusVC.view];
    [UIView animateWithDuration:0.4 animations:^{
        statusVC.view.alpha=1.0f;
    }];
    
    [statusVC didMoveToParentViewController:self];
}

- (IBAction)manualButtonClicked:(id)sender {
    if (!_dropView.hidden) {
        _dropView.hidden = YES;
    }
    ManualViewController *manual = [[ManualViewController alloc] initWithNibName:@"ManualViewController" bundle:nil];
    [self.navigationController pushViewController:manual animated:YES];
}

- (IBAction)addManualFlightClicked:(id)sender {
    if (!_dropView.hidden) {
        _dropView.hidden = YES;
    }
    manualFlight = [[AddManualFlightViewController alloc] initWithFlightDataObject:nil WithMode:Add];
    manualFlight.delegate = self;
    manualFlight.view.frame = self.view.frame;
    
    [self addChildViewController:manualFlight];
    manualFlight.view.alpha=0.0f;
    [self.view addSubview:manualFlight.view];
    [UIView animateWithDuration:0.4 animations:^{
        manualFlight.view.alpha = 1.0f;
    }];
    
    [manualFlight didMoveToParentViewController:self];
    UIViewController *vc = self.navigationController.topViewController;
    
    manualFlight.view.frame = vc.view.frame;
    manualFlight.containerView.center = CGPointMake(manualFlight.view.frame.size.width/2, manualFlight.view.frame.size.height/2);
}

-(void)closePopOverforObject:(UIViewController*)VC{
    [VC willMoveToParentViewController:nil];  // 1
    [UIView animateWithDuration:0.4 animations:^{
        VC.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [VC.view removeFromSuperview];
        [VC removeFromParentViewController];
        
    }];
    VC = nil;// 3
}

-(void)scrollToFlightReportFromVC:(UIViewController*)VC forFlight:(NSDictionary*)flightDict {
    [self closePopOverforObject:VC];
    //identify The flight
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightKey.airlineCode == %@ AND flightKey.flightDate==%@ AND flightKey.flightNumber==%@",[flightDict objectForKey:@"airlineCode"],[flightDict objectForKey:@"flightDate"],[flightDict objectForKey:@"flightNumber"]];
    NSArray *filterArray = [self.flightArray filteredArrayUsingPredicate:predicate];
    if ([filterArray count] > 0) {
        NSInteger index = [self.flightArray indexOfObject:[filterArray firstObject]];
        [self CarousalIdexSelectedForIndex:index forSelectedIndex:4];
    }
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
    NSArray *filterArray = [self.flightArray filteredArrayUsingPredicate:predicate];
    
    if ([filterArray count] > 0) {
        [LTSingleton getSharedSingletonInstance].flightKeyDict = [filterArray objectAtIndex:0];
        [LTSingleton getSharedSingletonInstance].flightRoasterDict = [filterArray objectAtIndex:0];
        GADViewController *gadVC = [[GADViewController alloc] initWithNibName:@"GADViewController" bundle:nil];
        NSString * name = [[gadDict valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[gadDict   valueForKey:@"lastName"]]];
        
        gadVC.bpIDforCrew =[gadDict valueForKey:@"bp"];
        NSMutableArray *legArr = [[NSMutableArray alloc] init];
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"origin":[gadDict objectForKey:@"legOrigin"],@"destination":[gadDict objectForKey:@"legDestination"],@"legArrivalLocal":[gadDict objectForKey:@"legArrivalLocal"],@"legDepartureLocal":[gadDict objectForKey:@"legDepartureLocal"]}];
        [legArr addObject:legDict];
        
        
        gadVC.legArray = legArr;
        NSInteger sections = gadVC.GADTableView.numberOfSections;
        if([[gadDict objectForKey:@"status"] intValue]<2){
            gadVC.isForReport = YES;
            gadVC.sendBtn.hidden = YES;
            for (int section = 0; section < sections; section++) {
                NSInteger rows =  [gadVC.GADTableView numberOfRowsInSection:section];
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
        
        UIViewController *vc1 = self.navigationController.topViewController;
        [vc1 addChildViewController:gadVC];
        [self.navigationController.topViewController.view addSubview:gadVC.view];
        [gadVC didMoveToParentViewController:vc1];
        
        gadVC.indexForLeg = [[gadDict objectForKey:@"legNumber"] integerValue];
        
        gadVC.designationLabel.text = [gadDict valueForKey:@"activeRank"];
        
        gadVC.crewNumberLabel.text = [gadDict valueForKey:@"specialRank"];
        gadVC.crewFirstName = [gadDict valueForKey:@"firstName"];
        gadVC.crewLastName = [gadDict  valueForKey:@"lastName"];
        gadVC.crewNameLabel.text = name;
        gadVC.bpIdLabel.text = [gadDict valueForKey:@"bp"];
        
        [gadVC.GADTableView reloadData];
    }
}

-(void)scrollToCUSReportFromVC:(UIViewController *)VC forFlight:(NSMutableDictionary *)flightDict andCUSDict:(NSDictionary*)cusDict {
    [self closePopOverforObject:VC];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightKey.airlineCode == %@ AND flightKey.flightDate==%@ AND flightKey.flightNumber==%@",[flightDict objectForKey:@"airlineCode"],[flightDict objectForKey:@"flightDate"],[flightDict objectForKey:@"flightNumber"]];
    NSArray *filterArray = [self.flightArray filteredArrayUsingPredicate:predicate];
    if ([filterArray count] > 0) {
        [LTSingleton getSharedSingletonInstance].flightRoasterDict = [filterArray firstObject];
        CUSReportViewController *CUSVC = [[CUSReportViewController alloc] initWithNibName:@"CUSReportViewController" bundle:nil];
        if ([[cusDict objectForKey:@"status"] integerValue]==draft || [[cusDict objectForKey:@"status"] integerValue]==0 || [[cusDict objectForKey:@"status"] integerValue] == eror) {
            CUSVC.readonly = NO;
        } else {
            CUSVC.readonly = YES;
        }
        
        NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
        
        if ([numJSB integerValue] == 0) {
            CUSVC.readonly = YES;
        }
        [LTSingleton getSharedSingletonInstance].flightKeyDict=[filterArray firstObject];
        
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
        if(currentCustomer.docType) {
            [cusDict1 setObject:currentCustomer.docType forKey:@"DOCUMENT_TYPE"];
            [cusDict1 setObject:currentCustomer.docNumber forKey:@"DOCUMENT_NUMBER"];
        }
        if(currentCustomer.freqFlyerNum)
            [cusDict1 setObject:currentCustomer.freqFlyerNum forKey:@"FREQUENTFLYER_NUMBER"];
        if(currentCustomer.freqFlyerCategory)
            [cusDict1 setObject:currentCustomer.freqFlyerCategory forKey:@"FREQUENTFLYER_CATEGORY"];
        if (report.reportId) {
            [cusDict1 setObject:report.reportId forKey:@"REPORTID"];
        }
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
        
        CUSReportImages *cusimages;
        if (report.reportCusImages) {
            cusimages = [[CUSReportImages alloc] init];
            cusimages.image1 = report.reportCusImages.image1;
            cusimages.image2 = report.reportCusImages.image2;
            cusimages.image3 = report.reportCusImages.image3;
            cusimages.image4 = report.reportCusImages.image4;
            cusimages.image5 = report.reportCusImages.image5;
        }
        
        if([cusDict1[@"DOCUMENT_NUMBER"] isEqualToString:@""]) {
            cusDict1[@"DOCUMENT_NUMBER"] = currentCustomer.freqFlyerNum;
        }
        
        NSMutableDictionary *flightRoster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
        CUSVC.customerDict = cusDict1;
        CUSVC.customer = currentCustomer;
        CUSVC.flightDict = flightRoster;
        CUSVC.cusReportImages = cusimages;
        CUSVC.report=report;
        
        UIViewController *vc = self.navigationController.topViewController;
        [vc addChildViewController:CUSVC];
        
        [self.navigationController.topViewController.view addSubview:CUSVC.view];
        [CUSVC didMoveToParentViewController:vc];
    }
}

-(void)manualFlightAdded:(NSDictionary*)flightDict {
    [self updateCarousal];
    
    if(self.flightArray.count == 0) {
        return;
    }
    
    int index;
    
    for(index = 0; index < self.flightArray.count; index++) {
        
        NSDictionary *dict = self.flightArray[index];
        
        if([dict[@"isManualyEntered"] intValue] == 0) {
            continue;
        }
        
        NSDictionary *fKeyDict = dict[@"flightKey"];
        
        if([fKeyDict[@"airlineCode"] isEqualToString:flightDict[@"airlineCode"]] &&
           [fKeyDict[@"flightDate"] isEqual:flightDict[@"flightDate"]] &&
           [fKeyDict[@"flightNumber"] isEqualToString:flightDict[@"flightNumber"]]) {
            break;
        }
    }
    
    [self syncFlight:index];
    [self.carousel scrollToItemAtIndex:index animated:YES];
}

-(void)syncFlight:(int)indexOfFlight {
    
    SynchronizationController *sync = [[SynchronizationController alloc] init];
    
    if ([sync checkForInternetAvailability] == NO) {
        return;
    }
    
    [self startSpin];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
        
        SynchronizationController *sync =  [[SynchronizationController alloc] init];
        NSDictionary *flightDict = [self.flightArray objectAtIndex:indexOfFlight];
        
        [sync actualizeDataForFlight:flightDict Oncomplete:^(BOOL success) {
            [sync actualizeDataForFlightSeat:flightDict Oncomplete:^(BOOL success) {
                [sync actualizeDataForFlightPassenger:flightDict Oncomplete:^(BOOL success) {
                    
                    NSDictionary *fKey = flightDict[@"flightKey"];
                    
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
                    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
                    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FlightRoaster"];
                    
                    NSDate *fDate;
                    //flightDate
                    if([[fKey objectForKey:@"flightDate"] isKindOfClass:[NSString class]]) {
                        NSString *fDateString = [fKey objectForKey:@"flightDate"];
                        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                        [dateFormat3 setDateFormat:DATEFORMAT];
                        
                        fDate = [dateFormat3 dateFromString:fDateString];
                    } else {
                        fDate = [fKey objectForKey:@"flightDate"];
                    }
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate, [fKey objectForKey:@"suffix"], [fKey objectForKey:@"flightNumber"], [fKey objectForKey:@"airlineCode"]];
                    [request setPredicate:predicate];
                    NSError *error1;
                    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
                    
                    if([results count] > 0) {
                        FlightRoaster *flight = [results firstObject];
                        
                        [sync syncGADReportsFlorFlightDict:flightDict onlySyncInQueue:YES];
                        if(flight.status.intValue == inqueue)
                            [sync syncFlightReportForFlightDict:[LTCreateFlightReport createReportFlightDictForFlight:flight]];
                        [sync syncCusReportsForFlightRoster:flight];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [LTSingleton getSharedSingletonInstance].synchStatus = NO;
                        [self stopSpin];
                        
                        if(success) {
                            [self updateCarousal];
                        }
                        else {
                            AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            NSString *title = [appDel copyTextForKey:@"ALERT_MSG"];
                            NSString *msg = [appDel copyTextForKey:@"FLIGHT_UPDATE_FAILED"];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:KOkButtonTitle otherButtonTitles: nil];
                            [alert show];
                        }
                    });
                }];
            }];
        }];
    });
}

-(void)updateCarousal {
    self.statArray = [UserInformationParser getStatusForAllFlights];
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    self.flightArray = [synch getFlightroaster];
    _pageController.numberOfPages = [self.flightArray count];
    
    if ([[self.navigationController topViewController] isKindOfClass:[self class]]) {
        [self.carousel reloadData];
    }
}

-(void)updateFlightCardForPublication:(NSDictionary *)flightDict {
    
    self.statArray = [UserInformationParser getStatusForAllFlights];
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    self.flightArray = [synch getFlightroaster];
    
    for(NSDictionary *dict in self.flightArray) {
        
        NSDictionary *fKey = dict[@"flightKey"];
        
        if([flightDict[@"airlineCode"] isEqualToString:fKey[@"airlineCode"]] &&
           [flightDict[@"flightNumber"] isEqualToString:fKey[@"flightNumber"]]) {
            [self.carousel reloadItemAtIndex:[self.flightArray indexOfObject:dict] animated:NO];
        }
    }
}

-(void)scrollToCurrentFlight {
    int nextFlyIndex = [self getIndexOfNextFly];
    [self.carousel scrollToItemAtIndex:nextFlyIndex animated:YES];
}

-(void)synchFailedWithError:(enum errorTag)errorTag {
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [LTSingleton getSharedSingletonInstance].isLoggingIn = NO;
    [LTSingleton getSharedSingletonInstance].synchStatus = NO;
    [self stopSpin];
    ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
    [acview stopAnimation];
    switch (errorTag) {
        case kInvalidPassword:
            //[self.loginIndicator stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:YES];
            //alert for authentication failed
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_INCORRECTPASSWORD"]];
            break;
            
        case kAuthenticationFailed:
            //[self.loginIndicator stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:YES];
            //alert for authentication failed
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_INCORRECTUSRPWD"]];
            break;
        case kReachabilityFailed:
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_UNABLETOCONNECT"]];
            break;
        case kDifferentUser:
            //[self.loginIndicator stopAnimating];
            //alert for authentication failed
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_UNABLETOAUTHENTICATE"]];
            break;
        case kTimeOut:
            //[self.loginIndicator stopAnimating];
            //alert for timeout
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_DATAFAILED"] message:[appDel copyTextForKey:@"ALERT_DATAFAILED_MSG"]];
            break;
        case kAccessForbidden:
            //[self.loginIndicator stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:YES];
            //alert for authentication failed
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_ACCESSFORBIDDEN"]];
            break;
        default:
            break;
    }
}

- (void)printCoreDataStats {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray *entityNames = [[appDel.managedObjectModel entities] valueForKey:@"name"];
    
    for(NSString *name in entityNames) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
        NSError *fetchError = nil;
        NSArray *results = [appDel.managedObjectContext executeFetchRequest:request error:&fetchError];
        NSLog(@"%@: %ld", name, results.count);
    }
}

@end
