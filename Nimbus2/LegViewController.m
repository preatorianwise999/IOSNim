//
//  LegViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/15/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "LegViewController.h"

@interface LegViewController ()

@end

@implementation LegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *legDict = [[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"legs"] objectAtIndex:self.index];
    self.origin.text = [legDict objectForKey:@"origin"];
    self.destination.text = [legDict objectForKey:@"destination"];
    NSDate *startDate = [legDict objectForKey:@"departureLocal"];
    self.departureDate.text = [startDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
    self.departureTime.text = [startDate dateFormat:DATE_FORMAT_HH_mm];
    NSDate *endDate = [legDict objectForKey:@"arrivalLocal"];
    self.arrivalDate.text = [endDate dateFormat:DATE_FORMAT_dd_MMM_yyyy];
    self.arrivalTime.text= [endDate dateFormat:DATE_FORMAT_HH_mm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
