//
//  SeatMapViewController.m
//  Nimbus2
//
//  Created by Dreamer on 7/29/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SeatMapViewController.h"
#import "SynchronizationController.h"
#import <QuartzCore/QuartzCore.h>
#import "ClassInformation.h"
//#import "Row.h"
#import "Column.h"
#import "Seat.h"
#import "FilterButton.h"
#import "Passenger.h"
#import "PassengerTableViewCell.h"
#import "BusinessSeatCell.h"
#import "EconomySeatCell.h"
#import "SeatCell.h"
#import "GetSeatMapData.h"
#import "PassengerDetailsViewController.h"

#import "SMPageControl.h"


@interface SeatMapViewController () {
    NSMutableArray *sectionInfoArray;
    
    __weak IBOutlet UIButton *searchButton;
    
    __weak IBOutlet NSLayoutConstraint *collectionViewWidthConstraint;
    
    __weak IBOutlet NSLayoutConstraint *tableViewWidhtConstraint;
    
    __weak IBOutlet NSLayoutConstraint *tableBottomSpaceConstraint;
    
    __weak IBOutlet NSLayoutConstraint *passengersTableViewHeightConstraint;
    
    __weak IBOutlet NSLayoutConstraint *gapBtwCollectionAndTableConstraint;
    
    __weak IBOutlet UIButton *FilterByCategoryButton;
    
    __weak IBOutlet FilterButton *ffpFilterButton;
    
    __weak IBOutlet FilterButton *vipFilterButton;
    
    __weak IBOutlet FilterButton *spmlFilterButton;
    
    __weak IBOutlet FilterButton *spndFilterButton;
    
    __weak IBOutlet FilterButton *cnxFilterButton;
    
    __weak IBOutlet FilterButton *apFilterButton;
    
    __weak IBOutlet UILabel *noSeatmapLabel;
    
    __weak IBOutlet UIButton *addCustomerButton;
    IBOutlet SMPageControl * pageController;
    enum filterMode mode;
    UIView *animateView ;
    
    NSMutableArray *passengerInfoArray;
    NSMutableArray *passengerInfoArrayFilter;
    NSMutableArray *passengerInfoArrayMaster;
    Passenger *currentPassenger;
    int legsCount;
    UIButton *previousButton;
    int previousHeightBusiness;
    int previousHeightEconomy;
    NSDictionary * seatMapdict;
    NSArray * businessClassArray;
    NSArray * customerArray;
    NSArray * economyClassArray;
    
    NSMutableArray *economyEmptySeats;
    NSMutableArray *businessEmptySeats;
    NSMutableArray *allSeatsArray;
    NSMutableArray *mealsList;
    NSMutableArray *lanPas;
    
    int indexForLeg;
    NSString * colType ;
    NSString * colTypeTempB ;
    NSString * colTypeTempE ;
    NSMutableArray * allPassengerArray;
    
    int vip_count; int ffp_count; int spml_count; int cnx_count; int ap_count; int spNeeds_count;
    
    CGSize kseatSizeForBusinessClass; //CGSizeMake(48.0, 70.0);
    CGSize kseatSizeForEconomyClass; //CGSizeMake(37.0, 50.0);
    
    int kDistanceBetweenTwoAisleSeatsInBusinessClass;// = 85;
    int kDistanceBetweenWindowAndIsleSeatInBusinessClass;// = 14;
    int kDistanceBetweenTwoAisleSeatsInEconomyClass;// = 67;
    int kDistanceBetweenWindowAndIsleSeatInEconomyClass;// = 10;
    int kWidthOfBusinessClassSeat;// = 48.0;
    int kWidthOfEconomyClassSeat;// = 37.0;
    int kRegularSpacingInBusinessClass;// = 14.0;
    int kRegularSpacingInEconomyClass;// = 9.0;
    BOOL isNotManualSeat;
    BOOL doseNotHaveSeatMap;
    
    int kRowNumberSpacing;
}

@end

@implementation SeatMapViewController

int VSeatMapCollectionViewWidth = 590;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUIFrames];
    
    vip_count = 0;  ffp_count = 0;  spml_count = 0;  cnx_count = 0;  ap_count = 0;  spNeeds_count =0;
    colTypeTempB = @"1J";
    colTypeTempE = @"1Y";
    
    isNotManualSeat = YES;
    doseNotHaveSeatMap = NO;
    
    self.legArray = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"];
    seatMapdict = [[NSDictionary alloc]init];
    
    legsCount = [self.legArray count];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollCarousal:) name:@"TabLegScroll" object:nil];
    [self loadPageControllerWithTotalPages:legsCount];
    
    _selectedPassenger = false;
    
    passengerFilterTabelView.delegate = self;
    passengerFilterTabelView.dataSource = self;
    
    sectionInfoArray = [[NSMutableArray alloc] init];
    passengerInfoArray = [[NSMutableArray alloc] init];
    
    economyEmptySeats = [[NSMutableArray alloc] init];
    businessEmptySeats = [[NSMutableArray alloc] init];
    allSeatsArray = [[NSMutableArray alloc] init];
    
    mode = no_Filter;
    
    [self retrieveInformationRequiredForCollectionViewfromSeatMapDict];
    
    [seatMapCollectionView registerNib:[UINib nibWithNibName:@"BusinessSeatCell" bundle:nil] forCellWithReuseIdentifier:@"BusinessSeatCellIdentifier"];
    
    [seatMapCollectionView registerNib:[UINib nibWithNibName:@"EconomySeatCell" bundle:nil] forCellWithReuseIdentifier:@"EconomySeatCellIdentifier"];
    
    [seatMapCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    [passengerFilterTabelView registerNib:[UINib nibWithNibName:@"PassengerTableViewCell" bundle:nil] forCellReuseIdentifier:@"PassengerIdentifier"];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [passengerSearchTextField setLeftViewMode:UITextFieldViewModeAlways];
    [passengerSearchTextField setLeftView:spacerView];
    
    [passengerSearchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // Do any additional setup after loading the view from its nib.
    previousButton = nil;
    
    noSeatmapLabel.text = [(AppDelegate*)[UIApplication sharedApplication].delegate copyTextForKey:@"SEATMAP_NOT_LOADED"];
    
    if(sectionInfoArray == nil || sectionInfoArray.count == 0) {
        noSeatmapLabel.hidden = NO;
    }
    else {
        noSeatmapLabel.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUIFrames];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

-(void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(updateUIFrames) withObject:nil afterDelay:0];
}

- (void)updateUIFrames {
    
    if (animateView) {
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            animateView.frame = CGRectMake(0, 0, 1024, 768);
            tableBottomSpaceConstraint.constant = 5;
        }
        else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            animateView.frame = CGRectMake(0, 0, 768, 1024);
            tableBottomSpaceConstraint.constant = 5;
            
        }
        UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[animateView viewWithTag:111];
        activity.center = animateView.center;
    }
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    int collectionViewidth = 0;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //Reduce width of collectionView
        collectionViewWidthConstraint.constant = 480;
        gapBtwCollectionAndTableConstraint.constant = 5;
        tableViewWidhtConstraint.constant = 190;
        collectionViewidth = 480;
        if (passengerDetailsViewController) {
            passengerDetailsViewController.view.frame = CGRectMake(475, 68, 190, 710);
            dispatch_async(dispatch_get_main_queue(), ^{
                [passengerDetailsViewController.view layoutIfNeeded];
            });
        }
        if (categoryTableViewController) {
            CGRect frame =  categoryTableViewController.view.frame;
            frame.origin.y = 68;
            frame.origin.x = 505;
            frame.size.width = 190;
            frame.size.height = 710;
            categoryTableViewController.view.frame = frame;
            dispatch_async(dispatch_get_main_queue(), ^{
                [categoryTableViewController reloadTheViews];
            });
        }
        passengersTableViewHeightConstraint.constant = 680;
        
        kDistanceBetweenTwoAisleSeatsInBusinessClass = 60;
        kDistanceBetweenWindowAndIsleSeatInBusinessClass = 7;
        kDistanceBetweenTwoAisleSeatsInEconomyClass = 47;
        kDistanceBetweenWindowAndIsleSeatInEconomyClass = 6;
        kWidthOfBusinessClassSeat = 38.0;
        kWidthOfEconomyClassSeat = 27.0;
        kRegularSpacingInBusinessClass = 7.0;
        kRegularSpacingInEconomyClass = 6.0;
        
        kseatSizeForBusinessClass = CGSizeMake(kWidthOfBusinessClassSeat, 70.0);
        kseatSizeForEconomyClass = CGSizeMake(kWidthOfEconomyClassSeat, 50.0);
        tableBottomSpaceConstraint.constant = 5;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        collectionViewWidthConstraint.constant = 590;
        gapBtwCollectionAndTableConstraint.constant = 25;
        tableViewWidhtConstraint.constant = 230;
        collectionViewidth =590;
        if (passengerDetailsViewController) {
            passengerDetailsViewController.view.frame = CGRectMake(635, 68, 230, 520);
            ;
            dispatch_async(dispatch_get_main_queue(), ^{
                [passengerDetailsViewController.view layoutIfNeeded];
            });
        }
        if (categoryTableViewController) {
            CGRect frame = categoryTableViewController.view.frame;
            frame.origin.y = 68;
            frame.origin.x = 635;
            frame.size.width = 230;
            frame.size.height = 520;
            categoryTableViewController.view.frame = frame;
            dispatch_async(dispatch_get_main_queue(), ^{
                [categoryTableViewController reloadTheViews];
            });
        }
        passengersTableViewHeightConstraint.constant = 520;
        
        kDistanceBetweenTwoAisleSeatsInBusinessClass = 85;
        kDistanceBetweenWindowAndIsleSeatInBusinessClass = 14;
        kDistanceBetweenTwoAisleSeatsInEconomyClass = 67;
        kDistanceBetweenWindowAndIsleSeatInEconomyClass = 10;
        kWidthOfBusinessClassSeat = 48.0;
        kWidthOfEconomyClassSeat = 37.0;
        kRegularSpacingInBusinessClass = 14.0;
        kRegularSpacingInEconomyClass = 9.0;
        
        kseatSizeForBusinessClass = CGSizeMake(kWidthOfBusinessClassSeat, 70.0);
        kseatSizeForEconomyClass = CGSizeMake(kWidthOfEconomyClassSeat, 50.0);
        tableBottomSpaceConstraint.constant = 5;
    }
    
    VSeatMapCollectionViewWidth = collectionViewidth;
    [seatMapCollectionView reloadData];
    [self reselectCurrentPassengerWithDrawing:NO];
    [self.view layoutIfNeeded];
}

