//
//  FlightReportViewController.m
//  Nimbus2
//
//  Created by Vishal on 28/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightReportViewController.h"
#import "FTSideMenuViewController.h"
#import "FTCarouselViewController.h"
#import "SMPageControl.h"
#import "LTSingleton.h"
#import "AppDelegate.h"
#import "LegsModel.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomViewController.h"
#import "ViewSummaryController.h"

#import "Legs.h"
#import "NSDate+DateFormat.h"
#import "DropDownViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SynchronizationController.h"

#import "SaveFlightData.h"



@interface FlightReportViewController () {
    FTSideMenuViewController *sideMenuViewController;
    FTCarouselViewController *vc;
    CustomViewController *detailController;
    AppDelegate *appDel;
    int legsCount;
    UIView *animateView;
    ViewSummaryController *viewSummaryCont;
    
    //Leg Implementation
    UIView *view1;
    
    UIPopoverController *popoverController;
    DropDownViewController *dropDownObject;
    IBOutlet UILabel *lineLeft;
    IBOutlet UILabel *lineRight;
    IBOutlet UIButton *backBtn;
    AVAudioPlayer *player;
    BOOL isLegPressedFirstTime;
    UINavigationController *navigationController;
    UIViewController *detailViewController_Ref;
}
@property (weak, nonatomic) IBOutlet SMPageControl *pageController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewHorizontalConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHorizonatalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewheightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthConstraint;

@end

@implementation FlightReportViewController
@synthesize legArray, flightNumLbl, delegate,infoValidationBtn,validityDataSource,roaster;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [LTSingleton getSharedSingletonInstance].enableCells = YES;
    if ([[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"] boolValue] == NO) {
        [LTSingleton getSharedSingletonInstance].enableCells = NO;
    }
    
    [LTSingleton getSharedSingletonInstance].isDataChanged = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validationListEmpty:) name:@"MandatoryFields" object:nil];
    validityDataSource = [[NSMutableArray alloc] init];
    appDel = (AppDelegate *)([UIApplication sharedApplication].delegate);
    
    // @nimbus [backBtn setTitle:[appDel copyTextForKey:@"BACK"] forState:UIControlStateNormal];
    self.flightReportLabel.text = [appDel copyTextForKey:@"FLIGHT_REPORT"];
    
    flightNumLbl.text = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingFormat:@" %@",[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
    // @nimbus [self drawLegs];
    self.isLegPressedFirstTime = YES;
    self.legArray = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"];
    
    [self loadSideMenuViewInContainer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self orientationChanged:nil];
}

-(void)orientationChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:isSummaryClicked]) {
            [viewSummaryCont.view setCenter:self.parentViewController.view.center];
            viewSummaryCont.view.frame = self.parentViewController.view.frame;
            [self.parentViewController.view addSubview:viewSummaryCont.view];
        }
        CGRect viewSummaryWidth = viewSummaryCont.view.frame;
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            self.rightViewHorizonatalConstraint.constant = 0;
            self.leftViewHorizontalConstraint.constant = 0;
            self.leftViewWidthConstraint.constant = 180;
            self.rightViewWidthConstraint.constant = 560;
            viewSummaryWidth.size.width = 768;
            viewSummaryWidth.size.height = 1024;
            [self.view layoutIfNeeded];
        } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            self.rightViewHorizonatalConstraint.constant = 44;
            self.leftViewHorizontalConstraint.constant = 28;
            self.leftViewWidthConstraint.constant = 230;
            self.rightViewWidthConstraint.constant = 600;
            viewSummaryWidth.size.width = 1024;
            viewSummaryWidth.size.height = 768;
            [self.view layoutIfNeeded];
        }
        if([[NSUserDefaults standardUserDefaults] boolForKey:isSummaryClicked]) {
            viewSummaryCont.view.frame = viewSummaryWidth;
        }
        
        [self.view updateConstraints];
        if([popoverController isPopoverVisible]) {
            [popoverController dismissPopoverAnimated:NO];
            [self performSelector:@selector(showValidationList:) withObject:nil afterDelay:0.2];
        }
        
        [vc.carouseView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
    });
}

