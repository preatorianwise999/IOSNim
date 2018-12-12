//
//  AddManualFlightViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OffsetCustomCell.h"
#import "NSDate+DateFormat.h"
#import "FlightTypePopoverController.h"
#import "AddRowCell.h"
#import "LegInformationCell.h"
#import "ActivityIndicatorView.h"
#import "SynchronizationController.h"
#import "LTSingleton.h"
#import "LTDeleteOlderFlight.h"
#import "UserInformationParser.h"
#import "FlightRoaster.h"
#import "LTFlightRoaster.h"

@protocol AddManualFlightDelegate<NSObject>
-(void)closePopOverforObject:(UIViewController*)VC;
-(void)manualFlightAdded:(NSDictionary*)flightDict;
-(void)updateCarousal;
@end

@interface AddManualFlightViewController : UIViewController<FlightTypePopoverProtocol,UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate,UIAlertViewDelegate>{
    AppDelegate *appDel;
    UITextField *currentTxtField;
    UITextField *presentTxtFld;
    NSString *alertMessage;
    NSMutableDictionary *flightInfoDict;//GVD
    NSMutableDictionary *flightDict;
    NSMutableDictionary *flightDictSave;

    NSMutableDictionary *flightJsonData;
    LTSingleton *singleton;
    FlightRoaster *roaster;
    BOOL shouldAddFlight;
    SynchronizationController *synch;
    NSMutableDictionary *responseDict;
    _Bool manualEnter;
    BOOL departDateManually;
    NSDate *flightDate;
    
}
- (BOOL)validateFields;

- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)trashButtonClicked:(id)sender;

- (IBAction)getDataButtonClicked:(id)sender;
//- (IBAction)saveButtonTapped:(UIButton *)sender;
- (IBAction)cancelTapped:(UIButton *)sender;
- (IBAction)popoverTap:(UIButton *)sender;
-(id)initWithFlightDataObject:(NSMutableDictionary *)flightDictionary WithMode:(enum flightAddMode)flightMode;
-(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)mode;
-(void)addUpdateDB:(BOOL)ShouldAdd;
-(void)validateDates:(NSDate *)departureString withArrival:(NSDate *)arrivalString;
-(void)validateDestinationAndDepartureWith:(NSDate *)departureDate Time:(NSDate *)departureTime;
-(FlightRoaster *)getFlightObjectFromDict:(NSMutableDictionary*)flightDict forManageObjectContext:(NSManagedObjectContext*)context;
@property (nonatomic,retain)id<AddManualFlightDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITableView *legTableView;
@property (nonatomic)enum flightAddMode mode;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *flightTypeButton;
@property (weak, nonatomic) IBOutlet UITextField *flightNumberTextView;
@property (weak, nonatomic) IBOutlet UIButton *flightDateButton;
@property (weak, nonatomic) IBOutlet UIButton *materialButton;
@property (weak, nonatomic) IBOutlet UITextField *matriculaTextView;
@property(nonatomic,retain) NSMutableArray *legDataArray;
//@property(nonatomic,retain) FlightRoaster *flightData;
@property(nonatomic,strong) NSMutableDictionary *flightDataDict;
@property(nonatomic,retain) NSMutableArray *deleteLegaArray;
@property (weak, nonatomic) IBOutlet UIButton *trashBtn;
@property (nonatomic) TestView *activeTestView;
@end
