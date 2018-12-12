//
//  SynchStatusViewController.h
//  Nimbus2
//
//  Created by 720368 on 9/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInformationParser.h"
#import "NSDate+DateFormat.h"
#import "GADViewController.h"
#import "AlertUtils.h"
#import "SynchronizationController.h"
#import "SynchStatusViewController.h"
/* AppDelegate object */
#define APP_DELEGATE1 ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@protocol SynchStatusDelegate<NSObject>
-(void)scrollToFlightReportFromVC:(UIViewController*)VC forFlight:(NSDictionary*)flightDict;
-(void)scrollToGADReportFromVC:(UIViewController *)VC forFlight:(NSDictionary *)flightDict andGADDict:(NSDictionary*)gadDict;
-(void)scrollToCUSReportFromVC:(UIViewController *)VC forFlight:(NSMutableDictionary *)flightDict andCUSDict:(NSDictionary*)cusDict;

-(void)closePopOverforObject:(UIViewController*)VC;
@end
@interface SynchStatusViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (IBAction)closeBtnTapped:(id)sender;
- (IBAction)addFriend:(id)sender;
@property (nonatomic) BOOL isSingleFlight;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (nonatomic,retain)id<SynchStatusDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITableView *statusTableView;
@property (weak, nonatomic) IBOutlet UILabel *statusHeader;
@property (strong,nonatomic) NSMutableArray *statArray;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property  NSString *idflightTemp;
@property  NSString *idReportTemp;
@property  NSString *idCustomer;
@property  NSString *idflightGAD;
@property  NSString *idReportGAD;
@property  NSString *idCustomerGAD;
@property  BOOL *isCUSReportToSend;
@property  BOOL *isGADReportToSend;
@property  BOOL *isFlightReportToSend;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property  UIButton *NameBottonGAD;
@property  UIButton *NameBottonCUS;
@property  UIButton *NameBottonFlight;
@property  NSString *dateflightActual;
@property  NSString *dateflightGad;
@property  NSString *dateReportFlight;
@end