- (void) loadSideMenuViewInContainer {
    sideMenuViewController = [[FTSideMenuViewController alloc] initWithNibName:@"FTSideMenuViewController" bundle:nil];
    sideMenuViewController.delegate = self;
    sideMenuViewController.roaster = self.roaster;
    sideMenuViewController.isLegPressedFirstTime = YES;
    sideMenuViewController.flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
    legsCount = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] count];
    [_sideMenuContainerView addSubview:sideMenuViewController.view];
}

- (void) loadPageControllerWithTotalPages:(int)totalCount {
    _pageController.numberOfPages = totalCount;
    _pageController.indicatorMargin = 10.0f;
    _pageController.indicatorDiameter = 10.0f;
    _pageController.alignment = SMPageControlAlignmentCenter;
    [_pageController setCurrentPageIndicatorImage:[UIImage imageNamed:@"sel.png"]];
    [_pageController setPageIndicatorImage:[UIImage imageNamed:@"desel.png"]];
    [_pageController addTarget:self action:@selector(spacePageControl:) forControlEvents:UIControlEventValueChanged];
}

- (void)spacePageControl:(SMPageControl *)sender {
    NSLog(@"Current Page (SMPageControl): %li", (long)sender.currentPage);
}

#pragma mark - Delegate For OnSelectionInMenu
/*
 @purpose : cell selected in sideMenu
 @params  :
 @returns : --
 */

-(void)didSelectSectionAtIndex:(NSString *)section flightType:(NSString *)typeOfFlight selection:(NSString *)selection {
    
    if([typeOfFlight isEqualToString:@"DMTAM"]) {
        typeOfFlight = @"DMTAM";
    }
    else if([typeOfFlight isEqualToString:@"DMLAN"]) {
        typeOfFlight = @"DMLAN";
    }
    
    NSString *pathString = [NSString stringWithFormat:@"%@_Controller",typeOfFlight];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pathString ofType:@"plist"]];
    NSString *name = [[plistDictionary objectForKey:section] objectForKey:selection];
    
    if(detailController) {
        [detailController.view removeFromSuperview];
        detailController = nil;
    }
    [self loadPageControllerWithTotalPages:legsCount];
    
    vc = [[FTCarouselViewController alloc] initWithNibName:@"FTCarouselViewController" bundle:nil legsCount:legsCount controllerName:name];
    vc.delegate = self;
    detailController = (CustomViewController *) vc;
    detailController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.detailsContainerView addSubview:detailController.view];
    
    [self.detailsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:detailController.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailsContainerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.detailsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:detailController.view
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailsContainerView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.detailsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:detailController.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailsContainerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.detailsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:detailController.view
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailsContainerView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
}

#pragma mark - Delegate For OnSelectionInMenu

- (void)didScrollToIndex:(NSInteger)index withTotalItems:(NSInteger)totalItem {
    _pageController.currentPage = index;
    _pageController.numberOfPages = totalItem;
    [self LegBtnPressed:index];
}

