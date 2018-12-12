//
//  PassengerDetailsViewController.h
//  Nimbus2
//
//  Created by Rajashekar on 20/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SeatMapViewController.h"
#import "CUSReportViewController.h"
#import "SelectedTextTableViewCell.h"
#import "detailTableViewCell.h"
#import  "AcompanantesTableViewCell.h"
#import "SolicitudeTableViewCell.h"
#import "ConexionesTableViewCell.h"
#import "GetSeatMapData.h"
#import "Passenger.h"
#import "DocNumberViewController.h"

@protocol doneButtonTappedProtocol<NSObject>
-(void)doneButtonTapped;
-(void)reportCusButtonTapped:(Passenger *)passenger;
@end
@interface PassengerDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,UITextFieldDelegate,DocNumberPopoverProtocol>

@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (nonatomic,retain) id<doneButtonTappedProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic,retain) Passenger *currentPassenger;
@property (nonatomic,retain) Passenger *currentPassengertemp;
@property NSString *classNameType;
- (IBAction)doneButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *reportCusButton;
@property(retain,nonatomic) NSString *strSeatNumber;
- (IBAction)reportCusButtonTapped:(id)sender;
@property NSString *selectedSeat;
@property NSArray *acompaniesDataArray;
@property BOOL selectPassenger;
@property BOOL isClicked;
@property int temp_height;
@property int legIndex;
-(void)disableCusReportButton:(NSString *)reportStatus;
- (void)reloadConstraints;
@end