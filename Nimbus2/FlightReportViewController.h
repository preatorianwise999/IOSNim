//
//  FlightReportViewController.h
//  Nimbus2
//
//  Created by Vishal on 28/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSideMenuViewController.h"
#import "FTCarouselViewController.h"
#import "AlertUtils.h"
#import "DropDownViewController.h"
#import "SynchronizationController.h"
#import "CustomViewController.h"

@interface FlightReportViewController : UIViewController <FTSideMenuViewControllerProtocol, FTCarouselViewControllerDelegate, DropSelectionDelegate, UIAlertViewDelegate, SynchDelegate>
@property (weak, nonatomic) IBOutlet UIView *detailsContainerView;
@property (weak, nonatomic) IBOutlet UIView *sideMenuContainerView;

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *legView;
@property (strong, nonatomic) NSArray *legArray;
@property (weak, nonatomic) IBOutlet UILabel *flightNumLbl;
@property (weak, nonatomic) IBOutlet UILabel *flightReportLabel;
@property id delegate;

@property (weak,nonatomic) IBOutlet UIButton *infoValidationBtn;
@property (nonatomic,retain) NSMutableArray *validityDataSource;
@property(nonatomic,retain) FlightRoaster *roaster;
@property BOOL isLegPressedFirstTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageControlLeadConstraint;


- (IBAction)backClicked:(id)sender;
- (IBAction)showValidationList:(UIButton *)sender;

@end