#pragma mark - Saving & Preparing Form methods
//Save the form data whenever switching away from the current form
- (void)saveDraft {
    
    NSMutableDictionary *legDictionay = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber];
    if([[legDictionay objectForKey:@"reports"] count] > 0
       &&
       [[[[legDictionay objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] count] > 0
       &&
       [[[[[[legDictionay objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] objectForKey:@"groups"] count] > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:[legDictionay objectForKey:@"destination"] forKey:@"destination"];
        [dict setObject:[legDictionay objectForKey:@"origin"] forKey:@"origin"];
        [SaveFlightData saveEventWithFlightRoasterDict:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:dict];
    }
}

-(void)prepareFlightRoasterDictWithLegIndex:(int)index {
    
}

-(void)LegBtnPressed:(int)currentIndex {
    
    if(!self.isLegPressedFirstTime) {
        [NSThread detachNewThreadSelector:@selector(loadSpinner) toTarget:self withObject:nil];
    }
    
    [LTSingleton getSharedSingletonInstance].legPressed = YES;
    [LTSingleton getSharedSingletonInstance].isFromMasterScreen = YES;
    
    UIView *currentResponder = (UIView *)[[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)];
    
    if([currentResponder isKindOfClass:[UITextField class]] || [currentResponder isKindOfClass:[UITextView class]]) {
        CustomViewController *controller;
        if(ISiOS8) {
            controller = (CustomViewController *)[[[[[[currentResponder nextResponder] nextResponder] nextResponder] nextResponder] nextResponder] nextResponder];
        }
        else
            controller = (CustomViewController *)[[[[[[[currentResponder nextResponder] nextResponder] nextResponder] nextResponder] nextResponder] nextResponder] nextResponder];
        
        [currentResponder isKindOfClass:[UITextField class]] ?[controller textFieldDidEndEditing:(UITextField *)currentResponder]:[controller textViewDidEndEditing:(UITextView *)currentResponder];
        [LTSingleton getSharedSingletonInstance].legPressed = NO;
    }
    
    NSMutableArray *tempArray = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"groups"];
    
    NSArray *resultArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",[appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"]]];
    
    if([resultArray count] != 0) {
        NSMutableDictionary *temp = [resultArray firstObject];
        if([[temp objectForKey:@"name"] isEqualToString:[appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"]]){
            [LTSingleton getSharedSingletonInstance].generalDictionary = [temp mutableCopy];
        }
    }
    //Saving Logic
    DLog("%s",__PRETTY_FUNCTION__);
    [self saveDraft];
    
    [LTSingleton getSharedSingletonInstance].legNumber = currentIndex;
    
    if(!self.isLegPressedFirstTime) {
        if([LTSingleton getSharedSingletonInstance].sendReport)
            [self performSelector:@selector(stopSpinner) withObject:nil afterDelay:0.3];
        else
            [self performSelector:@selector(stopSpinner) withObject:nil afterDelay:0.1];
    }
    
    NSDictionary *legdict=[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
    NSString *key = [NSString stringWithFormat:@"%@-%@",[legdict objectForKey:@"origin"],[legdict objectForKey:@"destination"] ];
    
    NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
    if([[[LTSingleton getSharedSingletonInstance].legExecutedDict objectForKey:key] isEqualToString:@"NO"]>0 || [numJSB boolValue]==YES){
        [LTSingleton getSharedSingletonInstance].enableCells=YES;
    }
    self.isLegPressedFirstTime = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"legScroll" object:nil];
}

-(void)loadSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        if(animateView)
            [animateView removeFromSuperview];
        if(ISiOS8) {
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        }
        else {
            animateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
        }
        animateView.userInteractionEnabled = NO;
        
        [animateView setBackgroundColor:[UIColor blackColor]];
        animateView.alpha = 0.3;
        
        UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityInd.center = animateView.center;
        [animateView addSubview:activityInd];
        
        [activityInd startAnimating];
        
        [self.view.window addSubview:animateView];
    });
}

-(void)stopSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [animateView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

-(void)viewSummarySelected {
    [self saveDraft];
    [self viewSummary];
}

-(void)sendReportSelected {
    [self saveDraft];
    [LTSingleton getSharedSingletonInstance].sendReport = YES;
  
    CustomViewController *customViewContrller =  (CustomViewController*)[[LTSingleton getSharedSingletonInstance].flightReportViewControllersArray objectAtIndex:kCurrentLegNumber];
    
    if([customViewContrller isKindOfClass:[CustomViewController class]]) {
        [customViewContrller.tableView reloadData];
        if([customViewContrller respondsToSelector:@selector(updateReportDictionary)]) {
            [customViewContrller updateReportDictionary];
        }
    }
    
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       
        DLog(@"Dict:%@",[LTSingleton getSharedSingletonInstance].reportDictionary);
        
        [self formDataSource];
        if(![self.validityDataSource count] == 0) {
            self.infoValidationBtn.hidden = NO;
            [self showValidationList:nil];
        }
        else {
            NSNotification *notification = [NSNotification notificationWithName:@"MandatoryFields" object:nil userInfo:@{@"Hidden":[NSNumber numberWithBool:FALSE]}];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_SENDREPORT"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"SEND_REPORT"],[appDel copyTextForKey:@"VIEW_SUMMARY"], nil];
            
            if ([AlertUtils checkAlertExist]) {
                alert.delegate = self;
                [alert show];
            }
        }
    });
}

-(void)sendReportWithNoLegExecuted {
    [self saveDraft];
    [LTSingleton getSharedSingletonInstance].sendReport = NO;
    
    
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[appDel copyTextForKey:@"ALERT_SENDREPORT"] delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"SEND_REPORT"],[appDel copyTextForKey:@"VIEW_SUMMARY"], nil];
        
        if ([AlertUtils checkAlertExist]) {
            alert.delegate = self;
            [alert show];
        }
    });
}