- (void) loadPageControllerWithTotalPages:(int)totalCount {
    pageController.numberOfPages = totalCount;
    pageController.indicatorMargin = 10.0f;
    pageController.indicatorDiameter = 10.0f;
    pageController.alignment = SMPageControlAlignmentCenter;
    [pageController setCurrentPageIndicatorImage:[UIImage imageNamed:@"sel.png"]];
    [pageController setPageIndicatorImage:[UIImage imageNamed:@"desel.png"]];
    [pageController addTarget:self action:@selector(spacePageControl:) forControlEvents:UIControlEventValueChanged];
}

- (void)spacePageControl:(SMPageControl *)sender {
    
}

-(void)scrollCarousal:(NSNotification*)notification {
    [self loadSpinner];
    NSDictionary *dic = notification.userInfo;
    NSInteger index = [[dic objectForKey:@"index"] integerValue];
    indexForLeg = index;
    [pageController setPageIndicatorImage:[UIImage imageNamed:@"desel"]];
    [pageController setCurrentPageIndicatorImage:[UIImage imageNamed:@"sel"]];
    pageController.currentPage = index;
    
    [self reloadPageControllerView];
    [self retrieveInformationRequiredForCollectionViewfromSeatMapDict];
    [seatMapCollectionView reloadData];
    [self reselectCurrentPassengerWithDrawing:NO];
    [passengerFilterTabelView reloadData];
    [self performSelector:@selector(stopSpinner) withObject:nil afterDelay:2.0f];
}

-(void)stopSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [animateView removeFromSuperview];
    });
}

-(void)loadSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(animateView)
            [animateView removeFromSuperview];
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            
        }
        else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
            
        }
        
        [animateView setBackgroundColor:[UIColor blackColor]];
        animateView.alpha = 0.7;
        
        UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityInd.center = animateView.center;
        [animateView addSubview:activityInd];
        activityInd.tag = 111;
        [activityInd startAnimating];
        
        [self.view.window addSubview:animateView];
        
    });
}

-(void)reloadPageControllerView {
    [pageController setPageIndicatorImage:[UIImage imageNamed:@"desel"]];
    pageController.currentPageIndicatorImage = [UIImage imageNamed:@"sel"];
}

