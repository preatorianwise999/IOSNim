//
//  TabBarController.h
//  Nimbus2
//
//  Created by 720368 on 7/13/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightDetailsViewController.h"
#import "CrewViewController.h"
#import "iCarousel.h"
#import "SeatMapViewController.h"
#import "SynchStatusViewController.h"


@interface TabBarController : UIViewController<iCarouselDataSource, iCarouselDelegate,SynchStatusDelegate>{
    UINavigationController *navC;
    UIViewController *previousViewController;
    UIViewController *tempViewController;
    FlightDetailsViewController *vc;
    CrewViewController *cvc;
    SeatMapViewController *svc;
    IBOutlet UIView *_landscapeView;
    IBOutlet UIView *_portraitView;
    UIView *_currentView;
    SynchStatusViewController *statusVC;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *flightNumberLabel;
@property (strong, nonatomic)   IBOutlet iCarousel *legScrollView;
@property (weak, nonatomic)     IBOutlet UIView *selectorView;
@property (weak, nonatomic)     IBOutlet UIView *selectorViewPortrait;
@property (strong, nonatomic)     UIButton *selectedButton;

@property (strong, nonatomic)   IBOutlet UIImageView *selectorImage;
@property (strong, nonatomic)   IBOutlet UIImageView *selectorImagePortrait;

@property (weak, nonatomic)     IBOutlet UIView *containerView;
@property (weak, nonatomic)     IBOutlet UILabel *flightLabel;
@property (weak, nonatomic)     IBOutlet UILabel *crewLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic)     IBOutlet UILabel *seatLabel;
@property (weak, nonatomic)     IBOutlet UILabel *reportLabel;
@property (weak, nonatomic)     IBOutlet UIButton *flightButton;
@property (weak, nonatomic) IBOutlet UIButton *flightPortraitButton;
@property (nonatomic) NSInteger selectedTabIndex;
@property (nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet UILabel *flightLabelPortrait;
@property (weak, nonatomic) IBOutlet UILabel *crewLabelPortrait;
@property (weak, nonatomic) IBOutlet UILabel *seatLabelPortrait;

@property (weak, nonatomic) IBOutlet UILabel *reportLabelPortrait;



- (IBAction)statusButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)flightButtonClicked:(id)sender;
- (IBAction)crewButtonClicked:(id)sender;
- (IBAction)seatButtonClicked:(id)sender;
- (IBAction)reportButtonClicked:(id)sender;


@end
