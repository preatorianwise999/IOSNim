//
//  FTSideMenuViewController.h
//  Nimbus2
//
//  Created by Vishal on 28/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightRoaster.h"


@protocol FTSideMenuViewControllerProtocol<NSObject>

- (void)didSelectSectionAtIndex:(NSString *)section flightType:(NSString *)typeOfFlight selection:(NSString *)selection ;//atIndex:(int)indexSelected

@optional
- (void)sendReportSelected;
- (void)viewSummarySelected;
- (void)sendReportWithNoLegExecuted;
- (void)resendReport;

@end



@interface FTSideMenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *sideMenu_TableView;
@property(nonatomic, retain) id<FTSideMenuViewControllerProtocol> delegate;


@property(nonatomic,retain) NSMutableArray *sectionArray;
@property(nonatomic,retain) NSMutableDictionary *flightReportDictionary;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UITableView *reportTableView;


@property(nonatomic,retain) NSString *flightType;


@property(strong,nonatomic) IBOutlet UIView *bothSummarySendView;
@property(strong,nonatomic) IBOutlet UIView *viewSummaryView;
@property(weak,nonatomic) IBOutlet UIImageView *sendIcon;
@property(weak,nonatomic) FlightRoaster *roaster;

@property(strong, nonatomic) IBOutlet UIButton *viewSummaryBtn;
@property(strong, nonatomic) IBOutlet UIButton *resendReportBtn;
@property(strong, nonatomic) IBOutlet UIButton *viewSummaryResendBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSummaryBtnWidthConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bothviewSummaryBtnWidthConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bothviewresendBtnWidthConstarint;

@property BOOL isLegPressedFirstTime;
- (IBAction)sendReport:(UIButton *)sender;

//- (IBAction)sendReport:(UIButton *)sender;

//- (IBAction)sendReport:(UIButton *)sender;
- (IBAction)resendReport:(UIButton *)sender;
-(IBAction)summaryReport:(UIButton *)sender;

-(void)statusChanged:(NSNotification *)notification;




@end