// To retrieve the information from the DB and form the datasource(sectionInfoArray).
-(void)retrieveInformationRequiredForCollectionViewfromSeatMapDict {
    vip_count = 0;  ffp_count = 0;  spml_count = 0;  cnx_count = 0;  ap_count = 0;  spNeeds_count =0;
    
    [economyEmptySeats removeAllObjects];
    [businessEmptySeats removeAllObjects];
    [allSeatsArray removeAllObjects];
    [mealsList removeAllObjects];
    mealsList = [[NSMutableArray alloc] init];
    lanPas = [[NSMutableArray alloc]init];
    
    [sectionInfoArray removeAllObjects];
    
    [passengerInfoArray removeAllObjects];
    
    seatMapdict = [GetSeatMapData getSeatMapDataForLegIndex:indexForLeg];
    if (!allPassengerArray) {
        allPassengerArray = [[NSMutableArray alloc]init];
    } else {
        [allPassengerArray removeAllObjects];
    }
    
    allPassengerArray = [GetSeatMapData getPassengerDataLegIndex:indexForLeg];
    
    
    NSMutableArray *passaengerWithNoSeat = [[NSMutableArray alloc]init];
    for ( int count = 0; count < allPassengerArray.count; count++) {
        Passenger * customer = [[Passenger alloc] init];
        
        NSDictionary * custDict = [allPassengerArray objectAtIndex:count];
        customer.firstName = [custDict valueForKey:@"firstName"];
        customer.lastName = [custDict valueForKey:@"lastName"];
        customer.secondLastName = [custDict valueForKey:@"secondLastName"];
        customer.dateOfBirth=[custDict valueForKey:@"dateOfBirth"];
        customer.seatNumber = [custDict valueForKey:@"seatNumber"];
        customer.docNumber = [custDict valueForKey:@"docNumber"];
        customer.docType = [custDict valueForKey:@"docType"];
        customer.freqFlyerComp = [custDict valueForKey:@"freqFlyerComp"];
        customer.freqFlyerCategory = [custDict valueForKey:@"freqFlyerCategory"];
        customer.freqFlyerNum = [custDict valueForKey:@"freqFlyerNum"];
        customer.groupCode = [custDict valueForKey:@"groupCode"];
        customer.language =[custDict valueForKey:@"language"];
        customer.gender =[custDict valueForKey:@"gender"];
        customer.editCodes =[custDict valueForKey:@"editCodes"];
        customer.isWCH = [custDict valueForKey:@"isWCH"];
        customer.isChild = [custDict valueForKey:@"isChild"];
        customer.lanPassKms = [custDict valueForKey:@"lanPassKms"];
        customer.lanPassCategory = [custDict valueForKey:@"lanPassCategory"];
        customer.lanPassUpgrade = [custDict valueForKey:@"lanPassUpgrade"];
        customer.vipCategory = [custDict valueForKey:@"vipCategory"];
        customer.vipRemarks = [custDict valueForKey:@"vipRemarks"];
        customer.email = [custDict valueForKey:@"email"];
        customer.address = [custDict valueForKey:@"address"];
        customer.customerId = [custDict valueForKey:@"customerId"];
        customer.status = [custDict valueForKey:@"status"];
        
        
        NSArray * splMealArray = [custDict objectForKey:@"splMeal"];
        customer.specialMeals = [[NSOrderedSet alloc]initWithArray:splMealArray];
        
        NSArray * cusConnectionArray  = [custDict objectForKey:@"connection"];
        customer.cusConnection = [[NSOrderedSet alloc]initWithArray:cusConnectionArray];
        
        // currentSeat.seatPassenger = customer;
        
        if(customer.seatNumber && customer.seatNumber.length > 0) {
            if([self trimWhiteSpace:customer.vipCategory].length > 0 ) {
                vip_count = vip_count +1;
            }
            if(!([self trimWhiteSpace:customer.groupCode].length > 0) ) {
                ap_count = ap_count +1;
            }
            if(customer.freqFlyerNum != nil && ![customer.freqFlyerNum isEqualToString:@"0"] &&  ![customer.freqFlyerNum isEqualToString:@""]) {
                ffp_count = ffp_count +1;
            }
            if(customer.specialMeals.count > 0 ) {
                spml_count = spml_count +1;
            }
            if([self trimWhiteSpace:customer.editCodes].length > 0 && [customer.isWCH intValue] == 1 ) {
                spNeeds_count = spNeeds_count +1;
            }
            if(customer.cusConnection.count > 0) {
                cnx_count = cnx_count +1;
            }
        }
        
        if(customer.specialMeals.count > 0) {
            NSMutableDictionary *specialMealsDictionary = [[NSMutableDictionary alloc]init];
            [specialMealsDictionary setObject:[[customer.specialMeals objectAtIndex:0]objectForKey:@"serviceCode"] forKey:@"service"];
            [specialMealsDictionary setObject:[[customer.specialMeals objectAtIndex:0]objectForKey:@"option"] forKey:@"option"];
            [specialMealsDictionary setObject:customer.firstName forKey:@"firstname"];
            [specialMealsDictionary setObject:customer.lastName forKey:@"lastname"];
            [specialMealsDictionary setObject:customer.seatNumber forKey:@"seatnumber"];
            [mealsList addObject:specialMealsDictionary];
        }
        if ((customer.lanPassCategory && customer.lanPassCategory != nil) && (customer.lanPassKms != nil && customer.lanPassKms) ) {
            [lanPas addObject:customer];
        }
        [passaengerWithNoSeat addObject:customer];
    }
    
    NSMutableArray * allKeyssorted = [[NSMutableArray alloc] init];
    NSArray * keys = [seatMapdict allKeys];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil
                                                 ascending:YES] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    keys = [keys sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSString * colnType in keys) {
        if ([[colnType substringFromIndex:colnType.length-1] isEqualToString:@"J"]) {
            [allKeyssorted addObject:colnType];
        }
    }
    for (NSString * colnType in keys) {
        if ([[colnType substringFromIndex:colnType.length-1] isEqualToString:@"Y"]) {
            [allKeyssorted addObject:colnType];
        }
    }
    
    for (NSString * colnType in keys) {
        if ([[colnType substringFromIndex:colnType.length-1] isEqualToString:@"M"]) {
            seatMapCollectionView.delegate = nil;
            isNotManualSeat = NO;
            doseNotHaveSeatMap = YES;
            [allKeyssorted addObject:colnType];
        }
    }
    
    for (NSString * key in allKeyssorted) {
        ClassInformation *anyClass = [[ClassInformation alloc] init];
        
        NSMutableString *classString = (NSMutableString *)key;
        NSString *class = [classString substringFromIndex:classString.length-1];
        anyClass.columnTypeString = classString;
        if ([class isEqualToString:@"J"]) {
            anyClass.className = @"Business";
        } else if ([class isEqualToString:@"Y"]) {
            anyClass.className = @"Economy";
        }
        
        NSArray *classArray =   (NSArray *)[seatMapdict objectForKey:key];
        anyClass.numberOfItems = classArray.count;
        
        NSMutableArray *seatInfoArray = [[NSMutableArray alloc] init];
        if (classArray.count > 0 && ([class isEqualToString:@"J"] ||[class isEqualToString:@"Y"] ))
            isNotManualSeat = YES;
        
        int greatestRow = 0;
        int lowestRow = INT_MAX;
        
        for (int k = 0; k < classArray.count; k++) {
            NSDictionary *seat = [classArray objectAtIndex:k];
            
            Seat *currentSeat = [[Seat alloc] init];
            currentSeat.rowName = [NSString stringWithFormat:@"%@",[seat objectForKey:@"rowNumber"]];
            currentSeat.columnName = [seat objectForKey:@"columnNumber"];
            currentSeat.state = [seat objectForKey:@"state"];
            currentSeat.isWindow = [[seat objectForKey:@"isWindow"] boolValue];
            currentSeat.isAisle = [[seat objectForKey:@"isAisle"] boolValue];
            currentSeat.isEmergency = [[seat objectForKey:@"isEmergency"] boolValue];
            
            if(greatestRow < currentSeat.rowName.intValue) {
                greatestRow = currentSeat.rowName.intValue;
            }
            if(lowestRow > currentSeat.rowName.intValue) {
                lowestRow = currentSeat.rowName.intValue;
            }
            
            [allSeatsArray addObject:[NSString stringWithFormat:@"%@%@",[seat objectForKey:@"rowNumber"],[seat objectForKey:@"columnNumber"]]];
            
            if ([seat valueForKey:@"seatCustomer"] !=nil) {
                
                Passenger * customer = [[Passenger alloc] init];
                NSDictionary * custDict = [seat valueForKey:@"seatCustomer"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"dd MMMM yyyy";
                
                customer.customerId = [custDict valueForKey:@"customerId"];
                customer.firstName = [custDict valueForKey:@"firstName"];
                customer.lastName = [custDict valueForKey:@"lastName"];
                customer.secondLastName = [custDict valueForKey:@"secondLastName"];
                customer.dateOfBirth = [df dateFromString:[custDict valueForKey:@"dateOfBirth"]];
                customer.seatNumber = [custDict valueForKey:@"seatNumber"];
                customer.docNumber = [custDict valueForKey:@"docNumber"];
                customer.docType = [custDict valueForKey:@"docType"];
                customer.freqFlyerComp = [custDict valueForKey:@"freqFlyerComp"];
                customer.freqFlyerCategory = [custDict valueForKey:@"freqFlyerCategory"];
                customer.freqFlyerNum = [custDict valueForKey:@"freqFlyerNum"];
                customer.flightClass = anyClass.className;
                customer.groupCode = [custDict valueForKey:@"groupCode"];
                customer.language =[custDict valueForKey:@"language"];
                customer.gender =[custDict valueForKey:@"gender"];
                customer.editCodes =[custDict valueForKey:@"editCodes"];
                customer.isWCH = [custDict valueForKey:@"isWCH"];
                customer.isChild = [custDict valueForKey:@"isChild"];
                customer.lanPassKms = [custDict valueForKey:@"lanPassKms"];
                customer.lanPassCategory = [custDict valueForKey:@"lanPassCategory"];
                customer.lanPassUpgrade = [custDict valueForKey:@"lanPassUpgrade"];
                customer.vipRemarks = [custDict valueForKey:@"vipRemarks"];
                customer.vipCategory = [custDict valueForKey:@"vipCategory"];
                customer.email = [custDict valueForKey:@"email"];
                customer.address = [custDict valueForKey:@"address"];
                
                customer.status = [custDict valueForKey:@"status"];
                
                NSArray * splMealArray = [custDict objectForKey:@"splMeal"];
                customer.specialMeals = [[NSOrderedSet alloc]initWithArray:splMealArray];
                
                NSArray * cusConnectionArray  = [custDict objectForKey:@"connection"];
                customer.cusConnection = [[NSOrderedSet alloc]initWithArray:cusConnectionArray];
                
                currentSeat.seatPassenger = customer;
                
                if(customer.seatNumber && customer.seatNumber.length > 0) {
                
                    if([self trimWhiteSpace:customer.vipCategory].length > 0 ) {
                        vip_count = vip_count + 1;
                    }
                    if(!([self trimWhiteSpace:customer.groupCode].length > 0) ) {
                        ap_count = ap_count + 1;
                    }
                    if(customer.freqFlyerNum != nil && ![customer.freqFlyerNum isEqualToString:@"0"] &&  ![customer.freqFlyerNum isEqualToString:@""]) {
                        ffp_count = ffp_count + 1;
                    }
                    if(customer.specialMeals.count > 0 ) {
                        spml_count = spml_count + 1;
                    }
                    if([self trimWhiteSpace:customer.editCodes].length > 0 && [customer.isWCH intValue] == 1 ) {
                        spNeeds_count = spNeeds_count + 1;
                    }
                    if(customer.cusConnection.count > 0) {
                        cnx_count = cnx_count + 1;
                    }
                }
                
                if(customer.specialMeals.count > 0) {
                    NSMutableDictionary *specialMealsDictionary = [[NSMutableDictionary alloc]init];
                    [specialMealsDictionary setObject:[[customer.specialMeals objectAtIndex:0]objectForKey:@"serviceCode"] forKey:@"service"];
                    [specialMealsDictionary setObject:[[customer.specialMeals objectAtIndex:0]objectForKey:@"option"] forKey:@"option"];
                    [specialMealsDictionary setObject:customer.firstName forKey:@"firstname"];
                    [specialMealsDictionary setObject:customer.lastName forKey:@"lastname"];
                    [specialMealsDictionary setObject:customer.seatNumber forKey:@"seatnumber"];
                    [mealsList addObject:specialMealsDictionary];
                }
                if ((customer.lanPassCategory && customer.lanPassCategory != nil) && (customer.lanPassKms != nil && customer.lanPassKms) ) {
                    [lanPas addObject:customer];
                }
                [passengerInfoArray addObject:customer];
                
            } else {
                
                if ([class isEqualToString:@"J"]) {
                    [businessEmptySeats addObject:currentSeat];
                } else if ([class isEqualToString:@"Y"]) {
                    [economyEmptySeats addObject:currentSeat];
                }
            }
            
            [seatInfoArray addObject:currentSeat];
        }
        
        // Pick one row item to find the number of columns
        NSMutableArray *temporaryArray = [seatInfoArray copy];
        
        Seat *anyoneseat = nil;
        if (temporaryArray.count > 0) {
            anyoneseat = (Seat *)  [temporaryArray objectAtIndex:0];
        }
        
        NSPredicate *temp = [NSPredicate predicateWithFormat:@"(columnName == %@)", anyoneseat.columnName];
        NSArray *filtered = [temporaryArray filteredArrayUsingPredicate:temp];
        anyClass.numberOfRows = filtered.count;
        
        temp = [NSPredicate predicateWithFormat:@"(rowName == %@) AND (columnName != %@)", anyoneseat.rowName,@"="];
        filtered = [temporaryArray filteredArrayUsingPredicate:temp];
        anyClass.numberOfColumns = filtered.count;
        
        NSMutableArray *temporaryArray1 = [seatInfoArray copy];
        
        // Pick one row item to find the number of hidden columns
        
        Seat *anyoneseat1 = nil;
        if (temporaryArray1.count > 0) {
            anyoneseat1 = (Seat *)  [temporaryArray1 objectAtIndex:0];
        }
        
        NSPredicate *temp1 = [NSPredicate predicateWithFormat:@"(rowName == %@) AND (columnName == %@)", anyoneseat1.rowName,@"="];
        NSArray *filtered1 = [temporaryArray1 filteredArrayUsingPredicate:temp1];
        
        anyClass.numberOfHiddenColumns = filtered1.count;
        
        // Pick one row item to find the concatinated string for header. This string is used to display the headers like A B   D E  etc.
        NSMutableArray *temporaryArray2 = [seatInfoArray copy];
        
        Seat *anyoneseat2 = nil;
        if (temporaryArray2.count > 0) {
            anyoneseat2 = (Seat *)  [temporaryArray2 objectAtIndex:0];
        }
        
        NSPredicate *temp2 = [NSPredicate predicateWithFormat:@"(rowName == %@)", anyoneseat2.rowName];
        NSArray *filtered2 = [temporaryArray2 filteredArrayUsingPredicate:temp2];
        
        NSString *tempString = [[NSString alloc] init];
        for (int p=0; p< filtered2.count; p++) {
            Seat    *anyoneseat1 = (Seat *) [filtered2 objectAtIndex:p];
            if (![tempString containsString:anyoneseat1.columnName]|| [anyoneseat1.columnName isEqualToString:@"="]) {
                tempString = [tempString stringByAppendingString:anyoneseat1.columnName];
            }
        }
        
        anyClass.columnHeaderString = tempString;
        anyClass.seatsArray = seatInfoArray;
        
        if (anyClass.seatsArray.count > 0 && isNotManualSeat) {
            [sectionInfoArray addObject:anyClass];
        }
    }
    
    passengerInfoArray =    [[passengerInfoArray arrayByAddingObjectsFromArray:passaengerWithNoSeat] mutableCopy];
    passengerInfoArrayFilter = [[NSMutableArray alloc] init];
    [passengerInfoArrayFilter addObjectsFromArray:passengerInfoArray];
    
    
    passengerInfoArrayMaster = [[NSMutableArray alloc] init];
    [passengerInfoArrayMaster addObjectsFromArray:passengerInfoArray];
    
    
    [ffpFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",ffp_count] andButtonName:@"FFP"];
    [vipFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",vip_count] andButtonName:@"VIP"];
    [spmlFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",spml_count] andButtonName:@"SPML"];
    [spndFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",spNeeds_count] andButtonName:@"SPND"];
    [cnxFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",cnx_count] andButtonName:@"CNX"];
    [apFilterButton modifyQuantity:[NSString stringWithFormat:@"%d",ap_count] andButtonName:@"AP"];
}

- (NSString*)trimWhiteSpace:(NSString*)text{
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickAdd:(UIButton *)sender {
    
    //if (addCustomerVC == nil){
    LTAddCustomerViewController * addCustomerVC = [[LTAddCustomerViewController alloc]initWithNibName:@"LTAddCustomerViewController" bundle:nil];
    addCustomerVC.delegate = self;
    addCustomerVC.allseats = allSeatsArray;
    addCustomerVC.seatMapExists = isNotManualSeat;
    
    UIViewController *vc= self.navigationController.topViewController;
    [vc addChildViewController:addCustomerVC];
    [self.navigationController.topViewController.view addSubview:addCustomerVC.view];
    
    [addCustomerVC didMoveToParentViewController:vc];
}

#pragma mark CollectionView Datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:section];
    return classInfo.numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:indexPath.section];
    colType = classInfo.columnTypeString;
    
    Seat *currentSeat = [classInfo.seatsArray objectAtIndex:indexPath.row];
    
    SeatCell *cell;
    
    int rowNum = currentSeat.rowName.intValue;
    
    if(![seatMapCollectionView viewWithTag:rowNum]) {
        
        Seat *firstSeat = [classInfo.seatsArray objectAtIndex:0];
        int firstRowInSection = firstSeat.rowName.intValue;
        
        float h = 0;
        float headerH = 30;
        float labelH = 30;
        
        for(int i = 0; i < indexPath.section; i++) {
            ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
            float itemH = [self collectionView:seatMapCollectionView layout:seatMapCollectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]].height;
            float itemSepH = ((UICollectionViewFlowLayout*)seatMapCollectionView.collectionViewLayout).minimumLineSpacing;
            float sectionH = classInfo.numberOfRows * (itemH + itemSepH) - itemSepH;
            
            UIEdgeInsets insets =[self collectionView:seatMapCollectionView layout:seatMapCollectionView.collectionViewLayout insetForSectionAtIndex:i];
            
            h += sectionH + insets.top + insets.bottom + headerH;
        }
        
        float itemH = [self collectionView:seatMapCollectionView layout:seatMapCollectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section]].height;
        float itemSepH = ((UICollectionViewFlowLayout*)seatMapCollectionView.collectionViewLayout).minimumLineSpacing;
        float prevH = (rowNum - firstRowInSection) * (itemH + itemSepH);
        UIEdgeInsets insets =[self collectionView:seatMapCollectionView layout:seatMapCollectionView.collectionViewLayout insetForSectionAtIndex:indexPath.section];
       
        h += prevH + insets.top + itemH/2 + headerH - labelH/2;
        
        int xNum = 2;
        if(currentSeat.isEmergency && rowNum < 10) {
            xNum = -7;
        }
        
        UILabel *rowNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(xNum, h, 24, 30)];
        rowNumLabel.textAlignment = NSTextAlignmentCenter;
        rowNumLabel.font = [UIFont fontWithName:@"Roboto Condensed" size:20];
        rowNumLabel.textColor = [UIColor whiteColor];
        rowNumLabel.text = [NSString stringWithFormat:@"%d", rowNum];
        rowNumLabel.tag = rowNum;
        [seatMapCollectionView addSubview:rowNumLabel];
        [seatMapCollectionView sendSubviewToBack:rowNumLabel];
        
        if(currentSeat.isEmergency) {
            int dx = 15;
            if(rowNum >= 10) {
                dx = 20;
            }
            
            UILabel *emergencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(xNum + dx, h + 1, 12, 30)];
            emergencyLabel.textAlignment = NSTextAlignmentCenter;
            emergencyLabel.font = [UIFont fontWithName:@"Roboto Condensed" size:15];
            emergencyLabel.textColor = [UIColor whiteColor];
            emergencyLabel.text = @"E";
            [seatMapCollectionView addSubview:emergencyLabel];
            [seatMapCollectionView sendSubviewToBack:emergencyLabel];
        }
    }
    
    if ([classInfo.className isEqualToString:@"Business"]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BusinessSeatCellIdentifier" forIndexPath:indexPath];
        
    } else if([classInfo.className isEqualToString:@"Economy"]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EconomySeatCellIdentifier" forIndexPath:indexPath];
    }
    
    [cell configurePassengerData:currentSeat];
    
    if([_curent_seatNmum isEqualToString:[currentSeat.rowName stringByAppendingString:currentSeat.columnName]]) {
        cell.layer.borderColor = [[UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:80.0/255.0 alpha:1.0] CGColor];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionInfoArray.count;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (reusableview==nil) {
            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, VSeatMapCollectionViewWidth, 30)];
        }
        reusableview.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:115.0/255.0 alpha:1.0];
        //reusableview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        reusableview.layer.cornerRadius = 10.0;
        
        for (UIView * view in reusableview.subviews){
            [view removeFromSuperview];
        }
        ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:indexPath.section];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 38, 30)];
        
        if([classInfo.className isEqualToString:@"Economy"]) {
            label.text = @"YC";
        } else if([classInfo.className isEqualToString:@"Business"]) {
            label.text = @"BC";
            
        }
        
        label.textColor = [UIColor whiteColor];
        
        [reusableview addSubview:label];
        
        CGFloat si = [self reduceheaderLabelforClass:classInfo];
        
        UIView *Viewlabel = [[UIView alloc] initWithFrame:CGRectMake(si, 0, VSeatMapCollectionViewWidth - 2 * si, 30)];
        
        [self applycolumnLables:Viewlabel forClass:classInfo];
        
        [reusableview addSubview:Viewlabel];
        
        return reusableview;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        
    }
    
    return reusableview;
}