-(void)resendReport {
    [self sendReport];
}

-(void)validationListEmpty:(NSNotification *)notification{
    [self formDataSource];
    BOOL setVisible = YES;
    
    
    if ([validityDataSource count]==0) {
        setVisible = NO;
    } else {
        setVisible = YES;
    }
    if (setVisible) {
        self.infoValidationBtn.hidden = ![[[notification userInfo] objectForKey:@"Hidden"] boolValue];
    } else {
        self.infoValidationBtn.hidden = YES;
    }
}

-(void)formDataSource {
    [validityDataSource removeAllObjects];
    
    NSMutableDictionary *reportDictionary = [LTSingleton getSharedSingletonInstance].reportDictionary;
    
    for(NSString *section in sideMenuViewController.sectionArray) {
        NSMutableDictionary *sectionDictionary = [reportDictionary objectForKey:section];
        
        for(NSString *group in [sideMenuViewController.flightReportDictionary objectForKey:section]) {
            
            NSArray *mandatoryLegArray = [sectionDictionary objectForKey:group];
            for(NSNumber *legElement in mandatoryLegArray) {
                if ([legElement intValue]>[self.legArray count]) {
                    return;
                }
                NSMutableDictionary *leg = [self.legArray objectAtIndex:[legElement intValue] - 1];
                
                if ([[[LTSingleton getSharedSingletonInstance].legExecutedDict objectForKey:[NSString stringWithFormat:@"%@-%@",[leg objectForKey:@"origin"],[leg objectForKey:@"destination"]]] isEqualToString:@"YES"]) {
                    [validityDataSource addObject:[NSString stringWithFormat:@"%@-%@ %@ %@ %@ %@",[leg objectForKey:@"origin"],[leg objectForKey:@"destination"],kSysbolForSeparator,section,kSysbolForSeparator,[appDel copyTextForKey:group]]];
                }
            }
        }
    }
}

-(void)viewSummary {
    viewSummaryCont = [[ViewSummaryController alloc] initWithNibName:@"ViewSummaryController" bundle:nil];
    [viewSummaryCont.view setCenter:self.parentViewController.view.center];
    viewSummaryCont.view.frame = self.parentViewController.view.frame;
    viewSummaryCont.flightReportViewCont = self;
    [self.parentViewController.view addSubview:viewSummaryCont.view];
}

-(void)sendReport {
    [NSThread detachNewThreadSelector:@selector(playSound) toTarget:self withObject:nil];
    
    NSNotification *noti = [NSNotification notificationWithName:kStatusChanged object:nil userInfo:@{@"status":[NSNumber numberWithInt:inqueue]}];
    [sideMenuViewController statusChanged:noti];
    [LTSingleton getSharedSingletonInstance].enableCells = FALSE;
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.counter = 0;
    synch.delegate = self;
    [synch sendCreatedFlightReport];
    
    if(![synch checkForInternetAvailability]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"SEND_REPORT_OFFLINE_MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"index==%d", buttonIndex);
    if (buttonIndex == 2) {
        [self viewSummary];
    } else if (buttonIndex == 1) {
        [self sendReport];
    }
}

//Play send report audio file
-(void)playSound {
    
}

-(void)selectedValueInDropdown:(DropDownViewController *)obj {
    
}

- (IBAction)showValidationList:(UIButton *)sender {
    [self formDataSource];
    dropDownObject = [[DropDownViewController alloc] initWithData:self.validityDataSource withCheckMark:NO];
    navigationController = [[UINavigationController alloc]initWithRootViewController:dropDownObject];
    dropDownObject.title = [appDel copyTextForKey:@"MISSING_MANDAROTY_ITEMS"];
    if(popoverController) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
    popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    dropDownObject.delegate = self;
    if(ISiOS8) {
        navigationController.preferredContentSize = CGSizeMake(500, (self.validityDataSource.count + 1)*45);
    }
    else
        [popoverController setPopoverContentSize:CGSizeMake(500, (self.validityDataSource.count + 1)*45) animated:NO];
    [dropDownObject.tableView reloadData];
    
    if(![popoverController isPopoverVisible])
        [popoverController presentPopoverFromRect:self.infoValidationBtn.frame inView:self.infoValidationBtn.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


@end
