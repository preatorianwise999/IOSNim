//
//  FlightCardViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Border.h"
#import "NSDate+DateFormat.h"

@interface FlightCardViewController : UIViewController
@property (strong, nonatomic) NSDictionary *flightDict;
@property (weak, nonatomic) IBOutlet UILabel *leg4lbl2;
@property (weak, nonatomic) IBOutlet UILabel *leg4lbl1;
@property (weak, nonatomic) IBOutlet UILabel *leg1lbl1;
@property (weak, nonatomic) IBOutlet UILabel *leg1lbl2;
@property (weak, nonatomic) IBOutlet UILabel *leg2lbl1;
@property (weak, nonatomic) IBOutlet UILabel *leg2lbl2;
@property (weak, nonatomic) IBOutlet UILabel *leg3lbl1;
@property (weak, nonatomic) IBOutlet UILabel *leg3lbl2;
@property (weak, nonatomic) IBOutlet UILabel *flightNumber;
@property (weak, nonatomic) IBOutlet UILabel *flightDate;
@property (weak, nonatomic) IBOutlet UILabel *leg1Origin;
@property (weak, nonatomic) IBOutlet UILabel *leg1dest;
@property (weak, nonatomic) IBOutlet UILabel *leg2dest;
@property (weak, nonatomic) IBOutlet UILabel *leg3dest;
@property (weak, nonatomic) IBOutlet UILabel *leg4dest;
@property (weak, nonatomic) IBOutlet UILabel *lastSynchTime;
@property (weak, nonatomic) IBOutlet UILabel *leg1StartTime;
@property (weak, nonatomic) IBOutlet UILabel *leg1StartDate;
@property (weak, nonatomic) IBOutlet UILabel *leg1EndTime;
@property (weak, nonatomic) IBOutlet UILabel *leg1EndDate;
@property (weak, nonatomic) IBOutlet UILabel *leg2StartTime;
@property (weak, nonatomic) IBOutlet UILabel *leg2StartDate;
@property (weak, nonatomic) IBOutlet UILabel *leg2EndTime;
@property (weak, nonatomic) IBOutlet UILabel *leg2EndDate;
@property (weak, nonatomic) IBOutlet UILabel *leg3StartTime;
@property (weak, nonatomic) IBOutlet UILabel *leg3StartDate;
@property (weak, nonatomic) IBOutlet UILabel *leg3EndTime;
@property (weak, nonatomic) IBOutlet UILabel *leg3EndDate;
@property (weak, nonatomic) IBOutlet UILabel *leg4StartTime;
@property (weak, nonatomic) IBOutlet UILabel *leg4StartDate;
@property (weak, nonatomic) IBOutlet UILabel *leg4EndTime;
@property (weak, nonatomic) IBOutlet UILabel *leg4EndDate;
@property (weak, nonatomic) IBOutlet UIImageView *breifinInfoIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *seatMapIndicator;



- (IBAction)buttonClicked:(id)sender;



@end