-(void)applycolumnLables:(UIView *)columnView forClass:(ClassInformation *)classInfo {
    
    NSString *headerString = classInfo.columnHeaderString;
    
    CGFloat seatWidth=0.0;
    CGFloat seatgap=0.0;
    if ([classInfo.className isEqualToString:@"Business"]) {
        seatWidth = kWidthOfBusinessClassSeat;
        seatgap = kRegularSpacingInBusinessClass;
    }else if ([classInfo.className isEqualToString:@"Economy"]) {
        seatWidth = kWidthOfEconomyClassSeat;
        seatgap =  kRegularSpacingInEconomyClass;
    }
    
    CGFloat xval = 0;
    for (int i=0; i<headerString.length; i++) {
        
        if (i>0) {
            
            xval =  i*(seatWidth+seatgap);
        }
        UILabel *temp = [[UILabel alloc] initWithFrame:CGRectMake(xval, 0, seatWidth, 30)];
        
        temp.text = [headerString substringWithRange:NSMakeRange(i, 1)];
        if ([temp.text isEqualToString:@"="]) {
            temp.hidden = true;
        }
        temp.textAlignment = NSTextAlignmentCenter;
        temp.backgroundColor = [UIColor clearColor];
        temp.textColor = [UIColor whiteColor];
        [columnView addSubview:temp];
    }
    
}

