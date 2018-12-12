//
//  CUSReportViewController.h
//  Nimbus2
//
//  Created by Dreamer on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestView.h"
#import "LTFlightReportCameraPopOverViewController.h"
#import "LTDetailCUSReportViewController.h"
#import "FlightRoaster.h"
#import "LTAddCustomerViewController.h"
#import "CUSReportImages.h"
#import "TestViewCameraViewController.h"
#import "CusReport.h"

@protocol CUSReportDelegate <NSObject>

-(void)finishedSavingCUSReport;
@end

@interface CUSReportViewController : UIViewController<UITextFieldDelegate,PopoverDelegate,UIPopoverControllerDelegate,LTFlightReportCameraProtocol>


@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *frequentFlyerLabel;
@property (strong,nonatomic) NSString *reportId;

@property (weak, nonatomic) IBOutlet UIView *cusotmerReportView;
@property (nonatomic,strong) NSMutableArray *associatedLegArray;
@property (nonatomic,strong) NSMutableArray *seatManteinanceArray;
@property (nonatomic,strong) NSMutableArray *passingerInfoArray;
@property (nonatomic,strong) NSMutableArray *actionTakenArray;
@property (nonatomic,strong) NSManagedObjectContext *localMoc;
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (strong,nonatomic) FlightRoaster *flightRoster;
@property (nonatomic,strong) NSArray *cusreportArray;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (nonatomic,strong)LTDetailCUSReportViewController *detailCUSReportViewController;
//@property (nonatomic,strong)LTTAMDetailCUSReportViewController *detailTAMCUSReportViewController;
@property (nonatomic,strong) NSMutableArray *legsArray1;
@property (nonatomic,strong) NSMutableDictionary *customerDict;
@property (nonatomic, strong) NSMutableDictionary *flightDict;
@property (nonatomic,strong) CUSReportImages *cusReportImages;
@property (nonatomic,strong) Customer *customer;
@property (nonatomic,strong) CusReport *report;
@property (nonatomic) BOOL readonly;
@property (nonatomic) BOOL doseNotHaveSeatMap;
@property (assign, nonatomic) id <CUSReportDelegate> delegate;

@property(weak,nonatomic)IBOutlet NSLayoutConstraint *cusReportTopConstraint;

@property(weak,nonatomic)IBOutlet NSLayoutConstraint *cusReportToLeadingConstraint;

@property(weak,nonatomic)IBOutlet NSLayoutConstraint *cusReportWidthConstraint;
@property (nonatomic) TestViewCameraViewController *cameraVC;
@property (weak, nonatomic) IBOutlet TestView *activeTestView;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)sendReportButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
