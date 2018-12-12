//
//  FlightViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "FlightCardViewController.h"
#import "TabBarController.h"
#import "TestView.h"
#import "DropDownViewController.h"
#import "AddManualFlightViewController.h"
#import "NSDate+DateFormat.h"
#import "FlightTypeMessageBox.h"
#import "LTSingleton.h"
#import "SynchronizationController.h"
#import "SynchStatusViewController.h"
#import "AlertUtils.h"
#import "ManualViewController.h"


@interface FlightViewController : UIViewController<iCarouselDataSource, iCarouselDelegate,PopoverDelegate,DropSelectionDelegate,FlightTypePopoverProtocol,SynchDelegate,AddManualFlightDelegate,SynchStatusDelegate,UIAlertViewDelegate,StoreManualsDelegate, UIGestureRecognizerDelegate>
{
    FlightCardViewController *fcView;
    FlightTypeMessageBox *flightTypeMessageBox;
    AddManualFlightViewController *manualFlight;
    BOOL noFlightForNext7days;
    SynchStatusViewController *statusVC;

}

//@property (strong, nonatomic) IBOutlet SynchStatusViewController *syncStatusVC;

@property (weak, nonatomic) IBOutlet UIView *dropView;
@property (nonatomic,strong) NSMutableArray *carousalFlights;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *langview;
@property (strong,nonatomic) NSMutableArray *statArray;
@property (nonatomic, strong) NSArray *flightArray;
@property (nonatomic,strong)   UIPopoverController *dropDownPopoverController;
@property (nonatomic,strong) DropDownViewController *dropDonwView;
@property(nonatomic,retain) NSString *flightType;
@property(nonatomic, retain)NSString *materialType;
@property(nonatomic, retain)NSString *businessUnit;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMsgLbl;
@property (weak, nonatomic) IBOutlet UIButton *signoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *synchBtn;

@property (weak, nonatomic) IBOutlet UISegmentedControl *languageSegment;
@property (nonatomic,weak)  IBOutlet NSLayoutConstraint *nameLabelWidth;
@property (nonatomic,weak)  IBOutlet NSLayoutConstraint *buttonSpacing;
- (IBAction)userBtnTapped:(id)sender;
- (IBAction)synchBtnClicked:(id)sender;

- (IBAction)noFlyingJSBBtnClicked:(id)sender;
- (IBAction)actualizaDataBtnClicked:(id)sender;
- (IBAction)languageChanged:(id)sender;
- (IBAction)signOutBtnTapped:(id)sender;
- (IBAction)StatusBtnTapped:(id)sender;

- (void)startDownloadingManuals;

- (IBAction)manualButtonClicked:(id)sender;
- (IBAction)addManualFlightClicked:(id)sender;
@end