#pragma mark CollectionView Delegate methods
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:indexPath.section];
    
    Seat *currentSeat = [classInfo.seatsArray objectAtIndex:indexPath.row];
    if (currentSeat.seatPassenger != nil)
        cell.layer.borderColor = [[UIColor clearColor] CGColor];
    else
        cell.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:indexPath.section];
    Seat *currentSeat = [classInfo.seatsArray objectAtIndex:indexPath.row];
    
    if(!indexPath || !currentSeat || [currentSeat.state isEqualToString:@""]) {
        [seatMapCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        if([currentSeat.state isEqualToString:@""]) {
            [self reselectCurrentPassengerWithDrawing:NO];
        }
        return;
    }
    
    [self reloadtableData];
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];

    if (currentSeat.seatPassenger != nil) {
        
        if(FilterByCategoryButton.selected) {
            [self filterByCategoryButtonTapped:FilterByCategoryButton];
        }
        
        // add code related to didselectrowatindexpath for tableview.
        
        if ([cell isKindOfClass:[BusinessSeatCell class]]){
            cell.layer.borderColor = [[UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:80.0/255.0 alpha:1.0] CGColor];
        }
        if ([cell isKindOfClass:[EconomySeatCell class]]){
            cell.layer.borderColor = [[UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:80.0/255.0 alpha:1.0] CGColor];
        }
        
        _isSeatClicked = YES;
        
        NSString *temp1=currentSeat.rowName;
        NSString *temp2=currentSeat.columnName;
        NSString *selectedSatNumber=[temp1 stringByAppendingString:temp2];
        
        if (passengerDetailsViewController) {
            
            [passengerDetailsViewController removeFromParentViewController];
            [passengerDetailsViewController.view removeFromSuperview];
            passengerDetailsViewController = nil;
        }
        
        if(categoryTableViewController) {
            [categoryTableViewController.view removeFromSuperview];
        }
        
        passengerDetailsViewController = [[PassengerDetailsViewController alloc] initWithNibName:@"PassengerDetailsViewController" bundle:nil];
        passengerDetailsViewController.isClicked = _isSeatClicked;
        passengerDetailsViewController.selectedSeat = selectedSatNumber;
        
        passengerDetailsViewController.currentPassengertemp = currentSeat.seatPassenger;
        _curent_seatNmum = [currentSeat.rowName stringByAppendingString:currentSeat.columnName];
        currentPassenger = currentSeat.seatPassenger;
        passengerDetailsViewController.acompaniesDataArray=[self retrievePassengerswithGroupcode:currentSeat.seatPassenger.groupCode];
        passengerDetailsViewController.legIndex = indexForLeg;
        [passengerSearchTextField setHidden:YES];
        [passengerFilterTabelView setHidden:YES];
        passengerDetailsViewController.delegate  = self;
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGRect size;
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            size = CGRectMake(635, 68, 230, 520);
        } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            size = CGRectMake(510, 68, 190, 710);
        }
        passengerDetailsViewController.view.frame = size;
        passengerDetailsViewController.view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:passengerDetailsViewController.view];
        
    } else {
        
        if(_curent_seatNmum) {
            [self reselectCurrentPassengerWithDrawing:YES];
        }
        
        // Bring add customer
        LTAddCustomerViewController * addCustomerVC = [[LTAddCustomerViewController alloc]initWithNibName:@"LTAddCustomerViewController" bundle:nil];
        addCustomerVC.delegate = self;
        addCustomerVC.seatNumber = [NSString stringWithFormat:@"%@%@",currentSeat.rowName,currentSeat.columnName];
        addCustomerVC.seatMapExists = isNotManualSeat;
        UIViewController *vc= self.navigationController.topViewController;
        [vc addChildViewController:addCustomerVC];
        [self.navigationController.topViewController.view addSubview:addCustomerVC.view];
        [addCustomerVC didMoveToParentViewController:vc];
    }
}


