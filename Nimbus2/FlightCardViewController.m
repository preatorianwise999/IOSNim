//
//  FlightCardViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightCardViewController.h"
#import "LTSingleton.h"
@interface FlightCardViewController ()

@end

@implementation FlightCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupCardforDict:_flightDict];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSeatIcon) name:@"seatMapActualized" object:nil];
    
    //[self.leg1lbl1 createArcPathFromstart:20 end:70 withDistance:0];
}

-(void)updateSeatIcon {
    
    [self.seatMapIndicator setAlpha:1.0];
}

-(void)setupCardforDict:(NSDictionary*)flightDict {
    NSDictionary *fkeyDict = [flightDict objectForKey:@"flightKey"];
    self.flightNumber.text = [NSString stringWithFormat:@"%@ %@",[fkeyDict objectForKey:@"airlineCode"],[fkeyDict objectForKey:@"flightNumber"]];
    NSDate *fdate = [fkeyDict objectForKey:@"flightDate"];
    
    self.flightDate.text = [fdate dateFormat:DATE_FORMAT_EEEE_dd_MMMM];
    if ([[flightDict objectForKey:@"isPublicationSynched"] boolValue]) {
        [self.breifinInfoIndicator setAlpha:1.0];
    }
    if ([[flightDict objectForKey:@"isFlightSeatMapSynched"] boolValue]) {
        [self.seatMapIndicator setAlpha:1.0];
    }
    
    NSArray *legArray = [flightDict objectForKey:@"legs"];
    for (int index = 0; index<[legArray count]; index++) {
        NSDictionary *legDict = [legArray objectAtIndex:index];
        if (index==0) {
            _leg1Origin.text = [legDict objectForKey:@"origin"];
            _leg1dest.text = [legDict objectForKey:@"destination"];
            NSDate *startDate = [legDict objectForKey:@"departureLocal"];
            _leg1StartDate.text = [startDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg1StartTime.text = [startDate dateFormat:DATE_FORMAT_HH_mm];
            NSDate *endDate = [legDict objectForKey:@"arrivalLocal"];
            _leg1EndDate.text = [endDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg1EndTime .text= [endDate dateFormat:DATE_FORMAT_HH_mm];
            NSArray *seatArray = [legDict objectForKey:@"seat"];
            for (NSDictionary *seatdict in seatArray) {
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"BC"]) {
                    [self.leg1lbl1 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"JC"]) {
                    [self.leg1lbl2 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
            }
            
        }
        else if (index==1) {
            _leg2dest.text = [legDict objectForKey:@"destination"];
            NSDate *startDate = [legDict objectForKey:@"departureLocal"];
            _leg2StartDate.text = [startDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg2StartTime.text = [startDate dateFormat:DATE_FORMAT_HH_mm];
            NSDate *endDate = [legDict objectForKey:@"arrivalLocal"];
            _leg2EndDate.text = [endDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg2EndTime .text= [endDate dateFormat:DATE_FORMAT_HH_mm];
            
            
            NSArray *seatArray = [legDict objectForKey:@"seat"];
            for (NSDictionary *seatdict in seatArray) {
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"BC"]) {
                    [self.leg2lbl1 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"JC"]) {
                    [self.leg2lbl2 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
            }
            
        }
        else if (index==2) {
            _leg3dest.text = [legDict objectForKey:@"destination"];
            NSDate *startDate = [legDict objectForKey:@"departureLocal"];
            _leg3StartDate.text = [startDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg3StartTime.text = [startDate dateFormat:DATE_FORMAT_HH_mm];
            NSDate *endDate = [legDict objectForKey:@"arrivalLocal"];
            _leg3EndDate.text = [endDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg3EndTime .text= [endDate dateFormat:DATE_FORMAT_HH_mm];
            
            NSArray *seatArray = [legDict objectForKey:@"seat"];
            for (NSDictionary *seatdict in seatArray) {
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"BC"]) {
                    [self.leg3lbl1 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"JC"]) {
                    [self.leg3lbl2 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
            }
     
        }
        else if (index==3) {
            _leg4dest.text = [legDict objectForKey:@"destination"];
            NSDate *startDate = [legDict objectForKey:@"departureLocal"];
            _leg4StartDate.text = [startDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg4StartTime.text = [startDate dateFormat:DATE_FORMAT_HH_mm];
            NSDate *endDate = [legDict objectForKey:@"arrivalLocal"];
            _leg4EndDate.text = [endDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
            _leg4EndTime .text= [endDate dateFormat:DATE_FORMAT_HH_mm];
            
            NSArray *seatArray = [legDict objectForKey:@"seat"];
            for (NSDictionary *seatdict in seatArray) {
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"BC"]) {
                    [self.leg4lbl1 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
                if ([[seatdict objectForKey:@"name"] isEqualToString:@"JC"]) {
                    [self.leg4lbl2 createArcPathFromstart:[[seatdict objectForKey:@"availibility"] intValue] end:[[seatdict objectForKey:@"capacity"] intValue] withDistance:0];
                }
            }
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)fillViewWithData:(NSDictionary *)dict{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonClicked:(id)sender {
    
}
@end