#pragma mark CollectionView Delegate FlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:indexPath.section];
    
    if ([classInfo.className isEqualToString:@"Business"]) {
        return kseatSizeForBusinessClass;
    }
    else if ([classInfo.className isEqualToString:@"Economy"]){
        return kseatSizeForEconomyClass;
        
    }
    return kseatSizeForEconomyClass;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:section];
    if ([classInfo.className isEqualToString:@"Business"]) {
        return kRegularSpacingInBusinessClass;
    } else if ([classInfo.className isEqualToString:@"Economy"])
        return kRegularSpacingInEconomyClass;
    
    return 50.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:section];
    
    return [self insetforClasswithCallInfo:classInfo];
}
// dynamically reduce the size of the header label to fit according to the length of the string.
-(CGFloat)reduceheaderLabelforClass: (ClassInformation *)classInfo {
    
    if ([classInfo.className isEqualToString:@"Business"]) {
        
        CGFloat ReminingWidthOfCollectionView = (seatMapCollectionView.frame.size.width - ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns) * kWidthOfBusinessClassSeat + ((classInfo.numberOfColumns+classInfo.numberOfHiddenColumns-1) * kRegularSpacingInBusinessClass)));
        
        CGFloat finalRect = ReminingWidthOfCollectionView/2;
        
        return finalRect;
    } else if ([classInfo.className isEqualToString:@"Economy"]) {
        
        CGFloat ReminingWidthOfCollectionView = (seatMapCollectionView.frame.size.width - ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns) * kWidthOfEconomyClassSeat + ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns -1) * kRegularSpacingInEconomyClass)));
        
        CGFloat finalRect = ReminingWidthOfCollectionView/2;
        
        return finalRect;
    }
    return 100.0;
}

// This method decides the inset of the section. This is helpful to create the dynamic layout of each section.

-(UIEdgeInsets)insetforClasswithCallInfo: (ClassInformation *)classInfo {
    
    // steps
    //  1. check the section class
    //  2. get the number of colums
    //  3. get the number of hidden columns.
    // 4. use this formula  remainingwidth = totalwidth of collection view - ((no of colums*widthofsectionseat)+((no of colums-1)*widthofsectionseat))
    // 5. divide the remainingwidth by 2 to get the inset on each side (left & right).
    
    
    if ([classInfo.className isEqualToString:@"Business"]) {
        
        CGFloat ReminingWidthOfCollectionView = (seatMapCollectionView.frame.size.width - ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns) * kWidthOfBusinessClassSeat + ((classInfo.numberOfColumns+classInfo.numberOfHiddenColumns-1) * kRegularSpacingInBusinessClass)));
        
        CGFloat finalInset = ReminingWidthOfCollectionView/2;
        
        return UIEdgeInsetsMake(20, finalInset, 20, finalInset);
        
    } else if ([classInfo.className isEqualToString:@"Economy"]) {
        
        CGFloat ReminingWidthOfCollectionView = (seatMapCollectionView.frame.size.width - ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns) * kWidthOfEconomyClassSeat + ((classInfo.numberOfColumns + classInfo.numberOfHiddenColumns -1) * kRegularSpacingInEconomyClass)));
        
        CGFloat finalInset = ReminingWidthOfCollectionView/2;
        
        return UIEdgeInsetsMake(20, finalInset, 20, finalInset);
    }
    
    return UIEdgeInsetsMake(0, 100, 0, 100);
}

#pragma mark TableView Datasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return passengerInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reloadtableData];
    PassengerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PassengerIdentifier"];
    
    Passenger *passenger = [passengerInfoArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.seatNumber.text =    passenger.seatNumber;
    cell.firstName.text =   [[NSString stringWithFormat:@"%@ %@",passenger.firstName,passenger.lastName] uppercaseString];
    cell.accountType.text =   passenger.editCodes ? passenger.editCodes : @"";
    
    cell.seatNumber.font = [UIFont fontWithName:@"RobotoCondensed-bold" size:20];
    cell.firstName.font= [UIFont fontWithName:@"RobotoCondensed-bold" size:16];
    cell.accountType.font= KRobotoFontSize14;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)doneButtonTapped {
    [passengerFilterTabelView setHidden:NO];
    [passengerSearchTextField setHidden:NO];
    _selectedPassenger = false;
    _curent_seatNmum = nil;
    currentPassenger = nil;
    [passengerDetailsViewController.view removeFromSuperview];
    [passengerDetailsViewController removeFromParentViewController];
    passengerDetailsViewController =nil;
    //  [self.view addSubview:passengerFilterTabelView];
    
    for (NSIndexPath *indexPath in [seatMapCollectionView indexPathsForSelectedItems]) {
        [seatMapCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:seatMapCollectionView didDeselectItemAtIndexPath:indexPath];
    }
}
#pragma mark CUS Report delegate method.
-(void)finishedSavingCUSReport {
    [self refreshData];
}
#pragma mark report CUS Button delegate method.

-(void)reportCusButtonTapped : (Passenger *)passenger {
    NSMutableDictionary *customerDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:passenger.firstName!=nil ? passenger.firstName : @"" ,@"FIRST_NAME",passenger.lastName!=nil ? passenger.lastName : @"",@"LAST_NAME",passenger.secondLastName?passenger.secondLastName:@"",@"SECOND_LAST_NAME",passenger.docType !=nil ? passenger.docType : @"",@"DOCUMENT_TYPE",passenger.docNumber!=nil ? passenger.docNumber : @"",@"DOCUMENT_NUMBER",passenger.date!=nil ? passenger.date : @"",@"DATE", passenger.seatNumber!=nil ? passenger.seatNumber : @"",@"SEAT_NUMBER",passenger.freqFlyerCategory!=nil ?passenger.freqFlyerCategory:@"",@"FREQUENTFLYER_CATEGORY",passenger.freqFlyerNum!=nil?passenger.freqFlyerNum:@"",@"FREQUENTFLYER_NUMBER",passenger.language!=nil?passenger.language:@"",@"LANGUAGE",passenger.address!=nil?passenger.address:@"",@"ADDRESS",passenger.email!=nil?passenger.email:@"",@"EMAIL",passenger.customerId,@"CUSTOMERID",nil];
    
    if([customerDict[@"DOCUMENT_NUMBER"] isEqualToString:@""]) {
        customerDict[@"DOCUMENT_NUMBER"] = passenger.freqFlyerNum;
    }
    
    CUSReportViewController * cusreportVC = [[CUSReportViewController alloc]initWithNibName:@"CUSReportViewController" bundle:nil];
    
    NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
    if ([numJSB integerValue]==0) {
        cusreportVC.readonly=YES;
    }
    
    NSMutableDictionary *flightRoster = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    cusreportVC.customerDict = customerDict;
    cusreportVC.flightDict = flightRoster;
    cusreportVC.delegate = self;
    cusreportVC.doseNotHaveSeatMap = doseNotHaveSeatMap;
    
    UIViewController *vc= self.navigationController.topViewController;
    [vc addChildViewController: cusreportVC];
    [self.navigationController.topViewController.view addSubview:cusreportVC.view];
    [cusreportVC didMoveToParentViewController:vc];
}

#pragma mark TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Passenger *selectedPass = [passengerInfoArray objectAtIndex:indexPath.row];
    Seat *selectedSeat;
    
    for (int i = 0; i < sectionInfoArray.count; i++) {
        ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
        for (int j = 0; j < classInfo.seatsArray.count; j++) {
            Seat *seat = [classInfo.seatsArray objectAtIndex:j];
            if([selectedPass.seatNumber isEqualToString:[seat.rowName stringByAppendingString:seat.columnName]]) {
                selectedSeat = seat;
                i = sectionInfoArray.count;
                j = classInfo.seatsArray.count;
            }
        }
    }
    
    if([selectedSeat.state isEqualToString:@""]) {
        return;
    }
    
    [self reloadtableData];
    currentPassenger = selectedPass;
    
    _selectedPassenger = YES;
    if (!passengerDetailsViewController) {
        passengerDetailsViewController = [[PassengerDetailsViewController alloc] initWithNibName:@"PassengerDetailsViewController" bundle:nil];
    }
    
    _curent_seatNmum = currentPassenger.seatNumber;
    passengerDetailsViewController.acompaniesDataArray = [self retrievePassengerswithGroupcode:currentPassenger.groupCode];
    
    if([currentPassenger.flightClass isEqualToString:@"Business"]) {
        passengerDetailsViewController.classNameType = @"BC";
    } else if([currentPassenger.flightClass isEqualToString:@"Economy"]) {
        passengerDetailsViewController.classNameType = @"YC";
    }
    
    _selectedPassenger = YES;
    passengerDetailsViewController.selectPassenger = _selectedPassenger;
    passengerDetailsViewController.legIndex = indexForLeg;
    
    passengerDetailsViewController.currentPassengertemp = currentPassenger;
    [passengerSearchTextField setHidden:YES];
    [passengerFilterTabelView setHidden:YES];
    passengerDetailsViewController.delegate = self;
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect size;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        size = CGRectMake(635, 68, 230, 520);
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        size = CGRectMake(475, 68, 190, 710);
    }
    
    passengerDetailsViewController.view.frame = size;
    passengerDetailsViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:passengerDetailsViewController.view];
    
    [self reselectCurrentPassengerWithDrawing:YES];
}

-(void)reloadtableData {
    
    passengerDetailsViewController.isClicked = NO;
    passengerDetailsViewController.selectPassenger = NO;
    _selectedPassenger = passengerDetailsViewController.selectPassenger;
    _isSeatClicked = passengerDetailsViewController.isClicked;
    passengerDetailsViewController.acompaniesDataArray = [[NSArray alloc] init];
}

#pragma mark Other methods

-(void)clearHighlightedSeatsOnCollectionview {
    
    for (int i = 0; i < sectionInfoArray.count; i++) {
        ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
        for (int j = 0; j < classInfo.seatsArray.count; j++) {
            Seat *currentSeat = [classInfo.seatsArray objectAtIndex:j];
            currentSeat.isHighlighted = NO;
        }
    }
    [seatMapCollectionView reloadData];
    [self reselectCurrentPassengerWithDrawing:NO];
}

-(void)highlightPassengers:(NSArray *)passengerArray {
    
    for (int k = 0; k < passengerArray.count; k++) {
        Passenger *passenger = [passengerArray objectAtIndex:k];
        
        for (int i = 0; i < sectionInfoArray.count; i++) {
            ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
            for (int j = 0; j< classInfo.seatsArray.count; j++) {
                Seat *currentSeat = (Seat *)[classInfo.seatsArray objectAtIndex:j];
                if ([currentSeat.seatPassenger.seatNumber isEqualToString:passenger.seatNumber]) {
                    currentSeat.isHighlighted = YES;
                    i = sectionInfoArray.count;
                    j = classInfo.seatsArray.count;
                }
            }
        }
    }
    
    [seatMapCollectionView reloadData];
    [self reselectCurrentPassengerWithDrawing:NO];
}

- (void)reselectCurrentPassengerWithDrawing:(BOOL)draw {
    
    if(!_curent_seatNmum) {
        return;
    }
    
    // de-select
    for (NSIndexPath *indexPath in [seatMapCollectionView indexPathsForSelectedItems]) {
        [seatMapCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:seatMapCollectionView didDeselectItemAtIndexPath:indexPath];
    }
    
    NSIndexPath *cvIndexPath;
    
    for (int i = 0; i < sectionInfoArray.count; i++) {
        ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
        for (int j=0; j< classInfo.seatsArray.count; j++) {
            Seat *currentSeat = (Seat *)[classInfo.seatsArray objectAtIndex:j];
            if([currentSeat.seatPassenger.seatNumber isEqualToString:currentPassenger.seatNumber]) {
                cvIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                i = sectionInfoArray.count;
                j = classInfo.seatsArray.count;
            }
        }
    }
    
    if(cvIndexPath) {
        // select
        if(draw) {
            [seatMapCollectionView selectItemAtIndexPath:cvIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
        else {
            [seatMapCollectionView selectItemAtIndexPath:cvIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        [self collectionView:seatMapCollectionView didSelectItemAtIndexPath:cvIndexPath];
    }
}

-(NSArray*)retrievePassengerswithGroupcode:(NSString *)groupcode {
    
    NSMutableArray *passengerswithsamegroupcode = [[NSMutableArray alloc] init];
    if (![groupcode isEqualToString:@""] && groupcode !=nil) {
        for (int i=0; i<sectionInfoArray.count; i++) {
            ClassInformation *classInfo = (ClassInformation *)[sectionInfoArray objectAtIndex:i];
            for (int j=0; j< classInfo.seatsArray.count; j++) {
                Seat *currentSeat = (Seat *)[classInfo.seatsArray objectAtIndex:j];
                if ([currentSeat.seatPassenger.groupCode isEqualToString:groupcode]) {
                    NSString *seatandname = [NSString stringWithFormat:@"%@  %@ %@",currentSeat.seatPassenger.seatNumber,currentSeat.seatPassenger.firstName,currentSeat.seatPassenger.lastName];
                    if(![currentSeat.seatPassenger.customerId isEqualToString:currentPassenger.customerId]) {
                        [passengerswithsamegroupcode addObject:seatandname];
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithArray:passengerswithsamegroupcode];
}

#pragma mark add new customer delegate methods

-(void)finishedEnteringNewCustomer {
    [self refreshData];
}

-(void)refreshData {
    [self retrieveInformationRequiredForCollectionViewfromSeatMapDict];
    if ([currentPassenger.status intValue] == 0 ) {
        [passengerDetailsViewController disableCusReportButton:@"1"];
    }
    
    [seatMapCollectionView reloadData];
    [self reselectCurrentPassengerWithDrawing:NO];
    [passengerFilterTabelView reloadData];
    
    if (categoryTableViewController) {
        categoryTableViewController.passengerInfoArray = passengerInfoArray;
        categoryTableViewController.economyArray = economyEmptySeats;
        categoryTableViewController.bussnessArray = businessEmptySeats;
        categoryTableViewController.passengerInfoArray = passengerInfoArray;
        categoryTableViewController.mealListArray = mealsList;
        categoryTableViewController.lanpassArray = lanPas;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [categoryTableViewController reloadTheViews];
        });
    }
}

#pragma mark UITextField Delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    // searchButton.selected = YES;
    
    if (searchButton.selected == NO) {
        [self toggleSelectedState:searchButton];
    }
}

-(void)textFieldDidChange :(UITextField *)textField {
    if (textField.text!=nil && textField.text.length>0) {
        if (textField == passengerSearchTextField ) {
            [self filterTableViewWithText:textField.text];
        }
    }
    
    else {
        [passengerInfoArray removeAllObjects];
        [passengerInfoArray addObjectsFromArray:passengerInfoArrayMaster];
        [passengerFilterTabelView reloadData];
    }
}

#pragma mark Filter_Array

-(void)filterTableViewWithText:(NSString *)searchText {
    
    [passengerInfoArrayFilter removeAllObjects];
    [passengerInfoArrayFilter addObjectsFromArray:passengerInfoArrayMaster];
    
    NSPredicate *predicate  = [self setPredicateForMode:mode withText:searchText];
    
    NSArray *filteredArray = [passengerInfoArrayFilter filteredArrayUsingPredicate:predicate];
    [passengerInfoArray removeAllObjects];
    [passengerInfoArray addObjectsFromArray:filteredArray];
    [passengerFilterTabelView reloadData];
    
    [self clearHighlightedSeatsOnCollectionview];
    [self highlightPassengers:passengerInfoArray];
}

#pragma mark Filter Buttons UI

- (IBAction)searchButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}

- (IBAction)filterByCategoryButtonTapped:(id)sender {
    
    UIButton *currentButton = (UIButton *)sender;
    
    if (currentButton.selected == NO) {
        if(self.curent_seatNmum) {
            [self doneButtonTapped];
        }
    }
    
    [self toggleSelectedState:sender];
    
    if (currentButton.selected == YES) {
        
        if(!categoryTableViewController) {
            categoryTableViewController = [[CategoryTableViewController alloc] initWithNibName:@"CategoryTableViewController" bundle:nil];
        }
        categoryTableViewController.passengerInfoArray = passengerInfoArray;
        categoryTableViewController.economyArray = economyEmptySeats;
        categoryTableViewController.bussnessArray = businessEmptySeats;
        categoryTableViewController.passengerInfoArray = passengerInfoArray;
        categoryTableViewController.mealListArray = mealsList;
        categoryTableViewController.lanpassArray = lanPas;
        [passengerSearchTextField setHidden:YES];
        [passengerFilterTabelView setHidden:YES];
        [passengerDetailsViewController.view setHidden:YES];
        
        CGRect frame =  categoryTableViewController.view.frame;
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            frame.origin.y = 68;
            frame.origin.x = 635;
            frame.size.width = 230;
            frame.size.height = 520;
            
        }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            frame.origin.y = 68;
            frame.origin.x = 505;
            frame.size.width = 190;
            frame.size.height = 710;
        }
        categoryTableViewController.view.frame = frame;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [categoryTableViewController reloadTheViews];
        });
        
        categoryTableViewController.view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:categoryTableViewController.view];
    }
    
}
- (IBAction)ffpFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
- (IBAction)vipFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
- (IBAction)smplFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
- (IBAction)spndFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
- (IBAction)cnxFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
- (IBAction)apFilterButtonTapped:(id)sender {
    [self toggleSelectedState:sender];
}
-(void)removeKeyboardifPresentOnScreen {
    [passengerSearchTextField setText:nil];
    [passengerSearchTextField resignFirstResponder];
}
-(void)toggleSelectedState:(id)sender {
    
    [self doneButtonTapped];
    
    UIButton *currentButton = (UIButton *)sender;
    if (previousButton) {
        if (previousButton.tag == currentButton.tag) {
            // return;
        }
        else if (previousButton.tag != currentButton.tag) {
            previousButton.selected = NO;
            passengerSearchTextField.text = nil;
        }
    }
    if (currentButton.selected) {
        currentButton.selected = NO;
        [passengerInfoArray removeAllObjects];
        [passengerInfoArray addObjectsFromArray:passengerInfoArrayMaster];
        [passengerFilterTabelView reloadData];
        if (currentButton.tag == 1) {
            [self removePassengerAndCategoryDetailsViewcontroller];
        }
        else {
            [self clearHighlightedSeatsOnCollectionview];
        }
    }
    
    else {
        currentButton.selected = YES;
        // Set Mode
        [self setFilterMode:(int)currentButton.tag];
        //Filter Array
        [self filterTableViewWithText:nil];
    }
    
    previousButton = currentButton;
}

- (void)setFilterMode:(int)tag {
    switch (tag) {
        case 0:
            // Todo
            mode = no_Filter;
            [passengerSearchTextField becomeFirstResponder];
            passengerSearchTextField.alpha = 1.00;
            [self removePassengerAndCategoryDetailsViewcontroller];
            break;
        case 1:
            // Todo
            mode = category_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            
            break;
        case 2:
            mode = ffp_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 3:
            mode = vip_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 04:
            mode = spml_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 05:
            mode = spnd_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 06:
            mode = cnx_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 07:
            mode = ap_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            
            break;
        case 8:
            // Todo
            mode =no_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            break;
        default:
            mode = no_Filter;
            [passengerSearchTextField resignFirstResponder];
            passengerSearchTextField.alpha = 0.20;
            [self removePassengerAndCategoryDetailsViewcontroller];
            break;
    }
}

-(void)removePassengerAndCategoryDetailsViewcontroller {
    
    if(categoryTableViewController) {
        [categoryTableViewController.view removeFromSuperview];
    }
   
    [passengerDetailsViewController.view setHidden:NO];
    [passengerSearchTextField setHidden:NO];
    [passengerFilterTabelView setHidden:NO];
    
    if (passengerDetailsViewController) {
        [passengerDetailsViewController.view removeFromSuperview];
        [passengerDetailsViewController removeFromParentViewController];
        passengerDetailsViewController = nil;
    }
}

- (NSPredicate *)setPredicateForMode:(FilterType)typeOfMode withText:(NSString*)searchText{
    NSPredicate *predicate = nil;
    switch (typeOfMode) {//
            
        case no_Filter:
            predicate = [NSPredicate predicateWithFormat:@"(firstName CONTAINS[cd]  %@) OR (lastName CONTAINS[cd] %@)", searchText, searchText];
            break;
        case ffp_Filter:
            //Todo
            predicate = [NSPredicate predicateWithFormat:@"(%K != nil && freqFlyerNum != %@ && freqFlyerNum != %@)", @"freqFlyerNum", @"0", @""];
            
            break;
        case vip_Filter:
            //Todo
            //vipCategory
            predicate = [NSPredicate predicateWithFormat:@"(%K != nil) && vipCategory.length > 0 ", @"vipCategory"];
            
            break;
        case spml_Filter:
            
            // predicate = [NSPredicate predicateWithFormat:@"(hasSpecialMeal == %@) OR (hasSpecialMeal == %@)", [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
            predicate = [NSPredicate predicateWithFormat:@"specialMeals[SIZE] > 0", @"specialMeals"];
            
            break;
        case spnd_Filter:
            //
            //  predicate = [NSPredicate predicateWithFormat:@"(isSpecialNeeds == %@) OR (isSpecialNeeds == %@)", [NSNumber numberWithBool:YES],[NSNumber ]];
            predicate = [NSPredicate predicateWithFormat:@"(%K != nil && editCodes.length > 0 && (isWCH == %@ || isChild == %@))", @"editCodes", @YES, @YES];
            
            break;
        case cnx_Filter:
            // predicate = [NSPredicate predicateWithFormat:@"(hasConnection == %@) OR (hasConnection == %@)", [NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
            predicate = [NSPredicate predicateWithFormat:@"cusConnection[SIZE] > 0", @"cusConnection"];
            
            break;
        case ap_Filter:
            //Todo groupCode
            predicate = [NSPredicate predicateWithFormat:@"!(%K != nil && groupCode.length >0  )", @"groupCode"];
            
            break;
        default:
            //Todo
            predicate = [NSPredicate predicateWithFormat:@"(firstName CONTAINS[cd]  %@)", searchText];
            
            break;
    }
    
    if(typeOfMode == no_Filter) {
        return predicate;
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"seatNumber.length > 0"]]];
}

@end



